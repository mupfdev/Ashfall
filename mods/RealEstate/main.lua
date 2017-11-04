-- TES3MP RealEstate -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Config.RealEstate = import(getModFolder() .. "config.lua")


function CellCheck(player)
    local message      = ""
    local sendMessage  = false
    local cellCurrent  = player:getCell().description
    local cellPrevious = "" -- TODO -- local previousCell = Players[pid].data.location.cell
    local cellOwner    = GetCellOwner(cellCurrent)
    local houses       = GetHouses()
    local playerName   = string.lower(player.name)

    if houses == -1 then return -1 end

    for index, cell in pairs(houses) do
        if cellCurrent == cell then
            if cellOwner ~= nil then
                if playerName ~= cellOwner then
                    message = color.Crimson .. "This house is owned by " .. cellOwner .. ".\n" .. color.Default
                    if previousCell ~= cellCurrent then
                        WarpToPreviousPosition(player)
                    else
                        WaroToSeydaNeen(player)
                    end
                    sendMessage = true
                elseif playerName == cellOwner or WhitelistCheck(cell, player) then
                    message = color.MediumSpringGreen .. "Welcome home, " .. playerName .. ".\n" .. color.Default
                    sendMessage = true
                end
            else
                local housePrice = GetHousePrice(cellCurrent)
                if housePrice == -1 then
                    housePrice = Config.RealEstate.basePrice
                end

                local playerHouse = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)
                if playerHouse == nil then
                    player:getGUI():customMessageBox(231, "This house is for sale. You can buy it for " .. housePrice .. " Septims.\n", "Close;Buy House")
                else
                    player:getGUI():customMessageBox(232, "This house is for sale, but you already own " .. playerHouse .. ".\n", "Close;Release and Buy (" .. housePrice .. ")")
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
    local cellOwner   = GetCellOwner(cellCurrent)
    local houses      = GetHouses()
    --local playerGold  = 0
    local playerGold  = 1000000
    --local goldIndex

    if houses == -1 then return -1 end

    --if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", "gold_001", true) then
    --    goldIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", "gold_001")
    --    playerGold = Players[pid].data.inventory[goldIndex].count
    --end

    for index, cell in pairs(houses) do
        if cellCurrent == cell and cellOwner == nil then

            local housePrice = GetHousePrice(cellCurrent)
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


--[[
function Portkey(pid)
    if tes3mp.HasItemEquipped(pid, "iron fork") then
        local message     = ""
        local sendMessage = false
        local playerName  = string.lower(tes3mp.GetName(pid))
        local playerHouse = userConfig.GetValue(pid, configKeyword)

        if playerHouse == -1 or playerHouse == "false" then
            message = message .. color.Crimson .. "You do not own a house yet.\n" .. color.Default
            sendMessage = true
        else
            tes3mp.UnequipItem(pid, 16)
            tes3mp.SendEquipment(pid)
            tes3mp.SetCellll(pid, playerHouse)
            tes3mp.SendCell(pid)
        end

        if sendMessage == true then
            tes3mp.SendMessage(pid, message, false)
        end
    end
end
---]]


function GetCellOwner(cell)
    local cellOwner

    local fcell = io.open(getDataFolder() .. "cells" .. package.config:sub(1, 1) .. cell .. ".txt", "r")
    if fcell ~= nil then
        cellOwner = fcell:read()
        fcell:close()
        return cellOwner
    end

    return nil
end


function GetHousePrice(cell)
    local price = 0
    local tmp   = {}
    local hit   = false

    local flist = io.open(getDataFolder() .. "houses.txt", "r")
    if flist ~= nil then
        for line in flist:lines() do
            table.insert(tmp, line)
        end
        flist:close()

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


function GetHouses()
    local tmp = {}
    local houses = {}

    local flist = io.open(getDataFolder() ..  package.config:sub(1, 1) .. "houses.txt", "r")
    if flist ~= nil then
        for line in flist:lines() do
            table.insert(tmp, line)
        end
        flist:close()

        for index, item in pairs(tmp) do
            for substr in string.gmatch(item, '([^:]+)') do
                table.insert(houses, substr)
                break
            end
        end

        return houses
    end

    return -1
end


function WhitelistCheck(cell, player)


    return false
end


function WarpToPreviousPosition(player)
    player:message("WaroToPreviousPosition()\n", false)
    --local posx = tes3mp.GetPreviousCellPosX(pid)
    --local posy = tes3mp.GetPreviousCellPosY(pid)
    --local posz = tes3mp.GetPreviousCellPosZ(pid)

    --tes3mp.SetCell(pid, "")
    --tes3mp.SetPos(pid, posx, posy, posz)
    --tes3mp.SendCell(pid)
    --tes3mp.SendPos(pid)
end


-- https://i.imgur.com/FCGYYqH.jpg
-- It's a meme, not a typo.
function WaroToSeydaNeen(player)
    player:message("WaroToSeydaNeen()\n", false)
    --tes3mp.SetCell(pid, "-2, -9")
    --tes3mp.SendCell(pid)
end


--[[
function PlayerHasItemEquipped(pid, list)
    local c = 0
    local i = 1

    while list[i] ~= nil do
        if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
        i = i + 1
    end

    if c > 0 then return true else return false end
end
---]]


Event.register(Events.ON_PLAYER_CELLCHANGE, function(player)
                   CellCheck(player)
end)


Event.register(Events.ON_GUI_ACTION, function(player, id, button)
                   if id == 231 then
                       if tonumber(button) == 1 then
                           CellBuy(player)
                       end
                   end
                   if id == 232 then
                       if tonumber(button) == 1 then
                           local cell = Data.UserConfig.GetValue(string.lower(player.name), Config.RealEstate.configKeyword)
                           CellRelease(cell)
                           CellBuy(player)
                       end
                   end
end)
