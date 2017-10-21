-- motd.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Methods = {}


-- Add [ motd = require("motd") ] to the top of server.lua
-- Find "myMod.OnPlayerConnect(pid, playerName)" inside server.lua and insert:
-- [ motd.Show(pid) ]
-- directly underneath it.


Methods.Show = function(pid)
    local motd = "/path/to/motd.txt"
    local message

    local f = io.open(motd, "r")
    if f == nil then return -1 end

    message = f:read("*a")
    f:close()

    message = color.Orange .. message
    message = message .. color.OrangeRed .. os.date("Now: %A %I:%M %p")
    message = message .. color.Default .. "\n"
    tes3mp.SendMessage(pid, message, false)

    return 0
end


return Methods
