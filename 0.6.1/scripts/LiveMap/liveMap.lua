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
        	local playerName = Players[pid].name
            Info[playerName] = {}
            Info[playerName].pid = pid
            Info[playerName].x = math.floor( tes3mp.GetPosX(pid) + 0.5 )
            Info[playerName].y = math.floor( tes3mp.GetPosY(pid) + 0.5 )
            Info[playerName].rot = math.floor( math.deg( tes3mp.GetRotZ(pid) ) + 0.5 ) % 360
            Info[playerName].isOutside = tes3mp.IsInExterior(pid)
            Info[playerName].cell = tes3mp.GetCell(pid)
        end
    end

    Save(path .. "LiveMap.json", Info)
    tes3mp.StartTimer(timer);
end


function TimerExpired()
    Update()
end
