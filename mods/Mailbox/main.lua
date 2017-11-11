-- TES3MP Mailbox -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
require("valid-email")


Config.Mailbox = import(getModFolder() .. "config.lua")


function Init(player)
    local message
    local mbox = getDataFolder() .. "users" .. package.config:sub(1, 1) .. string.lower(player.name) .. ".txt"

    local f = io.open(mbox, "r")
    if f == nil then
        f = io.open(mbox, "w+")
        f:write(Config.Mailbox.welcomeMessage)
        f:close()
        message = color.MediumSpringGreen .. "A new mailbox has been initialised.\n" .. color.Default
        player:message(message, false)
    else
        f:close()
    end
end


function CommandHandler(player, args)
    if #args < 1 then
        if InboxGUI(player) == false then
            return false
        end
        return true
    end

    if args[1] == "check" then
        if InboxCheck(player) == false then
            return false
        end
        return true
    end

    if args[1] == "delete" then
        if args[2] == nil then
            return false
        end
        if MessageDelete(player, args[2]) == false then
            return false
        end
        return true
    end

    if args[1] == "read" then
        if args[2] == nil or args[3] == true then
            return false
        end
        if MessageRead(player, args[2]) == false then
            return false
        end
        return true
    end

    if args[1] == "send" then
        if args[3] == nil then
            return false
        end
        if MessageSend(player, args[2], args[3]) == false then
            return false
        end
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

    player:getGUI():customMessageBox(221, message, "Close")
end


function InboxCheck(player)
    local message
    local mbox = getDataFolder() .. "users" .. package.config:sub(1, 1) .. string.lower(player.name) .. ".txt"
    local c = 0

    local f = io.open(mbox, "r")
    if f == nil then
        return false
    end
    for _ in io.lines(mbox) do c = c + 1 end
    f:close()

    message = color.MediumSpringGreen .. "You have " .. tostring(c) .. " message"
    if c > 1 or c == 0 then message = message .. "s" end

    message = message .. " in your Inbox.\n" .. color.Default
    player:message(message, false)

    return true
end


function InboxGUI(player)
    local message

    message = MessageRead(player, 0, true)
    if message ~= false then
        player:getGUI():customMessageBox(222, color.Orange .. "Messages\n\n" .. color.Default .. message, "Close;Delete all")
    else
        InboxCheck(player)
    end

    return true
end


function MessageDelete(player, id)
    if tonumber(id) == nil then
        return false
    end
    id = tonumber(id)
    if not math.floor(id) then
        return false
    end

    local message = ""
    local mbox = getDataFolder() .. "users" .. package.config:sub(1, 1) .. string.lower(player.name) .. ".txt"
    local line = {}
    local content = {}
    local c = 0
    local i = 0

    local f = io.open(mbox, "r")
    if f == nil then
        return false
    end
    for _ in io.lines(mbox) do c = c + 1 end

    -- Delete all messages.
    if id == 0 then
        f = io.open(mbox, "w+")
        f:close()
        message = color.MediumSpringGreen .. "All messages have been deleted.\n"
    else
        -- Delete specific message.
        if id > c or id < 0 then
            message = message .. color.Crimson .. "Message " .. tostring(id) .. " does not exist.\n" .. color.Default
        else
            f = io.open(mbox, "r")
            while true do
                line = f:read()
                if line == nil then break end
                content[i] = line .. "\n"
                i = i + 1
            end
            f:close()
            table.remove(content, id - 1)

            f = io.open(mbox, "w+")
            for i = 0, c - 2 do f:write(content[i]) end
            f:close()

            message = message .. color.MediumSpringGreen .. "Message " .. tostring(id) .. " has been deleted.\n" .. color.Default
        end
    end

    player:message(message, false)
    return true
end


function MessageRead(player, id, returnMessage)
    returnMessage = returnMessage or false

    if tonumber(id) == nil then
        return false
    end
    id = tonumber(id)
    if not math.floor(id) then
        return false
    end

    local message = ""
    local mbox = getDataFolder() .. "users" .. package.config:sub(1, 1) .. string.lower(player.name) .. ".txt"
    local line
    local c = 0
    local i = 0

    local f = io.open(mbox, "r")
    if f == nil then
        return false
    end
    for _ in io.lines(mbox) do c = c + 1 end
    if c < 1 then
        return false
    end

    -- Show all messages at once.
    if id == 0 then
        while true do
            line = f:read()
            if line == nil then break end

            if i % 2 == 0 then
                message = message .. color.LightSalmon .. line .. "\n" .. color.Default
            else
                message = message .. color.LightSkyBlue .. line .. "\n" .. color.Default
            end
            i = i + 1
        end
    end
    -- Show specific message.
    if id > c or id < 0 then
        message = message .. color.Crimson .. "Message " .. tostring(id) .. " does not exist.\n" .. color.Default
    else
        i = 0
        for line in f:lines() do
            if i == id - 1 then
                message = message .. color.LightSalmon .. line .. "\n" .. color.Default
            end
            i = i + 1
        end
    end
    f:close()

    player:message(message, false)

    if returnMessage == true then
        return message
    else
        return true
    end
end


function MessageSend(player, user, text)
    local i = 0

    local mbox = getDataFolder() .. "users" .. package.config:sub(1, 1) .. string.lower(user) .. ".txt"
    local message = ""
    local err = 0
    local c = 0

    local f = io.open(mbox, "r")
    if f == nil then
        message = message .. color.Crimson .. user .. " does not have a mailbox yet.\n" .. color.Default
        err = err + 1
    else
        for _ in io.lines(mbox) do c = c + 1 end
        if c >= Config.Mailbox.messageLimit then
            message = message .. color.Crimson .. user .. "'s mailbox is full.\n" .. color.Default
            err = err + 1
        end
        f:close()
    end

    if err == 0 then
        if text == "" then
            message = color.Crimson .. "Message is empty.\n"
        else
            text = text .. " - " .. player.name .. "\n"
            f = io.open(mbox, "a")
            f:write(text)
            f:close()
            message = color.MediumSpringGreen .. "Message has been sent.\n"

            Players.for_each(function(receiver)
                    if string.lower(receiver.name) == string.lower(user) then
                        receiver:message(color.Cyan .. "You've got mail from  " .. player.name .. ".\n" .. color.Default, false)
                    end
            end)
        end
    end

    player:message(message, false)
    return true
end


-- E-Mail message forwarding not implemented yet.
function SetEmail(player, email)
    if tonumber(email) == 0 or validemail(email) == true then
        Data.UserConfig.SetValue(string.lower(player.name), Config.Mailbox.configKeyword, email)
        return true
    end

    return false
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Init(player)
                   InboxCheck(player)
                   return true
end)


Event.register(Events.ON_GUI_ACTION, function(player, id, data)
                   if id == 222 then
                       if tonumber(data) == 1 then
                           MessageDelete(player, 0)
                           InboxCheck(player)
                       end
                   end
end)


CommandController.registerCommand("mailbox", CommandHandler, color.Salmon .. "/mailbox help" .. color.Default .. " - Mailbox system.")
