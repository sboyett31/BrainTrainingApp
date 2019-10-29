local composer = require( "composer" )  
local json = require("json")
local scene = composer.newScene()
local username = ""
local round = 1
local xCenter = display.contentCenterX
local yCenter = display.contentCenterY

-- function to switch to the game scene 
local function gotoGame()
local options =
	{
	    effect = "slideDown",
	    time = 500,
	    params = {
	        username = username,
	        round = round,
	        score = 0,
	        numObjects = 3,
	    }
	}
	composer.gotoScene( "game_scene", options )
end

-- function to switch to the highscores scene
local function gotoHighScores()
	scene.view:remove(1)
	local options =
		{
		    effect = "crossFade",
		    time = 500,
		    params = {
		        uname = nil,
		        score = nil,
		    }
		}
	composer.removeScene( "title_scene ")
	composer.gotoScene( "result_scene", options )
end

-- function to load the Highscores table from the JSON file
function loadTable( filename )
    -- Path for the file to read
    local docs = system.DocumentsDirectory
    local path = system.pathForFile( filename, docs )
    -- Open the file handle
    local file, errorString = io.open( path, "r" )
    if not file then
        -- Error occurred; output the cause
        return false
    else
        -- Read data from file
        print("opened")
        local contents = file:read( "*a" )
        print ("read .. "..contents)
        -- Decode JSON data into Lua table
        local t = json.decode( contents )
        -- Close the file handle
        io.close( file )
        -- Return table
        return t
    end
end

-- Function to save the highscores table to the JSON file
function saveTable( t, filename)
    -- Path for the file to write
    local path = system.pathForFile( filename, system.DocumentsDirectory )
    -- Open the file handle
    local file, errorString = io.open( path, "w" )
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Write encoded JSON data to file
        print("file opened")
        file:write( json.encode( t ) )
        print("json written")
        -- Close the file handle
        io.close( file )
        return true
    end
end

-- function that handles the user input in the textbox 
local function textListener( event )
    if ( event.phase == "began" ) then
        -- User begins editing "defaultBox"
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultBox"
        print( event.target.text )
    elseif ( event.phase == "editing" ) then
        print( event.newCharacters )
        print( event.oldText )
        print( event.startPosition )
        print( event.text )
        username = event.text
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- manage highscores table --
	highscores = loadTable("highscores.json")
	if highscores == false then
		-- No highscores file found, initialize
		 highscores = {
			{ place='1st', username='--', score='--'},
			{ place='2nd', username='--', score='--'},
			{ place='3rd', username='--', score='--'},
			{ place='4th', username='--', score='--'},
			{ place='5th', username='--', score='--'},
		}
	end

	-- save highscores to "highscores.json"
	saveTable(highscores, "highscores.json")

	-- create the background for the title scene -- 
	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- create and display the title of the game --
	local title = display.newText( sceneGroup, "Sequence", display.contentCenterX, display.contentCenterY-200, native.systemFont, 44)
	title:setFillColor( 0.75, 0.78, 1 )
	title.x = display.contentCenterX
	title.y = display.contentCenterY -200

	-- Prompt the user for a user name --
	local userText = display.newText( sceneGroup, "User: ", display.contentCenterX-100, display.contentCenterY, native.systemFont, 18)

	-- Create and display the textbox for the user to enter a user name and adds textListener event listener -- 
	local unametext = native.newTextField( display.contentCenterX, display.contentCenterY, 150, 25)
	unametext.x = xCenter
	unametext.y = yCenter
	unametext.isEditable = true
	sceneGroup:insert(1, unametext)
	unametext:addEventListener( "userInput", textListener )

	-- Create and display the play button and add event listener that takes user to game -- 
	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, display.contentCenterY+100, native.systemFont, 44 )
	playButton:setFillColor( 0.82, 0.86, 1 )
	playButton:addEventListener( "tap", gotoGame )

	-- Create and display the highscores button and adds event listener that takes user to highscores --
	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, display.contentCenterY+175, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.75, 0.78, 1 )
	highScoresButton:addEventListener( "tap", gotoHighScores )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- add username text box back to the screen -- 
		local unametext = native.newTextField( display.contentCenterX, display.contentCenterY, 150, 25)
		unametext.x = xCenter
		unametext.y = yCenter
		unametext.isEditable = true
		scene.view:insert(1, unametext)
		unametext:addEventListener( "userInput", textListener )
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen


	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		sceneGroup:remove(1)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	-- remove user input text box from the screen -- 
	sceneGroup:remove(1)

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
