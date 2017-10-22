-- items.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Methods = {}


-- Add [ items = require("items") ] to the top of server.lua
-- Find "OnPlayerEquipment(pid)" inside server.lua and insert:
-- [ items.IronFork(pid) ]
-- [ items.TsiyasRing(pid) ]
-- directly underneath it.


--local slotHelmet        = 0;
--local slotCuirass       = 1;
--local slotGreaves       = 2;
--local slotLeftPauldron  = 3;
--local slotRightPauldron = 4;
--local slotLeftGauntlet  = 5;
--local slotRightGauntlet = 6;
--local slotBoots         = 7;
--local slotShirt         = 8;
--local slotPants         = 9;
--local slotSkirt         = 10;
--local slotRobe          = 11;
--local slotLeftRing      = 12;
--local slotRightRing     = 13;
--local slotAmulet        = 14;
--local slotBelt          = 15;
local slotCarriedRight  = 16;
--local slotCarriedLeft   = 17;
--local slotAmmunition    = 18;


function PlayerHasItemEquipped(pid, list)
    local c = 0
    local i = 1

    while list[i] ~= nil do
        if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
        i = i + 1
    end

    if c > 0 then return true else return false end
end



Methods.IronFork = function(pid)
    if tes3mp.HasItemEquipped(pid, "iron fork") then
        local message = color.CornflowerBlue .. ""
        local cell
        local pos = {}
        local rot = {}

        message = color.CornflowerBlue .. "The sensation of travelling by portkey is universally agreed to be uncomfortable.\n"
        cell    = "Vivec, Arena Pit"
        pos[0]  = "913.79772949219"
        pos[1]  = "-12.880634307861"
        pos[2]  = "-459.41949462891"
        rot[0]  = "-0.15609979629517"
        rot[1]  = "-1.569390296936"

        if tes3mp.GetCell(pid) == "Vivec, Arena Pit" then
            message = color.LightBlue .. "It feels quite unpleasent to travel by portkey.\n"
            cell    = "-2, -9"
            pos[0]  = -11150.272460938
            pos[1]  = -70746.1796875
            pos[2]  = 235.42088317871
            rot[0]  = -0.057221055030823
            rot[1]  = -0.22354483604431
        end

        if tes3mp.GetHealthCurrent(pid) <= (tes3mp.GetHealthBase(pid)/100)*10 then
            message = color.CornflowerBlue .. "Suddenly you found yourself floating in the air. Uh-oh!\n"
            cell    = "-2, -9"
            pos[0]  = -11150.272460938
            pos[1]  = -70746.1796875
            pos[2]  = 10235.42088317871
            rot[0]  = -0.057221055030823
            rot[1]  = -0.22354483604431
        end

        tes3mp.UnequipItem(pid, slotCarriedRight)
        tes3mp.SendEquipment(pid)

        tes3mp.SetPos(pid, pos[0], pos[1], pos[2])
        tes3mp.SetRot(pid, rot[0], rot[1])
        tes3mp.SetCell(pid, cell)
        tes3mp.SendCell(pid)
        tes3mp.SendPos(pid)

        message = message .. color.Default
        tes3mp.SendMessage(pid, message, false)
    end
end


Methods.TsiyasRing = function(pid)
    local tsiyasRingModel = "mudcrab"

    if tes3mp.HasItemEquipped(pid, "common_ring_tsiya") then
        tes3mp.SetCreatureModel(pid, tsiyasRingModel, false)
        tes3mp.SendBaseInfo(pid)
    end
end


return Methods
