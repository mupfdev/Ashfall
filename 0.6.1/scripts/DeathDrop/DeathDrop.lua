-- DeathDrop.lua -*-lua-*-
-- "THE BEER-WARE LICENCE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


Methods = {}


-- Add [ DeathDrop = require("DeathDrop") ] to the top of myMod.lua

-- Find "Players[pid]:ProcessDeath()" inside myMod.lua and add:
-- [ DeathDrop.Drop(pid) ]
-- directly above it.


Methods.Drop = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        for index, item in pairs (Players[pid].data.inventory) do

            local mpNum = WorldInstance:GetCurrentMpNum() + 1
            local cell = tes3mp.GetCell(pid)
            local location = {
                posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
            }
            local refId = item.refId
            local refIndex =  0 .. "-" .. mpNum

            WorldInstance:SetCurrentMpNum(mpNum)
            tes3mp.SetCurrentMpNum(mpNum)

            LoadedCells[cell]:InitializeObjectData(refIndex, refId)
            LoadedCells[cell].data.objectData[refIndex].location = location
            table.insert(LoadedCells[cell].data.packets.spawn, refIndex)
            table.insert(LoadedCells[cell].data.packets.actorList, refIndex)
            LoadedCells[cell]:Save()

            tes3mp.InitializeEvent(pid)
            tes3mp.SetEventCell(cell)
            tes3mp.SetObjectRefId(refId)
            tes3mp.SetObjectRefNumIndex(0)
            tes3mp.SetObjectMpNum(mpNum)

            tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
            tes3mp.AddWorldObject()
            tes3mp.SendObjectSpawn()

            Players[pid].data.inventory[index] = nil
        end

        Players[pid]:Save()
        Players[pid]:LoadInventory()
    end
end


return Methods
