-- realEstate.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Methods = {}


-- Add [ realEstate = require("realEstate") ] to the top of server.lua

-- Find "function OnPlayerCellChange(pid)" inside server.lua and add:
-- [ realEstate.CheckCell(pid) ]
-- directly underneath it.

-- Find "elseif cmd[1] == "difficulty" and admin then" inside server.lua and insert:
-- [ elseif cmd[1] == "claim" then realEstate.ClaimCell(pid) ]
-- directly above it.

-- Move 'player_houses.txt' into your 'real_estate' directory and make
-- sure the listed cells aren't affected by your cell reset routine (if
-- required). To add more houses, just add cell descriptions to the file
-- (one per line). To set specific price, add a colon followed by a number.
-- E.g. An Abandoned Shack:200000


local realEstatePath = "/path/to/real_estate/"
local basePrice = 500000


Methods.CheckCell = function(pid)
    local message      = ""
    local sendMessage  = false
    local playerHouses = {}
    local cellOwner    = nil
    local playerName   = string.lower(tes3mp.GetName(pid))
    local currentCell  = tes3mp.GetCell(pid)
    local previousCell = Players[pid].data.location.cell
    local housePrice

    cellOwner    = GetCellOwner(currentCell)
    playerHouses = GetPlayerHouses()
    if playerHouses == -1 then return -1 end

    for index, cell in pairs(playerHouses) do
        if currentCell == cell then
            if cellOwner ~= nil then
                if playerName ~= cellOwner then
                    message = color.Crimson .. "This house is owned by "
                    message = message .. cellOwner .. ".\n" .. color.Default
                    if previousCell ~= currentCell then
                        WarpToPreviousPosition(pid)
                    else
                        WaroToSeydaNeen(pid)
                    end
                    sendMessage = true
                else
                    message = color.MediumSpringGreen .. "Welcome home, "
                    message = message .. playerName .. ".\n" .. color.Default
                    sendMessage = true
                end
            else
                housePrice = GetHousePrice(currentCell)
                if housePrice == -1 then housePrice = basePrice end

                message = color.Yellow .. "This house is for sale. " .. "Enter /claim to buy it for "
                message = message .. housePrice .. " Septims.\n" .. color.Default
                sendMessage = true
            end
        end
    end

    if sendMessage == true then
        tes3mp.SendMessage(pid, message, false)
    end

    return 0
end


function Methods.ClaimCell(pid)
    local message      = ""
    local sendMessage  = false
    local playerHouses = {}
    local cellOwner    = nil
    local playerName   = string.lower(tes3mp.GetName(pid))
    local currentCell  = tes3mp.GetCell(pid)
    local playerGold   = 0
    local housePrice
    local goldIndex

    cellOwner    = GetCellOwner(currentCell)
    playerHouses = GetPlayerHouses()
    if playerHouses == -1 then return -1 end

    if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", "gold_001", true) then
        goldIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", "gold_001")
        playerGold = Players[pid].data.inventory[goldIndex].count
    end

    for index, cell in pairs(playerHouses) do
        if currentCell == cell and cellOwner == nil then

            housePrice = GetHousePrice(currentCell)
            if housePrice == -1 then housePrice = basePrice end

            if playerGold < housePrice then
                message = color.Crimson .. "You need at least " .. tostring(housePrice)
                message = message .. " Septims to buy this house.\n" .. color.Default
                sendMessage = true
            else
                local f = io.open(realEstatePath .. currentCell .. ".txt", "w+")
                if f ~= nil then
                    message = color.MediumSpringGreen .. "Welcome home, "
                    message = message .. playerName .. ".\n" .. color.Default

                    f:write(playerName)
                    Players[pid].data.inventory[goldIndex].count = playerGold - housePrice
                    Players[pid]:Save()
                    Players[pid]:LoadInventory()
                    Players[pid]:LoadEquipment()
                    f:close()
                    sendMessage = true
                end
            end
        end
    end

    if sendMessage == true then
        tes3mp.SendMessage(pid, message, false)
    end

    return 0
end


function GetCellOwner(cell)
    local cellOwner

    local fcell = io.open(realEstatePath .. cell .. ".txt", "r")
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

    local flist = io.open(realEstatePath .. "player_houses.txt", "r")
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


function GetPlayerHouses()
    local tmp = {}
    local playerHouses = {}

    local flist = io.open(realEstatePath .. "player_houses.txt", "r")
    if flist ~= nil then
        for line in flist:lines() do
            table.insert(tmp, line)
        end
        flist:close()

        for index, item in pairs(tmp) do
            for substr in string.gmatch(item, '([^:]+)') do
                table.insert(playerHouses, substr)
                break
            end
        end

        return playerHouses
    end

    return -1
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


-- https://i.imgur.com/FCGYYqH.jpg
function WaroToSeydaNeen(pid)
    tes3mp.SetCell(pid, "-2, -9")
    tes3mp.SendCell(pid)
end


return Methods
