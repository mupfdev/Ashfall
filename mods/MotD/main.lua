-- TES3MP MotD -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


local motd = getModFolder() .. "motd.txt"


function Show(player, onConnect)
    onConnect = onConnect or false

    local userConfig
    local message

    local f = io.open(motd, "r")
    if f == nil then return false end

    message = f:read("*a")
    f:close()

    message = message .. color.MediumSpringGreen .. os.date("\nCurrent time: %A %I:%M %p") .. color.Default .. "\n"

    Event.raise(Data.UserConfig.GetValue, { player.name, "motd" })
    userConfig = Data.UserConfig.value

    if onConnect == true then
        if userConfig == "1" then
            player:getGUI():customMessageBox(1, message, "OK;Disable MotD")
        end
    else
        Event.raise(Data.UserConfig.SetValue, { player.name, "motd", "1" })
        player:getGUI():customMessageBox(2, message, "OK")
    end

    return true
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Show(player, true)
                   return true
end)


Event.register(Events.ON_GUI_ACTION, function(player, id, data)
                   if id == 1 then
                       if tonumber(data) == 1 then
                           Event.raise(Data.UserConfig.SetValue, { player.name, "motd", "0" })
                       end
                   end
end)


CommandController.registerCommand("motd", Show, color.Salmon .. "/motd".. color.Default .. " - Show message of the day.")
