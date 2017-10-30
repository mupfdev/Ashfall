-- userSettTES3MP UserConfig -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


local userConfigPath = getModFolder() .. "users" .. package.config:sub(1,1)


local tblUserConfig = {
    value    = nil,
    GetValue = Event.create()
    SetValue = Event.create()
}
Data["UserConfig"] = tblUserConfig


function Init(playerName)
    local config = userConfigPath .. string.lower(playerName) .. ".cfg"

    local f = io.open(config, "r")
    if f == nil then
        f = io.open(config, "w+")
        f:close()
    end
end


function GetValue(playerName, keyword)
    local settings = {}

    settings = ReadSettings(string.lower(playerName))
    if settings == nil then return -1 end

    local i   = 0
    local hit = false
    for index, item in pairs(settings) do
        for substr in string.gmatch(item, '([^=]+)') do
            if substr == keyword then hit = true end
            if hit == true and i %2 ~= 0 then return substr end
            i = i + 1
        end
    end

    return -2
end


function SetValue(playerName, keyword, value)
    local settings = {}
    local tmp      = {}

    tmp = ReadSettings(string.lower(playerName))
    if tmp == nil then return -1 end

    local i = 0
    for index, item in pairs(tmp) do
        for substr in string.gmatch(item, '([^=]+)') do
            if substr ~= keyword and i %2 == 0 then
                settings[index] = item
            end
            i = i + 1
        end
    end

    table.insert(settings, keyword .. "=" .. value)
    WriteSettings(playerName, settings)

    return 0
end


function ReadSettings(playerName)
    local config   = userConfigPath .. string.lower(playerName) .. ".cfg"
    local settings = {}

    local f = io.open(config, "r")
    if f == nil then
        return nil
    else
        for line in f:lines() do
            table.insert(settings, line)
        end
        f:close()
        return settings
    end

    return 0
end


function WriteSettings(playerName, settings)
    local config = userConfigPath .. string.lower(playerName) .. ".cfg"

    local f = io.open(config, "w+")
    if f == nil then
        return -1
    else
        for index, item in pairs(settings) do
            f:write(item .. "\n")
        end
        f:close()
        return 0
    end
end


Event.register(Events.ON_PLAYER_CONNECT, function(player)
                   Init(player.name)
                   return true
end)


Event.register(Data.UserConfig.SetValue, function(data)
                   if #data >= 3 then
                       SetValue(data[1], data[2], data[3])
                   end
end)


Event.register(Data.UserConfig.GetValue, function(data)
                   if #data >= 2 then
                       Data.UserConfig.value = GetValue(data[1], data[2])
                   end
end)
