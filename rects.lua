-----------------------------------------------------------------------------------------
--
-- rects_rects.lua
--
-----------------------------------------------------------------------------------------

-- This file contains code that describes the game scene for BrainTraner

local composer = require("composer")

local rects = composer.newScene()


-- state variables updated and passed to scenes --
local username = ""
local level = 1

-- game specific variables -- 
local rect_table = {} 
local nums = {}
local xCenter = display.contentCenterX
local yCenter = display.contentCenterY
local maxX = display.contentWidth
local maxY = display.contentHeight
local minX = 0
local minY = 0
print("xCenter"..xCenter)
print("yCenter"..yCenter)
print("maxX: "..maxX)
print("maxY: "..maxY)
-- Functions to transition scenes -- 


function rects:create( event )
	local sceneGroup = self.views
    for x, y in pairs(event.params['pos']) do
    	print("x is: "..x)
    	print("y is: "..y)
    	if (x ~= nil) and (y ~= nil) then
	    	rect = display.newRect(sceneGroup, x, y, 80, 60)
	    	table.insert(rect_table, rect)
	    end
    end
end
	    

-- show rects
function rects:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- code here runs when the scene is still off screen (but about to come on screen)
	elseif ( phase == "did" ) then
		-- code here runs when the scene is entirely on screen

	end
end

-- hide the rects
function rects:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- code here runs when the scene is on screen but about to dissappear

	elseif ( phase == "did" ) then
		-- code here runs immediately after the scene has dissappeared from the screen
	end
end

-- destroy()
function rects:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene
end

-- -------------------------------
-- Scene event function listeners
-- -------------------------------
rects:addEventListener( "create", rects )
rects:addEventListener( "show", rects )
rects:addEventListener( "hide", rects )
rects:addEventListener( "destroy", rects )

return rects
