-----------------------------------------------------------------------------------------
--
-- game_scene.lua
--
-----------------------------------------------------------------------------------------

-- This file contains code that describes the game scene for BrainTraner

local composer = require("composer")

local game_scene = composer.newScene()

-- state variables updated and passed to scenes --
local username = "bob"
local score = 0

-- game specific variables -- 
local rects = {}
local pos = {}
local nums = {}
local xCenter = display.contentCenterX
local yCenter = display.contentCenterY
local xMax = display.contentWidth
local yMax = display.contentHeight
local xMin = 0
local yMin = 0
local click_num = 1
local countDownText = "3"
local round = 1
local numObjects = 3
print("xCenter"..xCenter)
print("yCenter"..yCenter)
print("xMax: "..xMax)
print("yMax: "..yMax)
-- Functions to transition scenes -- 
local function gotoGame(lvl, num, score)
	print("gotogame reaced round is: "..round)
	local options =
		{
		    effect = "slideDown",
		    time = 1200,
		    params = {
		        uname = username,
		        round = lvl,
		        numObjects = num,
		        score = score,
		    }
		}
	composer.removeScene("game_scene")
	composer.gotoScene( "game_scene", options )
end

local function gotoResults()
	local options = 
		{
		    effect = "crossFade",
		    time = 1200,
		    params = {
		        uname = username,
		     	score = score
		    }
		}
	--composer.removeScene("game_scene")
	composer.gotoScene( "result_scene", options )
end

local function removeRects()
	for k, v in pairs(rects) do
		if v ~= nil then
			v:removeSelf()
			v = nil	
		end
	end
end

local function removeRemainingRects(click_num)
	for i=click_num, numObjects, 1 do
		rects[i]:removeSelf()
		rects[i] = nil
	end
end

local function check_order(event) 
	print("click function reached.. index is: "..event.target.index)
	if event.target.index == click_num then
		event.target:removeSelf()
		event.target = nil
		print("click_num is: ".. click_num)
		print("game_scene.round is"..round)
		if click_num == numObjects then
			score = score + numObjects
			nextLevel = function() gotoGame(round+1, numObjects+1, score) end
			timer.performWithDelay(500, nextLevel)
			-- gotoGame(round + 1, numObjects + 1, score)
		else 
			click_num = click_num + 1
		end
	elseif event.target.index ~= click_num then
		removeRemainingRects(click_num)
		gotoGame(round + 1, numObjects - 1, score)
	end
end


local function enableClick() 
	for k, v in pairs(rects) do 
		rects[k]:addEventListener("tap", check_order)
		print("event listener added")
	end
end


local function showRects()
	local index = 1
	for x, y in pairs(pos) do
		rect = display.newRect(x, y, 80, 60)
		rect.index = index
		table.insert(rects, rect)
		index = index + 1
	end
end

local function showNums(s)
	local i = 1
	for x, y in pairs(pos) do 
		num = display.newText(s, ""..i, x, y, native.systemFont, 25)
		table.insert(nums, num)
		i = i + 1
	end		
end

local function divideScreen(numObjects)
	local grid = {}
	for i=1, numObjects, 1 do
		grid[i] = {}
	end
	local rows = math.ceil(numObjects/2)
	local cols = 2
	local squares = rows*cols
	top = yMax 
	local yIncr = yMax/rows
	local xIncr = xMax/2
	local count = 1
	local row = 1
	local col = 1

	for k, v in pairs(grid) do
		v['xMin'] = xMin + (xIncr * (col-1))
		v['yMin'] = yMin + (yIncr * (row-1))
		v['xMax'] = xMin + (xIncr * col) 
		v['yMax'] = yMin + (yIncr * row)
		print("count is: "..count)
		row = row + 1
		if row == rows+1 then
			row = 1
			col = col + 1
		end
	end

	for k, v in pairs(grid) do
		for k2, v2 in pairs(v) do 
			print("v2 is: "..v2)
		end
	end
	return grid
end

local function startGame()
	local sceneGroup = game_scene.view
	local x = 1
	local y = 1
	local rect = nil
	display.remove(countdown)
	countdown:removeSelf()
	display.newText( sceneGroup, "Round "..round, xCenter, yMin, native.systemFont, 45)
	display.newText( sceneGroup, "Score: "..score, xCenter, yMin + 30, native.systemFont, 16)
	grid = divideScreen(numObjects)
	for k, v in pairs(grid) do
		-- create positions for objects
	    x = math.random(v['xMin'], v['xMax'])
    	y = math.random(v['yMin'], v['yMax'])
    	print("['xmin'] is: "..v['xMin'])
    	print("['xmax'] is: "..v['xMax'])
    	print("['ymin'] is: "..v['yMin'])
    	print("['ymax'] is: "..v['yMax'])

    	print("x,y :"..x..","..y)
		pos[x] = y
	end
	showNums(sceneGroup)
	timer.performWithDelay(700, showRects)
	timer.performWithDelay(710, enableClick)
end

local function countDown()

	if countdown.text == '1' then
		startGame()
	else
		countdown.text = countdown.text - 1
	end
end

function game_scene:create( event )
	-- start countdown for game start
	local sceneGroup = self.view
	round = event.params['round']
	numObjects = event.params['numObjects']
	score = event.params['score']

	if round <= 10 then
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
