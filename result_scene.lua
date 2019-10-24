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

local function show_high_scores()
		local high_scores = {
		text = ("High Scores"),
		x = xCenter,
		y = yMin + 30,
		font = native.systemFont,
		fontSize = 32,
	}

	display.remove(game_over)
	display.remove(final_score)
	display.newText(high_scores)
end

function result_scene:create( event )

	local sceneGroup = self.view
	-- table for game_over text options --
	-- countdown = display.newText( sceneGroup, ""..countDownText, xCenter, yCenter, native.systemFont, 45)

	if event.params['score'] ~= nil then
		-- game just ended
		game_over = display.newText("GAME OVER", xCenter, yCenter, native.systemFontBold, 30) 
		final_score = display.newText("Final Score: "..event.params['score'], xCenter, yCenter + 50, native.systemFontBold, 24) 
	end


	timer.performWithDelay(3000, show_high_scores)
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