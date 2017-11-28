-- TES3MP IrcBridge -*-lua-*-
-- "THE BEER-WARE LICENCE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
require("irc")


Config.IrcBridge = import(getModFolder() .. "config.lua")

local timer
local lastMessage = ""
local s = irc.new { nick = Config.IrcBridge.nick }

s:connect(Config.IrcBridge.server)
s:sendChat("NickServ", "identify " .. Config.IrcBridge.nickservPassword)
s:join(Config.IrcBridge.channel)


function RecvMessage()
    s:think()
    s:hook("OnChat", function(user, channel, message)
               if lastMessage ~= message then
                   user.nick = string.gsub(user.nick, Config.IrcBridge.nickFilter, "")
                   Players.for_each(function(player)
                           player:message(color.GreenYellow .. user.nick .. color.Default .. ": " .. message .. "\n", false)
                   end)
                   lastMessage = message
               end
    end)
    timer:start()
end


function SendMessage(message)
    s:sendChat(Config.IrcBridge.channel, message)
    s:think()
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   local message = player.name .. " joined the server\n"
                   SendMessage(message)

                   return true
end)


Event.register(Events.ON_PLAYER_DEATH, function(player, deathReason)
                   local reason = ": "
                   if deathReason == "suicide" then
                       reason = " commited suicide"
                   end

                   local message = player.name .. reason .. "\n"
                   SendMessage(message)
end)


Event.register(Events.ON_PLAYER_DISCONNECT, function(player)
                   local message = player.name .. " left the server\n"
                   SendMessage(message)
end)


Event.register(Events.ON_PLAYER_LEVEL, function(player)
                   if player.level > 1 then
                       local message = player.name .. " reached level " .. player.level .. "\n"
                       SendMessage(message)
                   end
end)


Event.register(Events.ON_POST_INIT, function()
                   timer = TimerCtrl.create(RecvMessage, 1000, { timer })
                   timer:start()
end)


Event.register(Events.ON_PLAYER_SENDMESSAGE, function(player, message)
                   SendMessage(string.sub(message, 8))
end)
