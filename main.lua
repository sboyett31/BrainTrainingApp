-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require( "composer" )

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator
math.randomseed( os.time() )

-- Go to the menu screen
local options =
{
    effect = "crossFade",
    time = 1200,
    params = {
        sampleVar1 = "my sample variable",
        sampleVar2 = "another sample variable"
    }
}
composer.gotoScene( "title_scene", options)
