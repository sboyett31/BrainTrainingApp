-----------------------------------------------------------------------------------------
--
-- result_scene.lua
--
-----------------------------------------------------------------------------------------

-- This file contains code that describes the result scene for BrainTraner

-- Require modules -- 
local json = require("json")
local composer = require("composer")

-- Variables used for the results scene -- 
local xMin = 0								-- Minimum x value
local yMin = 0								-- Minimum y value
local new_hs = 0							-- New highscore index
local username = ""							-- Username of current player
local xMax = display.contentWidth			-- Maximum x value
local yMax = display.contentHeight			-- Maximum y value
local xCenter = display.contentCenterX		-- Center of the screen
local yCenter = display.contentCenterY      -- Center of the screen
local result_scene = composer.newScene()	-- The result scene object

local function gotoMenu()
	-- function to return to the menu scene --
	local options = 
	{
		effect = "fade",
		time   = 500,
	}
	composer.removeScene("result_scene")
	composer.gotoScene("title_scene", options)
end

local function gotoGame()
	-- function for the 'play again' button -- 
local options =
	{
	    effect = "fade",
	    time = 500,
	   	params = {
	        username = username,
	        round = 1,
	        numObjects = 3,
	        score = 0,
	    }
	}
	composer.removeScene("result_scene")
	composer.gotoScene( "game_scene", options )
end

function saveTable( t, filename)
 	-- function to save the updated high scores to the JSON file --
    -- Path for the file to write
    local path = system.pathForFile( filename, system.DocumentsDirectory )
    -- Open the file handle
    local file, errorString = io.open( path, "w" )
    if not file then
        -- Error occurred; output the cause
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
	-- function to load the high scores from the JSON file -- 
    -- Path for the file to read
    local docs = system.DocumentsDirectory
    local path = system.pathForFile( filename, docs )
    -- Open the file handle
    local file, errorString = io.open( path, "r" ) 
    if not file then
        -- Error occurred; output the cause
    else
        -- Read data from file
        local contents = file:read( "*a" )
        -- Decode JSON data into Lua table
        local t = json.decode( contents )
        -- Close the file handle
        io.close( file )
        -- Return table
        return t
    end
end

local function update_highscores(hs, score)
	-- function to update the highscores 
	local updated = false		-- boolean value to keep track of if highscores have been updated or not
	local temphs = {}			-- temporary dictionary used in update highscores algorithm
	local tempunames = {}		-- temporary dictionary used in update highscores algorithm 

	-- update the highscores -- 
	-- This algorithm basically makes an updated copy of the highscores -- 
	-- in temporary tables and then uses these temp tables to update hs --
	for i=1, 5, 1 do 
		if updated == true then
			temphs[i] = hs[i-1]["score"]
			tempunames[i] = hs[i-1]["username"]
		else
			if hs[i]["score"] ~= "--" and hs[i]["score"] ~= nil then
				if score > tonumber(hs[i]["score"]) then
					temphs[i] = score
					if hs[i]["username"] ~= "--" then
						tempunames[i] = username
					else
						tempunames[i] = "--"
					end
					new_hs = i
					updated = true
				else
					temphs[i] = hs[i]["score"]
					tempunames[i] = hs[i]["username"]
				end
			else
				temphs[i] = score
				tempunames[i] = username
				new_hs = i
				updated = true
			end
		end
	end
	for i=1, 5, 1 do
		hs[i]["score"] = temphs[i]
		hs[i]["username"] = tempunames[i]
	end

	-- save updated highscores to the JSON file -- 
	saveTable(hs, "highscores.json")
	return hs
end

local function show_play_button()
	-- create and display play again button -- 
	local playAgain = display.newText(result_scene.view, "Play Again", display.contentCenterX, display.contentCenterY+200, native.systemFont, 44 )
	playAgain:setFillColor( 0.82, 0.86, 1 )
	playAgain:addEventListener( "tap", gotoGame )
end

local function show_back_to_menu()
	-- create and display back to menu button -- 
	local back2Menu = display.newText(result_scene.view, "Menu", display.contentCenterX, display.contentCenterY+125, native.systemFont, 44 )
	back2Menu:setFillColor( 0.82, 0.86, 1 )
	back2Menu:addEventListener( "tap", gotoMenu )
end

local function show_high_scores(s, hs)
	-- Display the highscores -- 

	display.remove(game_over)  -- remove game over text
	
	music = audio.play(soundTable["results"], {loops=-1})

	--- display header --
	display.newText(s, "High Scores", xCenter, yMin + 20, native.systemFont, 32) 
	place = display.newText(s, "Place", xCenter - 110 , yMin + 60, native.systemFont, 24)
	user = display.newText(s, "Username", xCenter, yMin + 60, native.systemFont, 24)
	score = display.newText(s, "Score", xCenter + 110, yMin + 60, native.systemFont, 24)

	-- display highscores -- 
	for i=1, 5, 1 do 
		display.newText(s, hs[i]["place"], xCenter - 120, yMin + 60 + (i*30), native.systemFont, 24)
		if hs[i]["username"] ~= nil then
			display.newText(s, hs[i]["username"], xCenter, yMin + 60 + (i*30), native.systemFont, 24) 
		else
			display.newText(s, "---", xCenter, yMin + 60 + (i*30), native.systemFont, 24) 
		end
		if hs[i]["score"] ~= nil then
			display.newText(s, hs[i]["score"], xCenter + 120, yMin + 60 + (i*30), native.systemFont, 24)
		end
	end

	-- highlight current highscore -- 
	print("new_hs is: "..new_hs)
	if new_hs ~= 0 then
		local highlight = display.newRect(s, xCenter, yMin + 60 + (new_hs*30), 280, 25)
		highlight:setFillColor( 0.8, 1, 0, 0.4)
	end
end

	

function result_scene:create( event )
	-- Create the result scene -- 
	local sceneGroup = self.view
	local score = event.params['score']
	username = event.params['username']
	local hs = loadTable("highscores.json")

	if score ~= nil then
		-- There is a current score - so game just ended --
		-- Display end of game information and high scores after 3 seconds --
		game_over = display.newText(sceneGroup, "GAME OVER", xCenter, yCenter, native.systemFontBold, 30) 
		final_score = display.newText(sceneGroup, "Final Score: "..event.params['score'], xCenter, yCenter + 50, native.systemFontBold, 24)
		hs = update_highscores(hs, score)
		local highscores = function() return show_high_scores(sceneGroup, hs) end
		timer.performWithDelay(3000, highscores)
		timer.performWithDelay(3001, show_play_button)
		timer.performWithDelay(3002, show_back_to_menu)
	else
		-- High scores accessed from menu, simply display highscores -- 
		-- and back to menu button to allow user to navigate back 	 --
		show_high_scores(sceneGroup, hs)
		show_back_to_menu()
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
		audio.pause(music)	-- stop the music
	end
end

-- destroy()
function result_scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene
	audio.pause(music) -- stop the music
end


-- -------------------------------
-- Scene event function listeners
-- -------------------------------
result_scene:addEventListener( "create", result_scene )
result_scene:addEventListener( "show", result_scene )
result_scene:addEventListener( "hide", result_scene )
result_scene:addEventListener( "destroy", result_scene )

return result_scene