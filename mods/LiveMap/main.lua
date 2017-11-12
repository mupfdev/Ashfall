-- TES3MP LiveMap -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


JsonInterface = require("jsonInterface")


Config.LiveMap = import(getModFolder() .. "config.lua")


local timer
local Info = {}

function Update()
    Info = {}

    Players.for_each(function(player)
            Info[player.pid] = {}
            Info[player.pid].name = player.name
            Info[player.pid].x, Info[player.pid].y = player:getPosition()
            Info[player.pid].rot = player:getRotation()
            Info[player.pid].x = math.floor( Info[player.pid].x + 0.5)
            Info[player.pid].y = math.floor( Info[player.pid].y + 0.5)
            Info[player.pid].rot = math.floor( math.deg(Info[player.pid].rot) + 0.5 ) % 360

    end)

    JsonInterface.save(Config.LiveMap.path .. "LiveMap.json", Info)
    timer:start()
end


Event.register(Events.ON_POST_INIT, function()
                   timer = TimerCtrl.create(Update, (Config.LiveMap.updateInterval * 1000), { timer })
                   timer:start()
end)

