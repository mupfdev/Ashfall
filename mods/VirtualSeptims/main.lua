-- TES3MP VirtualSeptims -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
JsonInterface = require("jsonInterface")
Config.VirtualSeptims = import(getModFolder() .. "config.lua")


local accountCheckLastVisitTimer
local accountGenerateSeptimsTimer
local storage = JsonInterface.load(getDataFolder() .. "storage.json")


function Init(player)
    if AccountCheckStatus(player.name) == false then
        AccountOpen(player.name)
        message = color.MediumSpringGreen .. "A new bank account has been opened.\n" .. color.Default
        player:message(message, false)
    end

    AccountUpdateLastVisit(player.name)
end


function CommandHandler(player, args)
    if args[1] == "show" then
        AccountShow(player)
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


function AccountCheckLastVisit()
    local timeCurrent = os.time()

    for index, item in pairs(storage) do
        if storage[index].lastVisit ~= nil then
            if timeCurrent - storage[index].lastVisit >= (Config.VirtualSeptims.maxAbandonTime * 3600) then
                AccountClose(index)
                local message = index .. "'s bank account has been closed.\n"
                logMessage(Log.LOG_INFO, message)
            end
        end
    end

    accountCheckLastVisitTimer:start()
end


function AccountCheckStatus(playerName)
    if storage[string.lower(playerName)] == nil then
        print("false\n")
        return false
    else
        print("true\n")
        return true
    end
end


function AccountOpen(playerName)
    storage[string.lower(playerName)] = {}
    storage[string.lower(playerName)].septims = 0
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function AccountClose(playerName)
    storage[string.lower(playerName)] = {}
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function AccountUpdateLastVisit(playerName)
    storage[string.lower(playerName)].lastVisit = os.time()
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


function AccountGenerateSeptims()
    Players.for_each(function(player)
            -- if not AFK
            local septimsCurrent = AccountGetSeptims(player.name)
            septimsCurrent = math.ceil(septimsCurrent + Config.VirtualSeptims.septimsPerMinute)
            AccountSetSeptims(player.name, septimsCurrent)
    end)

    accountGenerateSeptimsTimer:start()
end


function AccountGetSeptims(playerName)
    local septimsCurrent = storage[string.lower(playerName)].septims

    if septimsCurrent ~= nil then
        return septimsCurrent
    else
        return 0
    end
end


function AccountSetSeptims(playerName, count)
    storage[string.lower(playerName)].septims = count
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Init(player)
                   return true
end)


Event.register(Events.ON_POST_INIT, function()
                   accountCheckLastVisitTimer = TimerCtrl.create(AccountCheckLastVisit, 300000, { accountCheckLastVisitTimer })
                   accountGenerateSeptimsTimer = TimerCtrl.create(AccountGenerateSeptims, 60000, { accountGenerateSeptimsTimer })
                   accountCheckLastVisitTimer:start()
                   accountGenerateSeptimsTimer:start()
end)


CommandController.registerCommand("bank", CommandHandler, color.Salmon .. "/bank help" .. color.Default .. " - Banking system.")
