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
local storage = JsonInterface.load(getDataFolder() .. "storage.json")


function Init(player)
    if storage[string.lower(player.name)].lastVisit == nil then
        storage[string.lower(player.name)] = {}
        storage[string.lower(player.name)].septims = 0
        message = color.MediumSpringGreen .. "A new bank account has been opened.\n" .. color.Default
        player:message(message, false)
    end

    storage[string.lower(player.name)].lastVisit = os.time()
    JsonInterface.save(getDataFolder() .. "storage.json", storage)
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
                storage[index] = {}
                JsonInterface.save(getDataFolder() .. "storage.json", storage)
                local message = index .. "'s bank account has been closed.\n"
                logMessage(LOG_INFO, message)
            end
        end
    end

    accountCheckLastVisitTimer:start()
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Init(player)
                   return true
end)


Event.register(Events.ON_POST_INIT, function()
                   accountCheckLastVisitTimer = TimerCtrl.create(AccountCheckLastVisit, 300000, { accountCheckLastVisitTimer })
                   accountCheckLastVisitTimer:start()
end)


CommandController.registerCommand("bank", CommandHandler, color.Salmon .. "/bank help" .. color.Default .. " - Banking system.")
