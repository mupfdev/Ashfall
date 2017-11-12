-- liveMap.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


json = require ("dkjson");


local path = "/path/to/assets/json/"
local updateInterval = 5

local timer = tes3mp.CreateTimerEx("TimerExpired", time.seconds(updateInterval), "i", 0)
local Info = {}


tes3mp.StartTimer(timer)


function Save(fileName, data, keyOrderArray)
    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });
    local file = assert(io.open(fileName, 'w+b'), 'Error loading file: ' .. fileName);
    file:write(content);
    file:close();
end


function Update()
    Info = {}
    for pid, player in pairs(Players) do
        if player:IsLoggedIn() then
            Info[pid] = {}
            Info[pid].name = Players[pid].name
            Info[pid].x = math.floor( tes3mp.GetPosX(pid) + 0.5 )
            Info[pid].y = math.floor( tes3mp.GetPosY(pid) + 0.5 )
            Info[pid].rot = math.floor( math.deg( tes3mp.GetRotZ(pid) ) + 0.5 ) % 360
        end
    end

    Save(path .. "LiveMap.json", Info)
    tes3mp.StartTimer(timer);
end


function TimerExpired()
    Update()
end
