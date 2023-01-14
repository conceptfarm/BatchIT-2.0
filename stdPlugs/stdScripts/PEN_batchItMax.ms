/*
Client:PEN Productions Inc.

Created By: Paul Neale
Company: PEN Productions Inc.
E-Mail: info@paulneale.com
Site: http://paulneale.com
Start Date: unknown. 

Edited: Ilya Floussov
Date: November 2022
- added open script button
- date grid view for file selection

Purpose:
Max version 5x,6x,7x,8x,9x
Batch processes Max files with Max scripts. 

Usage:
PEN_batchItMax.run()
PEN_batchItMax.closeUi()

Updated:
	Oct 04 2006
	-Updated UI to make it wider
	-Nested tool in a struct and functions so it can be called from other tools. 

Bugs:
-Escape doesn't work

ToDo:
-File has been batched. Write this data into the file properties.
*/

struct PEN_batchItMax
(
	batchUtil=undefined,
	displayScale = 1,
	dgvWidth = 1196,
	dgvWidthWithBar = 1212,
	dgvRowHeight = 16,--26
	dgvHeaderRowHeight = 20,--36
	
	fn closeUi=
	(
		if batchUtil != undefined then
		(
			destroyDialog batchUtil
			batchUtil = undefined
		)
	),
	
	fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n),
	
	-- Expects dotnet DataTime object
	fn dotNetDate t = 
	(
		(padNumber t.year 4)+"\\"+(padNumber t.month 2)+"\\"+(padNumber t.day 2)+" "+(padNumber t.hour 2)+":"+(padNumber t.minute 2)+":"+(padNumber t.second 2)
	),
	
	fn getFileLastWriteTime f =
	(
		local t = (dotnetclass "System.IO.File").GetLastWriteTime(f)
		dotNetDate t 
	),
	
	fn run=
	(
		-- Interface
		rollout batchUtil_R "Batch It Max v1.1" width:1200
		(
			local btW = 80
				
			button browseScriptDir_bt "Browse" width:btW align:#left across:2
			editText batchScriptDir_et "Scripts Directory:" fieldWidth:980 align:#right
			
			button browseProcess_bt "Browse" width:btW align:#left across:2
			editText batchProcessDir_et "Process Directory:" fieldWidth:980 align:#right
			
			checkbox overWrite_cb " Overwrite Files on Save" checked:true across:3 align:#left offset:[195,0]
			checkBox dontSaveFilesCb " Don't Save Files" offset:[-20,0]
			checkBox useFileUnits_cb " Use File's Units" offset:[-180,0] checked: true
			
			button browseSaveFolder_bt "Browse" width:btW  align:#left across:2
			editText saveFolder_et "Save Files To:" fieldWidth:980 align:#right
		
			label dgvScriptFiles_lbl "Select batch scripts to run:" width:1080 align:#right offset:[0,15]
			dotNetControl dgvScriptFiles "DataGridView" width:1080 height:160 align:#right 
			
			label dgvMaxFiles_lbl "Select Max Files to Process:" width:1080 align:#right offset:[0,15]
			editText search_et "Match file path:" fieldWidth:1080 align:#right
			editText dontMatch_et "Don't match:" fieldWidth:1080 align:#right
			dotNetControl dgvMaxFiles "DataGridView" width:1080 height:500 align:#right 
			
			label prog0_lb "0%" across:3 align:#left
			label prog50_lb "50%"
			label prog1000_lb "100%" align:#right
			progressBar progBar_pb
		
			checkBox saveLog_cb ":Save Log File" checked:true align:#left pos:[14,160]
			button setLogFile_bt "Set Log File" width:btW align:#left
			button readLog_bt "Read Log File" width:btW align:#left
			button openScript_bt "Open Script" width:btW align:#left
			
			button getFiles_bt "Get Files"  width:btW align:#left pos:[14,420]
			checkBox recurse_cb ":Recursive" checked:true align:#left
			button selAll_bt "Select All" width:btW align:#left offset:[0,40]
			button deSelAll_bt "Select None" width:btW align:#left
			button invSelAll_bt "Select Inverse" width:btW align:#left
			button process_bt "Process" width:btW align:#left offset:[0,20]
			
			button close_bt "Close" width:btW align:#left offset:[0,200]
			
			fn scaleForDisplay n s = (n*s)
			
			-- DGV STUFF --
			fn styleDGV dgvObject = 
			(
				dgvObject.SelectionMode = (dotnetclass "DataGridViewSelectionMode").FullRowSelect
				dgvObject.Dock = dgvMaxFiles.Dock.Fill
				dgvObject.RowHeadersVisible = false
				
				--Colour and Styling
				local oddColor=(dotnetclass "system.drawing.color").fromARGB 32 32 32
				local evenColor= (dotnetclass "system.drawing.color").fromARGB 68 68 68  			
				
				local rowTemplate = dgvObject.RowTemplate
				rowTemplate.Height = scaleForDisplay PEN_batchItMax.dgvRowHeight displayScale 
				
				local defaultCellStyle = dotnetobject "DataGridViewCellStyle"
				defaultCellStyle.backColor = evenColor
				defaultCellStyle.SelectionBackColor = (dotnetclass "system.drawing.color").fromARGB 80 200 69
				
				local altDefaultCellSyle = dotnetobject "DataGridViewCellStyle"
				altDefaultCellSyle.backColor = oddColor

				local ColumnHeadersDefaultCellStyle = dotnetobject "DataGridViewCellStyle"
				ColumnHeadersDefaultCellStyle.backcolor = (dotnetclass "system.drawing.color").fromARGB 100 100 100
				ColumnHeadersDefaultCellStyle.forecolor = (dotnetclass "system.drawing.color").fromARGB 255 255 255 
				ColumnHeadersDefaultCellStyle.WrapMode = (dotnetclass "DataGridViewTriState").true

				dgvObject.defaultCellStyle = defaultCellStyle
				dgvObject.AlternatingRowsDefaultCellStyle = altDefaultCellSyle
				dgvObject.BackgroundColor = (dotnetclass "system.drawing.color").fromARGB 68 68 68			
				dgvObject.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
				dgvObject.ColumnHeadersDefaultCellStyle = ColumnHeadersDefaultCellStyle
				dgvObject.EnableHeadersVisualStyles = false
				dgvObject.CellBorderStyle = (dotnetclass "DataGridViewCellBorderStyle").None
				dgvObject.RowHeadersBorderStyle =  (dotnetclass "DataGridViewHeaderBorderStyle").Single
				dgvObject.ColumnHeadersBorderStyle =(dotnetclass  "DataGridViewHeaderBorderStyle").Single
				
				dgvObject.ColumnHeadersHeight =  scaleForDisplay PEN_batchItMax.dgvHeaderRowHeight displayScale
				dgvObject.AllowUserToResizeColumns = false
				dgvObject.ColumnHeadersHeightSizeMode = (dotnetclass "DataGridViewColumnHeadersHeightSizeMode").DisableResizing
				dgvObject.AllowUserToResizeRows = false
				dgvObject.RowHeadersWidthSizeMode = (dotnetclass "DataGridViewRowHeadersWidthSizeMode").DisableResizing
				dgvObject.ScrollBars = (dotnetclass "ScrollBars").Vertical
			)
		
			fn populateColumns dgvObject defList = 
			(
				for o in defList do
				(
					local col = undefined 
					case o[2] of 
					(
						"text":(
									col = (dotnetobject "DataGridViewTextBoxColumn")
								)
						"button": (
									col = (dotnetobject "DataGridViewButtonColumn")
									col.sortmode = (dotnetclass "DataGridViewColumnSortMode").NotSortable
								)
						"number": (
									col = (dotnetobject "DataGridViewTextBoxColumn")
									--Not a good idea to set column to integer mode, harder to handle non-number entries
									--col.valueType = (dotnetclass "type").gettype "System.Int32"
								)
						"check":(
									col = (dotnetobject "DataGridViewCheckBoxColumn")
								)
						"object": (col = (dotnetobject "DataGridViewTextBoxColumn"))
					)
					
					col.DataPropertyName = "Name"
					col.Name = o[1]
					col.width = o[3]
					
					if o[1] == "FilePath" then col.visible = false
					
					dgvObject.Columns.Add (col)
				)
			)
						
			fn populateDGV dgvObject dgvData= 
			(
				if dgvObject.name == "dgvMaxFiles" then 
				(
					for i = 0 to i = (dgvData.count - 1) do
					(
						local dgvDataRow = dgvData[i+1]
						local row = dgvObject.rows.item[dgvObject.rows.add()]
						--row.height = PEN_batchItMax.dgvRowHeight

						dgvObject.rows.item[i].cells.item["File"].value = dgvDataRow[1]
						dgvObject.rows.item[i].cells.item["File"].ReadOnly = true
						dgvObject.rows.item[i].cells.item["Date"].value = dgvDataRow[2]
						dgvObject.rows.item[i].cells.item["Date"].ReadOnly = true
						dgvObject.rows.item[i].cells.item["FilePath"].value = dgvDataRow[3]
						dgvObject.rows.item[i].cells.item["FilePath"].ReadOnly = true
					)
				)
				else if dgvObject.name == "dgvScriptFiles" then 
				(
					for i = 0 to i = (dgvData.count - 1) do
					(
						local dgvDataRow = dgvData[i+1]
						local row = dgvObject.rows.item[dgvObject.rows.add()]
						--row.height = PEN_batchItMax.dgvRowHeight

						dgvObject.rows.item[i].cells.item["File"].value = dgvDataRow[1]
						dgvObject.rows.item[i].cells.item["File"].ReadOnly = true
						dgvObject.rows.item[i].cells.item["Description"].value = dgvDataRow[2][1]
						dgvObject.rows.item[i].cells.item["Description"].ReadOnly = true
						dgvObject.rows.item[i].cells.item["Run With Save"].value = dgvDataRow[2][2]
						dgvObject.rows.item[i].cells.item["Run With Save"].ReadOnly = true
						dgvObject.rows.item[i].cells.item["FilePath"].value = dgvDataRow[3]
						dgvObject.rows.item[i].cells.item["FilePath"].ReadOnly = true
					)
				)
				print dgvObject.name
				--cameraObjIDsNoMod = for i = 0 to dgvObject.rows.count - 1 collect dgvObject.rows.item[i].cells.item["Date"].value
				
				--_height = 	ceil ((dgvRowHeight/displayScale*(allCams.count)) + dgvHeaderRowHeight/displayScale + 2)
				--if _height > dgvObject.height then (dgvObject.Columns["File"].width = dgvObject.Columns["File"].width-17)
				--print( dgvObject.Columns[0].width)

				dgvObject.AllowUserToAddRows = false
				dgvObject.AllowUserToDeleteRows = false
				dgvObject.ClearSelection()
			)
			
			fn dgvUpdate dgvObject dgvData= 
			(
				dgvObject.Rows.Clear()
				populateDGV dgvObject dgvData
			)
			
			fn setDGVSelection dgvObject selArray =
			(
				dgvObject.ClearSelection()
				
				for i in selArray do
				(
					dgvObject.rows.item[i-1].selected = true
				)
			)
			
			-- END DGV STUFF --
			
			-- Sets the ini file for the interface	
			fn setBatchIni_fn sectionStr keyStr valueStr =
			(
				logPath = (getDir #plugCfg) + "\\" + "BatchIni.ini"
				setIniSetting logPath sectionStr keyStr valueStr
			)
			
			-- Gets the ini settings for the interface.
			fn getBatchIni_fn sectionStr keyStr =
			(
				logPath = (getDir #plugCfg) + "\\" + "BatchIni.ini"
				outStr = (getIniSetting logPath sectionStr keyStr)
				return outStr
			)
			
			-- Collects the scripts in the designated folder.
			fn getScipts_fn dir =
			(
				local files = #()
				if dir != "" then 
				(
					allFiles = (getFiles (dir + "\\" + "*.ms"))
					files = for x in allFiles collect (fileNameFromPath x)
				)
				files
			)
			
			fn getScriptDescription filePath = 
			(
				local f = openFile filePath mode:"rt"
				local result = #("","")
				local delimInfo = "--batchitInfo: "
				local delimSave = "--batchitSave: "
				
				if (f != undefined) then (seek f 0)
				
				try
				(
					local parsedLine = readline f
					if matchpattern parsedLine pattern:(delimInfo + "*") then
					(
						local st = substring parsedLine (delimInfo.count +1) (-1)
						result[1] = trimLeft (trimRight st)
					)
					
					parsedLine = readline f
					if matchpattern parsedLine pattern:(delimSave + "*") then
					(
						local st = substring parsedLine (delimSave.count+1) (-1)
						result[2] = trimLeft (trimRight st)
					)
				)
				catch()
				close f
				free f
				result
			)
			
			fn getSciptsData_fn dir =
			(
				local files = #()
				if dir != "" then 
				(
					local allFiles = (getFiles (dir + "\\" + "*.ms"))
					files = for f in allFiles collect #(fileNameFromPath f, getScriptDescription f, f)
				)
				files
			)
			
			
			-- Collects the Max files in the designated folders with the option of recursive or not.
			fn getMaxFiles_fn dir =
			(
				if recurse_cb.checked then
				(
					local dir1 = getDirectories (dir + "*")
					for d in dir1 do
					(
						join dir1 (getDirectories (d + "*"))
					)
					
					local files = #()
					for f in dir1 do
					(
						join files (getFiles (f + "/*.max"))
					)
					files
				)
				else
				(
					files = (getFiles (dir + "\*.max"))
					files
				)
			)
			
			fn getMaxFilesData_fn dir = 
			(
				local maxFiles = getMaxFiles_fn dir
				for f in maxfiles collect #(pathConfig.convertPathToRelativeTo f dir , getFileLastWriteTime f , f)
			)
			
			--  Search max file paths for string and don't match based on dont string
			fn searchMaxFiles_fn dgvObject matchStr dontStr =
			(
				local matchIndexArray = #()
				local deleteIndexes = #()
				local numFiles = dgvObject.rows.count
				
				for i = 1 to numFiles do
				(
					if (matchPattern dgvObject.rows.item[i-1].cells.item["FilePath"].value pattern:matchStr)  then (append matchIndexArray i)
				)
				
				for i = 1 to matchIndexArray.count do
				(
					local dontArray = FilterString dontStr " "
					local deleteIndex = false
					for s in dontArray do 
					(
						if matchPattern dgvObject.rows.item[matchIndexArray[i]-1].cells.item["FilePath"].value pattern:("*" + s + "*") then deleteIndex = true
					)
					append deleteIndexes deleteIndex
				)
				
				for i = matchIndexArray.count to 1 by -1 do
				(
					if deleteIndexes[i] then deleteItem matchIndexArray i
				)
				matchIndexArray
			)
			
			fn setLogPath_fn =
			(
				if saveLog_cb.checked == true then
				(
					path = getSaveFileName caption:"Select Log File" \
							fileName:"MaxBatchLog.log" \
							types:"Log Data (*.log)|*.log"
					if path != undefined then
					(
						-- Write log path to Ini file
						setBatchIni_fn "batchUtil" "LogPath" path
						logFile = createFile path
					)
				)
			)
			
			-- Create and write Log file.
			-- FileIn is the file path being processed
			-- ScriptIn is an array of the batch scripts being run on each max file
			Fn logFile_fn fileIn scriptIn =
			(
				if saveLog_cb.checked == true then
				(
					iniEx = if (getFiles ((getDir #plugCfg) + "\\" + "BatchIni.ini")).count > 0 then (true) else (false)
					openedFile = if iniEx then (openFile (getBatchIni_fn "batchUtil" "LogPath") mode:"a+")else(undefined)
					
					if openedFile != undefined then
					(
						format "File: %\n" fileIn to:openedFile
						format "\tDate:\t\t%\n" localTime to:openedFile
						format "\tUser:\t\t%\n" sysInfo.userName to:openedFile
						format "\tComputer:\t%\n" sysInfo.computerName to:openedFile
						for x in scriptIn do
						(
							format "\tScript:\t\t%\n" (fileNameFromPath x) to:openedFile
						)
						format "\n" to:openedFile
						close openedFile
					)else
					(
						--  Error message goes here.
					)
				)
				fileProperties.addProperty #custom "Batch Processed" ""
				fileProperties.addProperty #custom "Date:" localTime #Date
				fileProperties.addProperty #custom "User:" sysInfo.userName
				fileProperties.addProperty #custom "Computer:" sysInfo.computerName
				fileproperties.addproperty #summary "author" sysInfo.userName
		
				for x in scriptIn do
				(
					fileProperties.addProperty #custom "Script:" (fileNameFromPath x)
					curComment=try(fileProperties.getPropertyValue #summary 2)catch("")
					fileproperties.addproperty #summary "comments" (curComment+"\n"+("Batched with:\n"+(fileNameFromPath x)))
				)
				
			)
			
			--  Run on opening the interface. Gets and sets the interface settings and positions the 
			--  dialog to the last used position.
			on batchUtil_R open do
			(
				iniEx = if (getFiles ((getDir #plugCfg) + "\\" + "BatchIni.ini")).count > 0 then (true) else (false)
		
				batchScriptDir_et.text = if iniEx then (getBatchIni_fn "batchUtil" "batchDir") else (getDir #scripts)
				batchProcessDir_et.text = if iniEx then (getBatchIni_fn "batchUtil" "processDir") else (getDir #scene)
				saveFolder_et.text = if iniEx then (getBatchIni_fn "batchUtil" "saveFolder") else (getDir #scene)
				overWrite_cb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "overWrite")) else (true)
				dontSaveFilesCb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "dontSaveFiles")) else (true)
				
				saveLog_cb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "saveLog")) else (true)
				recurse_cb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "recurse")) else (true)
				
				-- Update the scripts list on open
				--batchList_mlb.items = (getScipts_fn batchScriptDir_et.text)
				
				-- Get the position of the Dialog
				setDialogPos batchUtil_R (if iniEx then (execute (getBatchIni_fn "batchUtil" "Position")) else ([10,100]))
		
				if overWrite_cb.state then
				(
					browseSaveFolder_bt.enabled = false
					saveFolder_et.enabled = false
				)
				else
				(
					browseSaveFolder_bt.enabled = true
					saveFolder_et.enabled = true
				)
				
				if dontSaveFilesCb.state then
				(
					overWrite_cb.enabled=not dontSaveFilesCb.state
					browseSaveFolder_bt.enabled=not dontSaveFilesCb.state
					saveFolder_et.enabled=not dontSaveFilesCb.state
				)
				
				-- DGV STUFF -- 
				
				if ((maxVersion())[1] > 18000) then (displayScale = ((sysInfo.DesktopSizeUnscaled)/(sysInfo.desktopSize)).x)
					
				defListMaxFiles= #(
						#("File","text",scaleForDisplay 900 displayScale), 
						#("Date","text",scaleForDisplay 180 displayScale),
						#("FilePath","text",scaleForDisplay 0 displayScale)
				)
				
				defListScriptFiles= #(
						#("File","text",scaleForDisplay 260 displayScale), 
						#("Description","text",scaleForDisplay 700 displayScale),
						#("Run With Save","text",scaleForDisplay 120 displayScale),
						#("FilePath","text",scaleForDisplay 0 displayScale)
				)
				
				dgvWidth = (local c = 0; for i=1 to defListMaxFiles.count do c= c + defListMaxFiles[i][3]; c) -- ? +3 --1196
				dgvWidthWithBar = dgvWidth + 17--(scaleForDisplay 17 displayScale) --1212

				dgvMaxFiles.Name = "dgvMaxFiles"
				dgvScriptFiles.Name = "dgvScriptFiles"
				populateColumns dgvMaxFiles defListMaxFiles
				populateColumns dgvScriptFiles defListScriptFiles
				styleDGV dgvMaxFiles
				styleDGV dgvScriptFiles
				
				local dgvScriptData = getSciptsData_fn batchScriptDir_et.text
				populateDGV dgvScriptFiles dgvScriptData
				
				--dgvUpdateSize dgv dgvNoMod
		
			)

			-- Run on closing the dialog. Saves the last used settings for the interface and dialog position.
			on batchUtil_R close do
			(
				setBatchIni_fn "batchUtil" "batchDir" batchScriptDir_et.text
				setBatchIni_fn "batchUtil" "processDir" batchProcessDir_et.text
				setBatchIni_fn "batchUtil" "saveFolder" saveFolder_et.text
				setBatchIni_fn "batchUtil" "overWrite" (overWrite_cb.checked as string)
				setBatchIni_fn "batchUtil" "dontSaveFiles" (dontSaveFilesCb.checked as string) 
				setBatchIni_fn "batchUtil" "saveLog" (saveLog_cb.checked as string)
				setBatchIni_fn "batchUtil" "recurse" (recurse_cb.checked as string)
				
				-- Save position of the dialog
				setbatchIni_fn "batchUtil" "Position" (getDialogPOs batchUtil_R as string)
			)
			
			on browseScriptDir_bt pressed do
			(
				local filePath = (getSavePath caption:"Choose Directory for Scripts" initialDir:batchScriptDir_et.text )
				if filePath != undefined then
				(
					batchScriptDir_et.text = filePath
					--batchList_mlb.items = (getScipts_fn batchScriptDir_et.text)
					local dgvScriptData = getSciptsData_fn batchScriptDir_et.text
					dgvUpdate dgvScriptFiles dgvScriptData
				)
			)
			
			on browseProcess_bt pressed do
			(
				path = (getSavePath caption:"Select process directory" initialDir:batchProcessDir_et.text )
				if path != undefined then
				(
					batchProcessDir_et.text = path
					getMaxFiles_fn path
				)
			)
			
			on browseSaveFolder_bt pressed do
			(
				path = (getSavePath caption:"Select Save File directory")
				if path != undefined then
				(
					saveFolder_et.text = path
				)
			)
			
			on batchScriptDir_et entered str do
			(
				--batchList_mlb.items = (getScipts_fn str)
				local dgvScriptData = getSciptsData_fn batchScriptDir_et.text
				dgvUpdate dgvScriptFiles dgvScriptData
			)
			
			on batchProcessDir_et entered str do
			(
				--maxFiles_mlb.items = (getMaxFiles_fn batchProcessDir_et.text)
				local dgvData = getMaxFilesData_fn batchProcessDir_et.text
				dgvUpdate dgvMaxFiles dgvData
			)
			
			on overWrite_cb changed state do
			(
				if state then
				(
					browseSaveFolder_bt.enabled = false
					saveFolder_et.enabled = false
				)
				else
				(
					browseSaveFolder_bt.enabled = true
					saveFolder_et.enabled = true
				)
			)
			
			-- Dont save checkbox
			on dontSaveFilesCb changed state do
			(
				overWrite_cb.enabled = not state
				if state == true then
				(
					browseSaveFolder_bt.enabled = not state
					saveFolder_et.enabled = not state
				)
				else
				(
					browseSaveFolder_bt.enabled = not overWrite_cb.checked
					saveFolder_et.enabled = not overWrite_cb.checked
				)					
			)
			
			-- Search for files in MLB
			on search_et entered str do
			(
				setDGVSelection dgvMaxFiles (searchMaxFiles_fn dgvMaxFiles search_et.text dontMatch_et.text)
			)
			
			-- Search for files in MLB

			on dontMatch_et entered str do
			(
				setDGVSelection dgvMaxFiles (searchMaxFiles_fn dgvMaxFiles search_et.text dontMatch_et.text)
			)
			
			-- Set Log File
			on setLogFile_bt pressed do
			(
				setLogPath_fn()
			)
			
			-- Read log file
			on readLog_bt pressed do
			(
				edit (getBatchIni_fn "batchUtil" "LogPath")
			)
			
			on getFiles_bt pressed do
			(
				local dgvData = getMaxFilesData_fn batchProcessDir_et.text
				dgvUpdate dgvMaxFiles dgvData
			)
			
			-- Select all
			on selAll_bt pressed do
			(
				setDGVSelection dgvMaxFiles #{1..dgvMaxFiles.rows.count}
			)
			
			-- Delselect all
			on deSelAll_bt pressed do
			(
				dgvMaxFiles.ClearSelection()
			)
			
			--  Select Inverse
			on invSelAll_bt pressed do
			(
				local temp = (for i=0 to dgvMaxFiles.rows.count-1 where dgvMaxFiles.rows.item[i].selected == false collect i+1) as bitArray
				setDGVSelection dgvMaxFiles temp
			)
			
			on recurse_cb changed state do
			(
				local dgvData = getMaxFilesData_fn batchProcessDir_et.text
				dgvUpdate dgvMaxFiles dgvData
			)
			
			-- Start the process going.
			on process_bt pressed do
			(
				local proceed = false
				local scriptCheck = false
				
				local scriptSel = for i=0 to dgvScriptFiles.rows.count-1 where dgvScriptFiles.rows.item[i].selected == true collect dgvScriptFiles.rows.item[i].cells.item["FilePath"].value
				local scriptRunSave = for i=0 to dgvScriptFiles.rows.count-1 where dgvScriptFiles.rows.item[i].selected == true collect dgvScriptFiles.rows.item[i].cells.item["Run With Save"].value
				local fileSel = for i=0 to dgvMaxFiles.rows.count-1 where dgvMaxFiles.rows.item[i].selected == true collect dgvMaxFiles.rows.item[i].cells.item["FilePath"].value
				
				if dontSaveFilesCb.state == true and findItem scriptRunSave "true" > 0 then
				(
					local qb = queryBox "Script suggests to run with Don't Save Files UNCHECKED?\nProceed anyway?"
					if qb == true then scriptCheck = true
				)
				else if dontSaveFilesCb.state == false and findItem scriptRunSave "false" > 0 then
				(
					local qb = queryBox "Script suggests to run with Don't Save Files CHECKED?\nProceed anyway?"
					if qb == true then scriptCheck = true
				)
				else scriptCheck = true
				
				if dontSaveFilesCb.checked and scriptCheck then 
				(
					local qb = queryBox "Proceed WITHOUT SAVING?"
					if qb == true then proceed = true
				)
				else if overWrite_cb.checked and scriptCheck then 
				(
					local qb = queryBox "Proceed WITH OVERWRITTING?\nThere is no UNDO!"
					if qb == true then proceed = true
				)
				
				if proceed == true then
				(
					print "proceed"
					
					escapeEnable = true
					
					progBar_pb.value = 0
					local iter = 0
					
					-- check that files and scripts have been selected.
					if (scriptSel.count > 0) and (fileSel.count > 0) then
					(
						escapeEnable = true
						-- Loop through files, open and run script.
						for maxFile in fileSel do
						(
							-- Load the max file and run the selected scripts.
							loadMaxFile maxFile useFileUnits:useFileUnits_cb.checked quiet:true
							local scriptsIn = #() --  List of scripts run on each file. To be written to Log file.
							for scriptFile in scriptSel do
							(
								fileIn scriptFile
								--fileIn (batchScriptDir_et.text + "\\" + batchList_mlb.items[s])
								append scriptsIn (getFilenameFile scriptFile)
							)
							
							-- Write data to log.
							if (getBatchIni_fn "batchUtil" "LogPath") != "" then
							(	
								logFile_fn maxFile scriptsIn
							)
							else
							(
								setLogPath_fn()
								logFile_fn maxFile scriptsIn
							)
							
							-- Save max file
							-- Get path name
							local saveDir = ""
							if overWrite_cb.checked then
							(
								-- Path if file is to be overwritten.
								saveDir = (getFileNamePath maxFile)
							)
							else
							(
								-- Path if new folder is choosen
								saveDir = (saveFolder_et.text)
							)
							
							-- get file name
							local file = (fileNameFromPath maxFile)
							
							-- Save the file to the correct path if dontSaveFilesCb is unchecked. 
							if dontSaveFilesCb.state == false then
							(
								saveMaxFile (saveDir + "\\" + file)
							)
							
							-- Update progress bar
							progBar_pb.value = ((100.0 * (iter += 1)) / fileSel.count)
						)
					)
					else 
					(
						messageBox "Please select Scripts and Files to process."
					)
				)
			)
			
			
			-- Open selected script file
			on openScript_bt pressed do
			(
				--local scriptSel = 0
				local scriptSel = for i=0 to dgvScriptFiles.rows.count-1 where dgvScriptFiles.rows.item[i].selected == true collect dgvScriptFiles.rows.item[i].cells.item["FilePath"].value
				/*
				for x = 1 to batchList_mlb.items.count do
				(
					if batchList_mlb.selection[x] == true do (scriptSel += 1)
				)
				*/
				if scriptSel.count > 0 then
				(
					for f in scriptSel do
					(
						--local f =  (batchScriptDir_et.text + "\\" + batchList_mlb.items[s])
						ShellLaunch f ""
					)
				)
				else
				(
					Messagebox "No script selected"
				)
			)
				
			-- Cancel dialog
			on close_bt pressed do
			(
				destroyDialog batchUtil_R
			)
			
		)-- End Rollout
		
		batchUtil=batchUtil_R
		createDialog batchUtil_R style:#(#style_titleBar, #style_border, #style_sysMenu, #style_minimizeBox)
	)-- End Run Function
)-- End Struct

PEN_batchItMax=PEN_batchItMax()














