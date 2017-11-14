-- BannedItems.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


Methods = {}


-- Add [ BannedItems = require("BannedItems") ] to the top of myMod.lua

-- Find "OnPlayerInventory(pid)" inside myMod.lua and insert:
-- [ BannedItems.Remove(pid) ]
-- directly underneath [ Players[pid]:SaveInventory() ].


Methods.Remove = function(pid)
    local message = color.Crimson .. "Banned item has been removed.\n" .. color.Default

    -- Ridiculously over-powerful items which can be obtained without
    -- difficulty. Or items that simply destroy the overall balance:
    local bannedItems = {
        "daedric_fountain_helm", "daedric_terrifying_helm",
        "daedric_god_helm", "daedric_cuirass", "daedric_cuirass_htab",
        "daedric_greaves", "daedric_greaves_htab",
        "daedric_pauldron_left", "daedric_pauldron_right",
        "gauntlet_fists_l_unique", "gauntlet_fists_r_unique",
        "daedric_gauntlet_left", "daedric_gauntlet_right",
        "daedric_boots", "helseth's ring", "towershield_eleidon_unique",
        "azura's servant", "spell_breaker_unique", "daedric_shield",
        "daedric_towershield", "gravedigger", "boots of blinding speed[unique]",
        "bound_shield", "bound_boots", "bound_gauntlet_right",
        "bound_gauntlet_left", "bound_cuirass", "bound_helm"
    }

    local hadBannedItem = false

    for index, item in pairs(bannedItems) do
        if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", item, true) then
            hadBannedItem = true
            local itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", item)
            Players[pid].data.inventory[itemIndex] = nil
        end

        if tableHelper.containsKeyValue(Players[pid].data.equipment, "refId", item, true) then
            hadBannedItem = true
            local itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.equipment, "refId", item)
            Players[pid].data.equipment[itemIndex] = nil
        end
    end

    if hadBannedItem == true then
        Players[pid]:Save()
        Players[pid]:LoadInventory()
        Players[pid]:LoadEquipment()
        tes3mp.SendMessage(pid, message, false)
    end
end


return Methods
