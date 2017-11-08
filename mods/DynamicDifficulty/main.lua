-- TES3MP DynamicDifficulty -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Config.DynamicDifficulty = import(getModFolder() .. "config.lua")


function UpdateDifficulty(player, notify)
    notify = notify or true

    local difficulty
    local difficultyMin = Config.DynamicDifficulty.min
    local difficultyCap = Config.DynamicDifficulty.cap
    local levelEndGame  = Config.DynamicDifficulty.levelEndGame
    local levelCurrent  = player.level

    difficulty = difficultyMin + (levelCurrent * (difficultyCap - difficultyMin) / levelEndGame)
    difficulty = math.floor(difficulty)

    if difficulty < difficultyMin then
        difficulty = difficultyMin
    end

    if difficulty > difficultyCap then
        difficulty = difficultyCap
    end

    if player.level == 1 then
        difficulty = difficultyMin
    end

    if Config.DynamicDifficulty.notify == true and notify == true then
        player:message(color.Cyan .. "Difficulty is now set to " .. tostring(difficulty) .. ".\n" .. color.Default, false)
    end

    player:getSettings():setDifficulty(difficulty)
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   UpdateDifficulty(player, false)
                   return true
end)


Event.register(Events.ON_PLAYER_LEVEL, function(player)
                   UpdateDifficulty(player)
end)
