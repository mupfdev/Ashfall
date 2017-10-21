-- realEstate.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


-- This script is work in progress!


require("color")


Methods = {}


local realEstatePath = "/home/tes3mp/server/keepers/real_estate/"


Methods.IsOwner = function(pid)
    local message = color.Crimson .. "This house is owned by "
    local currentCell  = tes3mp.GetCell(pid)
    local previousCell = Players[pid].data.location.cell

    local f = io.open(realEstatePath .. currentCell .. ".txt", "r")
    if f ~= nil then
        local player = string.lower(tes3mp.GetName(pid))
        local owner  = f:read()
        if player ~= owner then
            WarpToPreviousPosition(pid)
            message = message .. owner .. ".\n" .. color.Default
            tes3mp.SendMessage(pid, message, false)
        end
    f:close()
    end
end


function WarpToPreviousPosition(pid)
    local posx = tes3mp.GetPreviousCellPosX(pid)
    local posy = tes3mp.GetPreviousCellPosY(pid)
    local posz = tes3mp.GetPreviousCellPosZ(pid)

    tes3mp.SetCell(pid, "")
    tes3mp.SetPos(pid, posx, posy, posz)
    tes3mp.SendCell(pid)
    tes3mp.SendPos(pid)
end


return Methods
