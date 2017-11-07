-- TES3MP RealEstate -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Config.RealEstate = import(getModFolder() .. "config.lua")


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
    local message      = ""
    local sendMessage  = false
    local cellCurrent  = player:getCell().description
    local cellOwner    = CellGetOwner(cellCurrent)
    local cells       = CellGetList()
    local playerName   = string.lower(player.name)

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

                local playerCell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)
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


function CellBuy(player)
    local message     = ""
    local sendMessage = false
    local cellCurrent = player:getCell().description
    local cellOwner   = CellGetOwner(cellCurrent)
    local cells      = CellGetList()
    --local playerGold  = 0
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
                local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. cellCurrent .. ".txt", "w+")
                if f ~= nil then
                    message = color.MediumSpringGreen .. "Welcome home, " .. player.name .. ".\n" .. color.Default
                    Data.UserConfig.SetValue(string.lower(player.name), Config.RealEstate.configKeyword, cellCurrent)
                    f:write(string.lower(player.name))
                    --Players[pid].data.inventory[goldIndex].count = playerGold - housePrice
                    --Players[pid]:Save()
                    --Players[pid]:LoadInventory()
                    --Players[pid]:LoadEquipment()
                    f:close()
                    sendMessage = true
                end
            end
        end
    end

    if sendMessage == true then
        player:message(message, false)
    end

    return 0
end


function CellRelease(cell)
    local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. cell .. ".txt", "w+")
    if f ~= nil then
        f:close()
    end
end


function Portkey(player)
    if player:getInventory():hasItemEquipped(string.lower(Config.RealEstate.portkeyRefId)) and Config.RealEstate.portkey == true then
        player:message("true\n", false)
        local message = ""
        local sendMessage = false
        local playerName = string.lower(player.name)
        local playerCell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)

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
    local cellOwner

    local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. cell .. ".txt", "r")
    if f ~= nil then
        cellOwner = f:read()
        f:close()
        return cellOwner
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


function GuestListGetList(cell)
    local guestList = {}
    local tmp = {}

    local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. cell .. ".txt", "r")
    if f ~= nil then
        for line in f:lines() do
            table.insert(tmp, line)
        end
        f:close()
    end
    table.remove(tmp, 1)

    if tmp[1] ~= nil then
        for substr in string.gmatch(tmp[1], '([^:]+)') do
            table.insert(guestList, substr)
        end
    else
        table.insert(guestList, nil)
    end

    return guestList
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
    local playerCell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
    else
        if GuestListCheck(playerCell, guestName) then
            message = color.Orange .. guestName .. " is already on your guest list.\n" .. color.Default
        else
            local guestList = GuestListGetList(playerCell)

            if guestList[1] == nil then
                table.remove(guestList, 1)
            end
            table.insert(guestList, guestName)

            local fcontent = string.lower(player.name) .. "\n"
            for index, item in pairs(guestList) do
                fcontent = fcontent .. item .. ":"
            end

            local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. playerCell .. ".txt", "w+")
            if f ~= nil then
                message = color.MediumSpringGreen .. guestName .. " is now considered a guest.\n" .. color.Default
                f:write(fcontent)
                f:close()
            end
        end
    end

    player:message(message, false)
    return true
end


function GuestListRemove(player, guestName)
    local message = ""
    local playerCell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)

    guestName = string.lower(guestName)

    if playerCell == nil then
        message = color.Crimson .. "You do not own a house yet.\n" .. color.Default
    else
        if GuestListCheck(playerCell, guestName) then
            local guestList = GuestListGetList(playerCell)

            local fcontent =  string.lower(player.name) .. "\n"
            for index, item in pairs(guestList) do
                if item ~= guestName then
                    fcontent = fcontent .. item .. ":"
                end
            end

            local f = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. playerCell .. ".txt", "w+")
            if f ~= nil then
                message = color.MediumSpringGreen .. guestName .. " is no longer welcome in your house.\n" .. color.Default
                f:write(fcontent)
                f:close()
            end
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
    local playerCell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)

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


Event.register(Events.ON_GUI_ACTION, function(player, id, button)
                   if id == 232 then
                       if tonumber(button) == 1 then
                           CellBuy(player)
                       end
                   end
                   if id == 233 then
                       if tonumber(button) == 1 then
                           local cell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)
                           CellRelease(cell)
                           CellBuy(player)
                       end
                   end
end)


CommandController.registerCommand("house", CommandHandler, color.Salmon .. "/house help" .. color.Default .. " - Real estate system.")
