-- TES3MP RealEstate -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
JsonInterface = require("jsonInterface")
Config.RealEstate = import(getModFolder() .. "config.lua")


local cellMonitorLastVisitTimer
local storage = JsonInterface.load(getDataFolder() .. "storage.json")


function CommandHandler(player, args)
    if args[1] == nil then
        CellShowPlayerCellGUI(player)
        return true
    end

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

    if args[1] == "lock" then
        CellLockPlayerCell(player)
        return true
    end

    if args[1] == "unlock" then
        CellUnlockPlayerCell(player)
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
    local goldCurrencyName = GoldGetCurrencyName()
    local playerName = string.lower(player.name)

    if cells == -1 then return -1 end

    for index, cell in pairs(cells) do
        if cellCurrent == cell then
            if cellOwner ~= nil then
                if CellGetLockState(currentCell) == false and playerName ~= cellOwner then
                    message = color.Orange .. "You found this house unlocked.\n"
                    sendMessage = true

                elseif playerName ~= cellOwner and GuestListCheck(cellCurrent, playerName) == false then
                    message = color.Crimson .. "This house is owned by " .. cellOwner .. ".\n"
                    if previousCell ~= cellCurrent then
                        WarpToPreviousPosition(player)
                    else
                        WaroToSeydaNeen(player)
                    end
                    sendMessage = true

                elseif playerName == cellOwner then
                    message = color.MediumSpringGreen .. "Welcome home, " .. playerName .. ".\n"
                    sendMessage = true
                    CellUpdateLastVisit(cellCurrent)

                elseif GuestListCheck(cellCurrent, playerName) then
                    message = color.MediumSpringGreen .. "This house is owned by " .. cellOwner .. ".\nBehave yourself accordingly.\n"
                    CellUpdateLastVisit(cellCurrent)
                    sendMessage = true

                end
            else
                local housePrice = CellGetPrice(cellCurrent)
                if housePrice == -1 then
                    housePrice = Config.RealEstate.basePrice
                end

                local playerCell = CellGetPlayerCell(player)
                if playerCell == nil then
                    player:getGUI():customMessageBox(232, "This house is for sale. You can buy it for " .. housePrice .. " " .. goldCurrencyName .. ".\n", "Close;Buy House")
                else
                    player:getGUI():customMessageBox(233, "This house is for sale, but you already own " .. playerCell .. ".\n", "Close;Release and Buy (" .. housePrice .. ")")
                end
            end
        end
    end

    message = message .. color.Default
    if sendMessage == true then
        player:message(message, false)
    end

    return 0
end


function CellMonitorLastVisit()
    local timeCurrent = os.time()

    for index, item in pairs(storage) do
        if storage[index].lastVisit ~= nil then
            if timeCurrent - storage[index].lastVisit >= (Config.RealEstate.maxAbandonTime * 3600) then
                CellRelease(index)
                local message = index .. " has been abandoned.\n"
                logMessage(Log.LOG_INFO, message)
                Players.for_each(function(player)
                        player:message(color.Orange .. message)
                end)
            end
        end
    end

    cellMonitorLastVisitTimer:start()
end


function CellUpdateLastVisit(cell)
    if storage[cell] == nil then
        storage[cell] = {}
    end

    storage[cell].lastVisit = os.time()
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function CellBuy(player)
    local message = ""
    local sendMessage = false
    local cellCurrent = player:getCell().description
    local cellOwner   = CellGetOwner(cellCurrent)
    local cells = CellGetList()
    local goldCurrencyName = GoldGetCurrencyName()
    local goldAmount = GoldGetAmount(player)

    if cells == -1 then return -1 end

    for index, cell in pairs(cells) do
        if cellCurrent == cell and cellOwner == nil then

            local housePrice = CellGetPrice(cellCurrent)
            if housePrice == -1 then
                housePrice = Config.RealEstate.basePrice
            end

            if goldAmount < housePrice then
                message = color.Crimson .. "You need at least " .. tostring(housePrice) .. " " .. goldCurrencyName .. ".\n"
                sendMessage = true
            else
                message = color.MediumSpringGreen .. "Welcome home, " .. player.name .. ".\n"
                CellSetOwner(cellCurrent, player)
                GoldSetAmount(player.name, (goldAmount - housePrice))

                sendMessage = true
            end
        end
    end

    message = message .. color.Default
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


function CellLockPlayerCell(player)
    local message = ""
    local playerCell = CellGetPlayerCell(player)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n"
    else
        storage[playerCell].isUnlocked = false
        message = color.MediumSpringGreen .. playerCell .. " has been locked.\n"
    end

    message = message .. color.Default
    player:message(message, false)
end


function CellUnlockPlayerCell(player)
    local playerCell = CellGetPlayerCell(player)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n"
    else
        storage[playerCell].isUnlocked = false
        message = color.Orange .. playerCell .. " has been unlocked. Be careful.\n"
    end

    message = message .. color.Default
    player:message(message, false)
end


function CellShowPlayerCellGUI(player)
    local message = "#FF8C00Real estate system#FFFFFF"
    local buttons = "Close Window;Add Guest;Remove Guest;Guest list;Lock;Unlock"

    player:getGUI():customMessageBox(234, message, buttons)
end


function CellGetLockState(cell)
    if storage[cell] == nil then
        return false
    end

    return storage[cell].isUnlocked
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
    storage[cell].isUnlocked = false
    storage[cell].lastVisit = os.time()
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function GoldGetCurrencyName()
    if Config.RealEstate.useVirtualSeptims == true then
        return Config.RealEstate.nameCurrencyRegular
    else
        return Config.RealEstate.nameCurrencyVirtual
    end
end


function GoldGetAmount(player)
    if Config.RealEstate.useVirtualSeptims == true then
        return Data.VirtualSeptims.Get(player.name)
    end

    -- Todo: else return gold amount from inventory
    return 1000000
end


function GoldSetAmount(player, gold)
    if Config.RealEstate.useVirtualSeptims == true then
        Data.VirtualSeptims.Set(player, gold)
    else
        -- Todo: set gold in inventory
    end
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
        message = color.Crimson .. "You do not own a house yet.\n"
    else
        if GuestListCheck(playerCell, guestName) then
            message = color.Orange .. guestName .. " is already on your guest list.\n"
        else
            if storage[playerCell].guestList == nil then
                storage[playerCell].guestList = {}
            end

            table.insert(storage[playerCell].guestList, guestName)
            message = color.MediumSpringGreen .. guestName .. " is now considered a guest.\n"
            JsonInterface.save(getDataFolder() .. "storage.json", storage)
        end
    end

    message = message .. color.Default
    player:message(message, false)
    return true
end


function GuestListRemove(player, guestName)
    local message = ""
    local playerCell = CellGetPlayerCell(player)

    guestName = string.lower(guestName)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n"
    else
        if GuestListCheck(playerCell, guestName) then
            for index, item in pairs(storage[playerCell].guestList) do
                if item == string.lower(guestName) then
                    table.remove(storage[playerCell].guestList, index)
                end
            end
            message = color.MediumSpringGreen .. guestName .. " is no longer welcome in your house.\n"
            JsonInterface.save(getDataFolder() .. "storage.json", storage)
        else
            message = color.Orange .. guestName .. " is not on your guest list.\n"
        end
    end

    message = message .. color.Default
    player:message(message, false)
    return true
end


function GuestListShow(player)
    local message = ""
    local sendMessage = false
    local playerCell = CellGetPlayerCell(player)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n"
        sendMessage = true
    else
        local guestList = GuestListGetList(playerCell)

        if guestList[1] == nil then
            message = color.Crimson .. "Your guest list is empty.\n"
            sendMessage = true
        else
            message = message .. color.Orange .. "Guests of " ..  playerCell .. "\n\n"
            for index, item in pairs(guestList) do
                message = message .. item .. "\n"
            end
            player:getGUI():customMessageBox(234, message, "Close")
        end
    end

    message = message .. color.Default
    if sendMessage == true then
        player:message(message, false)
    end

    return true
end


function WarpHome(player)
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


Event.register(Events.ON_GUI_ACTION, function(player, id, data)
                   if id == 232 then
                       if tonumber(data) == 1 then
                           CellBuy(player)
                       end
                   elseif id == 233 then
                       if tonumber(data) == 1 then
                           local cell = CellGetPlayerCell(player)
                           CellRelease(cell)
                           CellBuy(player)
                       end
                   elseif id == 234 then
                       if tonumber(data) == 1 then
                           player:getGUI():inputDialog(235, "Add guest")
                       elseif tonumber(data) == 2 then
                           player:getGUI():inputDialog(236, "Remove guest")
                       elseif tonumber(data) == 3 then
                           GuestListShow(player)
                       elseif tonumber(data) == 4 then
                           CellLockPlayerCell(player)
                       elseif tonumber(data) == 5 then
                           CellUnlockPlayerCell(player)
                       end
                   elseif id == 235 then
                       GuestListAdd(player, data)
                   elseif id == 236 then
                       GuestListRemove(player, data)
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
                   WarpHome(player)
end)


Event.register(Events.ON_POST_INIT, function()
                   cellMonitorLastVisitTimer = TimerCtrl.create(CellMonitorLastVisit, 300000, { cellMonitorLastVisitTimer })
                   cellMonitorLastVisitTimer:start()

                   if Config.RealEstate.useVirtualSeptims == true then
                       local hit = false

                       for index, mod in pairs(Data.Core.loadedMods) do
                           if mod == "VirtualSeptims" then
                               hit = true
                           end
                       end

                       if hit == false then
                           logAppend(Log.LOG_ERROR, "useVirtualSeptims enabled but mod not installed.\n")
                           stopServer(-1)
                       end
                   end
end)


CommandController.registerCommand("house", CommandHandler, color.Salmon .. "/house help" .. color.Default .. " - Real estate system.")
