-- TES3MP LiveMap -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


JsonInterface = require("jsonInterface")


Config.LiveMap = import(getModFolder() .. "config.lua")


local timer


function Update()
    local playerInfo = {}

    Players.for_each(function(player)
            playerInfo[player.pid] = {}
            playerInfo[player.pid].name = player.name
            playerInfo[player.pid].x, playerInfo[player.pid].y = player:getPosition()
            playerInfo[player.pid].rot = player:getRotation()
    end)

    JsonInterface.save(Config.LiveMap.path .. "LiveMap.json", playerInfo)
    timer:start()
end


Event.register(Events.ON_POST_INIT, function()
                   timer = TimerCtrl.create(Update, (Config.LiveMap.updateInterval * 100), { timer })
                   timer:start()
end)
