-- liveMap.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


JsonInterface = require("jsonInterface")


Methods = {}


local path = "/path/to/webroot/"
local updateInterval = 5

local timer = tes3mp.CreateTimerEx("TimerExpired", time.seconds(updateInterval), "i", 0)
local playerInfo = {}


tes3mp.StartTimer(timer)


Methods.Update = function()
    playerInfo = {}
    for playerId, player in pairs(Players) do
        if player:IsLoggedIn() then
            playerInfo[playerId] = {}
            playerInfo[playerId].name = Players[playerId].name
            playerInfo[playerId].x = tes3mp.GetPosX(playerId)
            playerInfo[playerId].y = tes3mp.GetPosY(playerId)
            playerInfo[playerId].rot = tes3mp.GetRotX(playerId)
        end
    end
    JsonInterface.save(path .. "LiveMap.json", playerInfo)
    tes3mp.StartTimer(timer);
end


function TimerExpired()
    Methods.Update()
end


return Methods
