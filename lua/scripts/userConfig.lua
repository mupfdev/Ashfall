-- userConfig.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


Methods = {}


local userConfigPath = "/home/tes3mp/server/keepers/user_config/"


Methods.Init = function(pid)
    local config   = userConfigPath .. string.lower(tes3mp.GetName(pid)) .. ".txt"

    local f = io.open(config, "r")
    if f == nil then
        f = io.open(config, "w+")
        f:close()
    end
end


Methods.GetValue   = function(username, keyword)
    local config   = userConfigPath .. string.lower(username) .. ".txt"
    local settings = {}
    local tmp      = ""

    local f = io.open(config)
    if f == nil then
        return -1
    else
        for line in f:lines() do
            tmp = string.gsub(line, " ", "")
            table.insert(settings, tmp)
        end
        f:close()
    end

    local i   = 0
    local hit = false
    for index, item in pairs(settings) do
        for substr in string.gmatch(item, '([^=]+)') do
            if substr == keyword then hit = true end
            if hit == true and i %2 ~= 0 then return substr end

            i = i + 1
        end
    end

    return -1
end


return Methods
