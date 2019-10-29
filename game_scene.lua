-----------------------------------------------------------------------------------------
--
-- game_scene.lua
--
-----------------------------------------------------------------------------------------

-- This file contains code that describes the game scene for BrainTraner

local composer = require("composer")
local json = require("json")

local game_scene = composer.newScene()

-- state variables updated and passed to different scenes --
local username = ""
local score = 0

-- game specific tables -- 
local pos = {}			-- holds x and y positions for where numbers/sprites will be generated
local set = {}			-- table to prevent pos[x] overwrites
local nums = {}			-- table to hold the number objects
local rects = {}	    -- table to hold the rectangle objects
local soundTable = {}   -- table to hold the different sound options to play during gameplay

-- game specific variables -- 
local xMin = 0							-- minimum x value
local yMin = 0							-- minimum y value
local round = 1							-- current round of the game
local click_num = 1						-- current click number by user (used to check if right sprite selected)
local rectWidth = 80					-- Width of the Imagerect object used to display sprites
local rectHeight = 60					-- Height of the image rect object used to display sprites
local numObjects = 3					-- Current number of objects (numbers/sprites) to be displayed 
local countDownText = "3"				-- The text that starts the countDown
local xMax = display.contentWidth		-- Maximum X value
local yMax = display.contentHeight		-- Maximum Y value
local xCenter = display.contentCenterX	-- Middle of the screen X value for readability / ease of typing
local yCenter = display.contentCenterY	-- Middle of the screen Y value for readability / ease of typing

-- loading sound table to be used during game -- 
soundTable["wrong"] = audio.loadSound("wrong.mp3")
soundTable["click"] = audio.loadSound("click.wav")

-- Functions to transition scenes -- 
local function gotoGame(lvl, num, score)
	-- Function to transition to the game scene --
	local options =
		{
		    effect = "slideDown",
		    time = 1200,
		    params = {
		        username = username,
		        round = lvl,
		        numObjects = num,
		        score = score,
		    }
		}
	composer.removeScene("game_scene")
	composer.gotoScene( "game_scene", options )
end

local function gotoResults()
	-- Function to transition to the result scene --
	local options = 
		{
		    effect = "crossFade",
		    time = 1200,
		    params = {
		        username = username,
		     	score = score
		    }
		}
	composer.removeScene("game_scene")
	composer.gotoScene( "result_scene", options )
end

local function removeRects()
	-- Function to remove all of the rectangles --
	for k, v in pairs(rects) do
		if v ~= nil then
			v:removeSelf()
			v = nil	
		end
	end
end

local function removeNums()
	-- function to remove all of the numbers from screen -- 
	for k, v in pairs(nums) do 
		if v ~= nil then
			v:removeSelf()
			v = nil
		end
	end
end

local function removeRemainingRects(click_num)
	-- function to remove only the remaining rectangles -- 
	-- this is used after the round has been lost       --
	for i=click_num, numObjects, 1 do
		rects[i]:removeSelf()
		rects[i] = nil
	end
end


local function roundWin()
	-- function called when a round is completed successfully      --
	-- this function cleans up the screen and displays a checkmark --
	-- this function also plays a sound to indicate a round win    --
	removeNums()
	display.remove(roundText)
	display.remove(scoreText)
	local checkMark = display.newImageRect( game_scene.view, "Correct.png", 320, 480 )
	checkMark.x = display.contentCenterX
	checkMark.y = display.contentCenterY	
end

local function roundLoss()
	-- function called when a round is not completed succesfully -- 
	-- this function cleans up the screen and displays a red X   -- 
	-- this function also plays a sound to indicate a round loss -- 
	removeNums()
	display.remove(roundText)
	display.remove(scoreText)
	removeRemainingRects(click_num)
	audio.play(soundTable["wrong"])
	local X = display.newImageRect( game_scene.view, "wrong.png", 320, 480 )
	X.x = display.contentCenterX
	X.y = display.contentCenterY
end


local function check_order(event) 
	-- Function called every time a user clicks a sprite             -- 
	-- This function checks the number of the click and compares it  --
	-- to the index of the sprite that was selected.  			     --

	if event.target.index == click_num then
		-- Click number == index of sprite (correct) -- 
		audio.play(soundTable["right"])	-- play correct click sound
		event.target:removeSelf()		-- remove sprite
		event.target = nil				-- remove sprite
		if click_num == numObjects then	
			-- That was the last sprite -- 
			score = score + numObjects  -- increase score by number of sprites	 
			roundWin()					-- call round Win function
			-- Proceed 2 the next round -- 
			nextLevel = function() gotoGame(round+1, numObjects+1, score) end
			timer.performWithDelay(1500, nextLevel)
		else 
			-- Was not the last sprite  --
			click_num = click_num + 1	
		end
	elseif event.target.index ~= click_num then
		-- Click number ~= index of sprite (incorrect) -- 
		roundLoss()	-- call round loss function
		-- Go to next round with decremented number of objects --
		nextLevel = function() gotoGame(round+1, numObjects-1, score) end
		timer.performWithDelay(1500, nextLevel)
	end
end

local function showRects()
	-- Display the sprites to cover up the numbers -- 
	-- These sprites are linked to the positions   -- 
	-- of the numbers through the 'pos' table      -- 
	local index = 1
	for x, y in pairs(pos) do
		rect = display.newImageRect("galaxy.png", rectWidth, rectHeight)
		rect.x = x
		rect.y = y
		rect.index = index
		rect:addEventListener("tap", check_order)
		table.insert(rects, rect)
		index = index + 1
	end
end

local function showNums(s)
	-- Display the numbers that will be covered up  -- 
	-- By the sprites, linked through the pos table --
	local i = 1
	for x, y in pairs(pos) do 
		num = display.newText(s, ""..i, x, y, native.systemFont, 25)
		table.insert(nums, num)
		i = i + 1
	end		
end

local function divideScreen(numObjects)
	-- this function divides the phone screen into segments based --
	-- on how many objects are to be created, this is done by     --
	-- creating a table of boundaries for each new segment        --
	local grid = {}
	for i=1, numObjects, 1 do
		grid[i] = {}
	end
	local rows = math.ceil(numObjects/2)
	local cols = 2
	local squares = rows*cols
	local top = yMin + 75 
	local yIncr = (yMax - top)/rows
	local xIncr = xMax/2
	local count = 1
	local row = 1
	local col = 1

	for k, v in pairs(grid) do
		-- create boundaries for each segment -- 
		v['xMin'] = xMin + (xIncr * (col-1))
		v['yMin'] = top + (yIncr * (row-1))
		v['xMax'] = xMin + (xIncr * col) 
		v['yMax'] = top + (yIncr * row)
		row = row + 1
		if row == rows+1 then
			row = 1
			col = col + 1
		end
	end

	return grid
end

local function startRound()
	-- This function starts a specific round based on the status of the game -- 
	local sceneGroup = game_scene.view
	local x = 1	 -- variable for x position of objects
	local y = 1  -- variable for y position of objects
	local rect = nil
	display.remove(countdown)	-- remove the countdown
	countdown:removeSelf()		-- remove the countDown

	-- Display the round and score information -- 
	roundText = display.newText( sceneGroup, "Round "..round, xCenter, yMin, native.systemFont, 45)
	scoreText = display.newText( sceneGroup, "Score: "..score, xCenter, yMin + 30, native.systemFont, 16)
	-- get grid boundaries --
	grid = divideScreen(numObjects)

	for k, v in pairs(grid) do
		-- create positions for objects to be placed -- 
		x = -1   -- dummy value to initialize while loop 
		set[x] = true
		while(set[x]) do 
			-- while loop to prevent duplicate x values causing overwrite in pos table -- 
	    	x = math.random(v['xMin'] + (rectWidth/2), v['xMax'] - (rectWidth/2))
	    end
    	y = math.random(v['yMin'] + (rectHeight/2), v['yMax'] - (rectHeight/2))
		pos[x] = y
		set[x] = true
	end
	-- display the numbers -- 
	showNums(sceneGroup)
	-- cover the numbers with sprites after 0.7s -- 
	timer.performWithDelay(700, showRects)
end

local function countDown()
	-- this function performs the countdown before each round of the game --
	-- and is called by a timer in the game_scene:create function         --
	if countdown.text == '1' then
		startRound()   -- start round after countdown has finished 
	else
		countdown.text = countdown.text - 1
	end
end

function game_scene:create( event )
	-- start countdown for round start
	local sceneGroup = self.view
	round = event.params['round']
	numObjects = event.params['numObjects']
	score = event.params['score']
	username = event.params['username']

	if round <= 10 then
		-- begin the round with the countdown if the round is <= 10 --
		countdown = display.newText( sceneGroup, ""..countDownText, xCenter, yCenter, native.systemFont, 45)
		timer.performWithDelay(1000, countDown, 3)
	end
end


-- show game_scene
function game_scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		-- code here runs when the scene is still off screen (but about to come on screen)
	elseif ( phase == "did" ) then
		-- code here runs when the scene is entirely on screen
		if round == 11 then
			-- if 10 rounds have been played, END GAME -- 
			gotoResults()
		end
	end
end

-- hide the game_scene
function game_scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- code here runs when the scene is on screen but about to dissappear

	elseif ( phase == "did" ) then
		-- code here runs immediately after the scene has dissappeared from the screen
	end
end

-- destroy()
function game_scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene
end

-- -------------------------------
-- Scene event function listeners
-- -------------------------------
game_scene:addEventListener( "create", game_scene )
game_scene:addEventListener( "show", game_scene )
game_scene:addEventListener( "hide", game_scene )
game_scene:addEventListener( "destroy", game_scene )


return game_scene
