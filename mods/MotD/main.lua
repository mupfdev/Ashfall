-- TES3MP MotD -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Config.MotD = import(getModFolder() .. "config.lua")


function Show(player, onConnect)
    onConnect = onConnect or false

    local f = io.open(getDataFolder() .. "motd.txt", "r")
    if f == nil then return false end

    local message = f:read("*a")
    f:close()

    message = message .. color.MediumSpringGreen .. os.date("\nCurrent time: %A %I:%M %p") .. color.Default .. "\n"

    if onConnect == true then
        local userConfig = Data.UserConfig.GetValue(string.lower(player.name), Config.MotD.configKeyword)

        if userConfig == nil then
            Data.UserConfig.SetValue(string.lower(player.name), Config.MotD.configKeyword, "1")
            userConfig = "1"
        end

        if userConfig == "1" then
            if player.level == 1 and player.levelProgress == 0 then
                player:getGUI():customMessageBox(211, message, "OK;Disable MotD")
            else
                player:getGUI():customMessageBox(212, message, "OK;" .. Config.MotD.spawnLocation .. ";Disable MotD")
            end
        end
    else
        player:getGUI():customMessageBox(213, message, "OK")
    end

    return true
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Show(player, true)
                   return true
end)


Event.register(Events.ON_GUI_ACTION, function(player, id, data)
                   if id == 211 then
                       if tonumber(data) == 1 then
                           Data.UserConfig.SetValue(string.lower(player.name), Config.MotD.configKeyword, "0")
                       end
                   end

                   if id == 212 then
                       if tonumber(data) == 1 then
                           player:getCell().description = Config.MotD.spawnLocation
                       end
                       if tonumber(data) == 2 then
                           Data.UserConfig.SetValue(string.lower(player.name), Config.MotD.configKeyword, "0")
                       end
                   end

                   if id == 213 then
                       if tonumber(data) == 0 then
                           Data.UserConfig.SetValue(string.lower(player.name), Config.MotD.configKeyword, "1")
                       end
                   end
end)


CommandController.registerCommand("motd", Show, color.Salmon .. "/motd".. color.Default .. " - Show message of the day.")
