-- TES3MP IrcBridge -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
require("irc")


Config.IrcBridge = dofile(getModFolder() .. "config.lua")

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
                           player:message(color.GreenYellow .. user.nick .. color.Default .. ": " .. message .. "\n")
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


Event.register(Events.ON_POST_INIT, function()
                   timer = TimerCtrl.create(RecvMessage, 1000, {timer})
                   timer:start()
end)


Event.register(Events.ON_PLAYER_SENDMESSAGE, function(player, message)
                   SendMessage(string.sub(message, 8))
end)
