-----------------------------------------------------------------------------------------
--
-- result_scene.lua
--
-----------------------------------------------------------------------------------------

-- This file contains code that describes the result scene for BrainTraner

local composer = require("composer")

local result_scene = composer.newScene()
local xCenter = display.contentCenterX
local yCenter = display.contentCenterY
local xMax = display.contentWidth
local yMax = display.contentHeight
local xMin = 0
local yMin = 0
local username = ""
local json = require("json")
local score = 0

local function gotoGame()
local options =
	{
	    effect = "fade",
	    time = 500,
	    params = {
	        uname = username,
	        round = 1,
	        numObjects = 3,
	        score = 0,
	    }
	}

	composer.gotoScene( "game_scene", options )
end

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
        file:write( json.encode( t ) )
        -- Close the file handle
        io.close( file )
        return true
    end
end

function loadTable( filename )

    -- Path for the file to read
    local docs = system.DocumentsDirectory
    local path = system.pathForFile( filename, docs )
 
    -- Open the file handle
    local file, errorString = io.open( path, "r" )
 
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
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

local function update_highscores(hs)
	temphs = {}
	local updated = 0
	for i=1, 5, 1 do 
		if updated == 1 then
			temphs[i] = hs[i-1]["score"]
			tempunames[i] = hs[i-1]["username"]
		else
			if hs[i]["score"] ~= "--" then
				if score > tonumber(hs[i]["score"]) then
					temphs[i] = score
					tempunames[i] = username
					updated = 1
				end
			else
				temphs[i] = score
				tempuanmes[i] = username
				updated = 1
			end
		end
	end
	for i=1, 5, 1 do
		hs[i]["score"] = temphs[i]
		hs[i]["username"] = tempunames[i]
	end

	saveTable(hs, "highscores.json")
	return hs
end


local function show_high_scores(s)

	local hs = loadTable("highscores.json")

	hs = update_highscores(hs)

	display.remove(game_over)
	--display.remove(final_scores)
	display.newText(s, "High Scores", xCenter, yMin + 20, native.systemFont, 32)


	--- display header --
	place = display.newText(s, "Place", xCenter - 110 , yMin + 60, native.systemFont, 24)
	user = display.newText(s, "Username", xCenter, yMin + 60, native.systemFont, 24)
	score = display.newText(s, "Score", xCenter + 110, yMin + 60, native.systemFont, 24)

	-- display highscores -- 
	for i=1, 5, 1 do 
		display.newText(s, hs[i]["place"], xCenter - 120, yMin + 60 + (i*30), native.systemFont, 24)
		display.newText(s, hs[i]["username"], xCenter, yMin + 60 + (i*30), native.systemFont, 24) 
		display.newText(s, hs[i]["score"], xCenter + 120, yMin + 60 + (i*30), native.systemFont, 24)
	end

	local playAgain = display.newText(s, "Play", display.contentCenterX, display.contentCenterY+150, native.systemFont, 44 )
	playAgain:setFillColor( 0.82, 0.86, 1 )
	playAgain:addEventListener( "tap", gotoGame )

end

function result_scene:create( event )

	local sceneGroup = self.view
	-- table for game_over text options --
	-- countdown = display.newText( sceneGroup, ""..countDownText, xCenter, yCenter, native.systemFont, 45)
	local highscores = function() return show_high_scores(sceneGroup) end
	score = event.params['score']
	username = event.params['username']
	
	if score ~= nil then
		-- game just ended
		print("score is: "..score)
		game_over = display.newText("GAME OVER", xCenter, yCenter, native.systemFontBold, 30) 
		final_score = display.newText("Final Score: "..event.params['score'], xCenter, yCenter + 50, native.systemFontBold, 24)
		timer.performWithDelay(3000, highscores)
	else
		timer.performWithDelay(500, highscores)
	end

end

-- show result_scene
function result_scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- code here runs when the scene is still off screen (but about to come on screen)
	elseif ( phase == "did" ) then
		-- code here runs when the scene is entirely on screen

	end
end

-- hide the result_scene
function result_scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- code here runs when the scene is on screen but about to dissappear

	elseif ( phase == "did" ) then
		-- code here runs immediately after the scene has dissappeared from the screen
	end
end

-- destroy()
function result_scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene
end

-- -------------------------------
-- Scene event function listeners
-- -------------------------------
result_scene:addEventListener( "create", result_scene )
result_scene:addEventListener( "show", result_scene )
result_scene:addEventListener( "hide", result_scene )
result_scene:addEventListener( "destroy", result_scene )

return result_scene