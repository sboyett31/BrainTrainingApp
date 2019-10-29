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

-- Sound table -- 
soundTable = {}

-- loading sound table to be used during game -- 
soundTable["ding"] = audio.loadSound("ding.mp3")
soundTable["wrong"] = audio.loadSound("wrong.mp3")
soundTable["roundWin"] = audio.loadSound("roundWin.mp3")
soundTable["results"]  = audio.loadSound("results.mp3")

-- Go to the menu screen
local options =
{
    effect = "crossFade",
    time = 1200,
}
composer.gotoScene( "title_scene", options)
