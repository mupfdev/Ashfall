-- HeightMap.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


-- THIS SCRIPT IS UNDER ACTIVE DEVELOPMENT AND THEREFORE UNFINISHED.


local collectInterval = 2
local timerHMCollect = tes3mp.CreateTimerEx("HMCollectTimerExpired", time.seconds(collectInterval), "i", 0)


tes3mp.StartTimer(timerHMCollect)


function HMCollect()
    local heightMap = {}
    local gridSize = 64
    local tolerance = 32
    local addition = 50

    for pid, player in pairs(Players) do
        if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
            if tes3mp.IsInExterior(pid) == true then
                local posx = tes3mp.GetPosX(pid)
                local posy = tes3mp.GetPosY(pid)
                local posz = tes3mp.GetPosZ(pid)

                local hitX = false
                local hitY = false

                if posx >= 0 then
                    if posx % gridSize <= tolerance then hitX = true end
                    posx = posx - (posx % gridSize)
                else
                    if math.abs(posx) % gridSize <= tolerance then hitX = true end
                    posx = math.abs(posx) - (math.abs(posx) % gridSize)
                    posx = posx - (posx * 2)
                end

                if posy >= 0 then
                    if posy % gridSize <= tolerance then hitY = true end
                    posy = posy - (posy % gridSize)
                else
                    if math.abs(posy) % gridSize <= tolerance then hitY = true end
                    posy = math.abs(posy) - (math.abs(posy) % gridSize)
                    posy = posy - (posy * 2)
                end

                if hitX == true and hitY == true then
                    tes3mp.SendMessage(pid, "[" .. posx .. "]" .. "x[" .. posy .. "]: " .. (posz + addition) .. "\n", false)
                end
            end
        end
    end

    tes3mp.StartTimer(timerHMCollect);
end


function HMCollectTimerExpired()
    HMCollect()
end
