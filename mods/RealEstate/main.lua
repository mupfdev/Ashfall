-- TES3MP RealEstate -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
JsonInterface = require("jsonInterface")


Config.RealEstate = import(getModFolder() .. "config.lua")


local cellCheckLastVisitTimer
local storage = JsonInterface.load(getDataFolder() .. "storage.json")


function CommandHandler(player, args)
    if args[1] == "add" then
        if args[2] == nil then
            return false
        end
        GuestListAdd(player, args[2])
        return true
    end

    if args[1] == "remove" then
        if args[2] == nil then
            return false
        end
        GuestListRemove(player, args[2])
        return true
    end

    if args[1] == "guests" then
        GuestListShow(player)
        return true
    end

    Help(player)
    return true
end


function Help(player)
    local f = io.open(getDataFolder() .. "help.txt", "r")
    if f == nil then
        return false
    end

    local message = f:read("*a")
    f:close()

    player:getGUI():customMessageBox(231, message, "Close")
end


function CellCheck(player)
    local message = ""
    local sendMessage = false
    local cellCurrent = player:getCell().description
    local cellOwner = CellGetOwner(cellCurrent)
    local cells = CellGetList()
    local playerName = string.lower(player.name)

    if cells == -1 then return -1 end

    for index, cell in pairs(cells) do
        if cellCurrent == cell then
            if cellOwner ~= nil then
                if playerName ~= cellOwner and GuestListCheck(cellCurrent, playerName) == false then
                    message = color.Crimson .. "This house is owned by " .. cellOwner .. ".\n" .. color.Default
                    if previousCell ~= cellCurrent then
                        WarpToPreviousPosition(player)
                    else
                        WaroToSeydaNeen(player)
                    end
                    sendMessage = true
                elseif playerName == cellOwner then
                    message = color.MediumSpringGreen .. "Welcome home, " .. playerName .. ".\n" .. color.Default
                    storage[cellCurrent].lastVisit = os.time()
                    JsonInterface.save(getDataFolder() .. "storage.json", storage)
                    sendMessage = true
                elseif GuestListCheck(cellCurrent, playerName) then
                    message = color.MediumSpringGreen .. "This house is owned by " .. cellOwner .. ".\nBehave yourself accordingly.\n" .. color.Default
                    sendMessage = true
                end
            else
                local housePrice = CellGetPrice(cellCurrent)
                if housePrice == -1 then
                    housePrice = Config.RealEstate.basePrice
                end

                local playerCell = CellGetPlayerCell(player)
                if playerCell == nil then
                    player:getGUI():customMessageBox(232, "This house is for sale. You can buy it for " .. housePrice .. " Septims.\n", "Close;Buy House")
                else
                    player:getGUI():customMessageBox(233, "This house is for sale, but you already own " .. playerCell .. ".\n", "Close;Release and Buy (" .. housePrice .. ")")
                end
            end
        end
    end

    if sendMessage == true then
        player:message(message, false)
    end

    return 0
end


function CellCheckLastVisit()
    local timeCurrent = os.time()

    for index, item in pairs(storage) do
        if storage[index].lastVisit ~= nil then
            if timeCurrent - storage[index].lastVisit >= (Config.RealEstate.maxAbandonTime * 3600) then
                CellRelease(index)
                local message = index .. " has been abandoned.\n"
                logMessage(LOG_INFO, message)
                Players.for_each(function(player)
                        player:message(color.Orange .. message)
                end)
            end
        end
    end

    cellCheckLastVisitTimer:start()
end


function CellBuy(player)
    local message = ""
    local sendMessage = false
    local cellCurrent = player:getCell().description
    local cellOwner   = CellGetOwner(cellCurrent)
    local cells = CellGetList()
    --local playerGold = 0
    local playerGold  = 1000000
    --local goldIndex

    if cells == -1 then return -1 end

    --if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", "gold_001", true) then
    --    goldIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", "gold_001")
    --    playerGold = Players[pid].data.inventory[goldIndex].count
    --end

    for index, cell in pairs(cells) do
        if cellCurrent == cell and cellOwner == nil then

            local housePrice = CellGetPrice(cellCurrent)
            if housePrice == -1 then
                housePrice = Config.RealEstate.basePrice
            end

            if playerGold < housePrice then
                message = color.Crimson .. "You need at least " .. tostring(housePrice) .. " Septims to buy this house.\n" .. color.Default
                sendMessage = true
            else
                CellSetOwner(cellCurrent, player)
                message = color.MediumSpringGreen .. "Welcome home, " .. player.name .. ".\n" .. color.Default
                --Players[pid].data.inventory[goldIndex].count = playerGold - housePrice
                --Players[pid]:Save()
                --Players[pid]:LoadInventory()
                --Players[pid]:LoadEquipment()
                sendMessage = true
            end
        end
    end

    if sendMessage == true then
        player:message(message, false)
    end

    return 0
end


function CellRelease(cell)
    if storage[cell] == nil then
        storage[cell] = {}
    end
    storage[cell] = {}
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function Portkey(player)
    if player:getInventory():hasItemEquipped(string.lower(Config.RealEstate.portkeyRefId)) and Config.RealEstate.portkey == true then
        local message = ""
        local sendMessage = false
        local playerCell = CellGetPlayerCell(player)

        if playerCell == nil then
            message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
            sendMessage = true
        else
            player:getInventory():unequipItem(Config.RealEstate.portkeySlot)
            player:getCell().description = playerCell
        end

        if sendMessage == true then
            player:message(message, false)
        end
    end
end


function CellGetList()
    local tmp = {}
    local cells = {}

    local f = io.open(getDataFolder() ..  package.config:sub(1, 1) .. "cells.txt", "r")
    if f ~= nil then
        for line in f:lines() do
            table.insert(tmp, line)
        end
        f:close()

        for index, item in pairs(tmp) do
            for substr in string.gmatch(item, '([^:]+)') do
                table.insert(cells, substr)
                break
            end
        end

        return cells
    end

    return -1
end


function CellGetOwner(cell)
    if storage[cell] == nil then
        return nil
    end

    return storage[cell].owner
end


function CellGetPlayerCell(player)
    for index, item in pairs(storage) do
        if storage[index].owner == string.lower(player.name) then
            return index
        end
    end

    return nil
end


function CellGetPrice(cell)
    local price = 0
    local tmp = {}
    local hit = false

    local f = io.open(getDataFolder() .. "cells.txt", "r")
    if f ~= nil then
        for line in f:lines() do
            table.insert(tmp, line)
        end
        f:close()

        for index, item in pairs(tmp) do
            for substr in string.gmatch(item, '([^:]+)') do
                if hit == true then
                    price = tonumber(substr)
                    if price then return price end
                end
                if substr == cell then hit = true end
            end
            if hit == true then break end
        end
    end

    return -1
end


function CellSetOwner(cell, player)
    if storage[cell] == nil then
        storage[cell] = {}
    end

    storage[cell].owner = string.lower(player.name)
    storage[cell].lastVisit = os.time()
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function GuestListGetList(cell)
    if storage[cell].guestList == nil then
        storage[cell].guestList = {}
    end

    return storage[cell].guestList
end


function GuestListCheck(cell, guestName)
    local guestList = GuestListGetList(cell)

    if guestList[1] == nil then
        return false
    end

    for index, item in pairs(guestList) do
        if item == guestName then
            return true
        end
    end

    return false
end


function GuestListAdd(player, guestName)
    local guestName = string.lower(guestName)
    local message = ""
    local playerCell = CellGetPlayerCell(player)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
    else
        if GuestListCheck(playerCell, guestName) then
            message = color.Orange .. guestName .. " is already on your guest list.\n" .. color.Default
        else
            if storage[playerCell].guestList == nil then
                storage[playerCell].guestList = {}
            end

            table.insert(storage[playerCell].guestList, guestName)
            message = color.MediumSpringGreen .. guestName .. " is now considered a guest.\n" .. color.Default
            JsonInterface.save(getDataFolder() .. "storage.json", storage)
        end
    end

    player:message(message, false)
    return true
end


function GuestListRemove(player, guestName)
    local message = ""
    local playerCell = CellGetPlayerCell(player)

    guestName = string.lower(guestName)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
    else
        if GuestListCheck(playerCell, guestName) then
            for index, item in pairs(storage[playerCell].guestList) do
                if item == string.lower(guestName) then
                    table.remove(storage[playerCell].guestList, index)
                end
            end
            message = color.MediumSpringGreen .. guestName .. " is no longer welcome in your house.\n" .. color.Default
            JsonInterface.save(getDataFolder() .. "storage.json", storage)
        else
            message = color.Orange .. guestName .. " is not on your guest list.\n" .. color.Default
        end
    end

    player:message(message, false)
    return true
end


function GuestListShow(player)
    local message = ""
    local sendMessage = false
    local playerCell = CellGetPlayerCell(player)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
        sendMessage = true
    else
        local guestList = GuestListGetList(playerCell)

        if guestList[1] == nil then
            message = color.Crimson .. "Your guest list is empty.\n" .. color.Default
            sendMessage = true
        else
            message = message .. color.Orange .. "Guests of " ..  playerCell .. "\n\n" .. color.Default
            for index, item in pairs(guestList) do
                message = message .. item .. "\n"
            end
            player:getGUI():customMessageBox(234, message, "Close")
        end
    end

    if sendMessage == true then
        player:message(message, false)
    end

    return true
end


function WarpToPreviousPosition(player)
    player:getCell().description = player.customData.cellPrevious
    --local posx = tes3mp.GetPreviousCellPosX(pid)
    --local posy = tes3mp.GetPreviousCellPosY(pid)
    --local posz = tes3mp.GetPreviousCellPosZ(pid)
end


-- https://i.imgur.com/FCGYYqH.jpg
-- It's a meme, not a typo.
function WaroToSeydaNeen(player)
    player:getCell().description = "-2, -9"
end


Event.register(Events.ON_GUI_ACTION, function(player, id, button)
                   if id == 232 then
                       if tonumber(button) == 1 then
                           CellBuy(player)
                       end
                   end
                   if id == 233 then
                       if tonumber(button) == 1 then
                           local cell = CellGetPlayerCell(player)
                           CellRelease(cell)
                           CellBuy(player)
                       end
                   end
end)


Event.register(Events.ON_PLAYER_CELLCHANGE, function(player)
                   -- Dirty hack to determine previous cell.
                   -- Todo:
                   --   GetPreviousCellPosX
                   --   GetPreviousCellPosY
                   --   GetPreviousCellPosZ
                   if player:getCell():isExterior() == true then
                       player.customData["cellPrevious"] = player:getCell().description
                   end
                   --
                   CellCheck(player)
end)


Event.register(Events.ON_PLAYER_EQUIPMENT, function(player)
                   Portkey(player)
end)


Event.register(Events.ON_POST_INIT, function()
                   cellCheckLastVisitTimer = TimerCtrl.create(CellCheckLastVisit, 300000, { cellCheckLastVisitTimer })
                   cellCheckLastVisitTimer:start()
end)


CommandController.registerCommand("house", CommandHandler, color.Salmon .. "/house help" .. color.Default .. " - Real estate system.")
