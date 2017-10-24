-- hardcoreMode.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


userConfig = require("userConfig")


Methods = {}


-- Add [ hardcoreMode = require("hardcoreMode") ] to the top of myMod.lua
-- Find "Players[pid]:ProcessDeath()" inside myMod.lua and add:
-- [ hardcoreMode.Check(pid) ]
-- above it.


local playerFilePath = "/path/to/data/player/"


Methods.Check = function(pid)
    if userConfig.GetValue(pid, "hardcore") == "true" then
        local message = color.Crimson .. "You have passed away. Rest in peace." .. color.Default
        os.remove(playerFilePath .. tes3mp.GetName(pid) .. ".json")
        tes3mp.SendMessage(pid, message, false)
        tes3mp.SendMessage(pid, color.Crimson .. tes3mp.GetName(pid) .. " is dead and gone for good. Press F to pay respects." .. color.Default, true)
        while true do end
    end
end


return Methods
