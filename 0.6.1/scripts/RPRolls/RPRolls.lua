--Setup instructions:
-- 1. Place this file in \mp-stuff\scripts\
-- 2. Add [ RPRolls = require("RPRolls") ] (without the square brackets) at the top of server.lua
-- 3. Add [ elseif cmd[1] == "roll" then RPRolls.doRoll(pid, playerName, cmd[2]) ] (without the square brackets)
-- after last "elseif cmd[1] == ..." statement in server.lua
-- 4. Add [ /roll <attribute> - perform <attribute> - 100 roll" ] (without square brackets) at the end of "local helptext = ..."

require("color")

Methods = {}

local attributeStrength         =  0
local attributeIntelligence     =  1
local attributeWillpower        =  2
local attributeAgility          =  3
local attributeSpeed            =  5
local attributeEndurance        =  4
local attributePersonality      =  6
local attributeLuck             =  7

local skillBlock       =  0
local skillArmorer     =  1
local skillMediumArmor =  2
local skillHeavyArmor  =  3
local skillBlunt       =  4
local skillLongBlade   =  5
local skillAxe         =  6
local skillSpear       =  7
local skillAthletics   =  8
local skillEnchant     =  9
local skillDestruction = 10
local skillAlteration  = 11
local skillIllusion    = 12
local skillConjuration = 13
local skillMysticism   = 14
local skillRestoration = 15
local skillAlchemy     = 16
local skillUnarmored   = 17
local skillSecurity    = 18
local skillSneak       = 19
local skillAcrobatics  = 20
local skillLightArmor  = 21
local skillShortBlade  = 22
local skillMarksman    = 23
local skillMercantile  = 24
local skillSpeechcraft = 25
local skillHandToHand  = 26


Methods.doRoll = function(pid, playerName, rollcheck)
    local rollCheckID
    local message
    local rollCheckValue
    local roll
    local maxroll
    local isAttribute
    if rollcheck == "strength" then
        rollCheckID = attributeStrength
        isAttribute = true
    elseif rollcheck == "intelligence" then
        rollCheckID = attributeIntelligence
        isAttribute = true
    elseif rollcheck == "willpower" then
        rollCheckID = attributeWillpower
        isAttribute = true
    elseif rollcheck == "endurance" then
        rollCheckID = attributeSpeed
        isAttribute = true
    elseif rollcheck == "agility" then
        rollCheckID = attributeAgility
        isAttribute = true
    elseif rollcheck == "speed" then
        rollCheckID = attributeEndurance
        isAttribute = true
    elseif rollcheck == "personality" then
        rollCheckID = attributePersonality
        isAttribute = true
    elseif rollcheck == "luck" then
        rollCheckID = attributeLuck
        isAttribute = true
    elseif rollcheck == "block" then
        rollCheckID = skillBlock
        isAttribute = false
    elseif rollcheck == "armorer" then
        rollCheckID = skillArmorer
        isAttribute = false
    elseif rollcheck == "mediumarmor" then
        rollCheckID = skillMediumArmor
        isAttribute = false
    elseif rollcheck == "heavyarmor" then
        rollCheckID = skillHeavyArmor
        isAttribute = false
    elseif rollcheck == "blunt" then
        rollCheckID = skillBlunt
        isAttribute = false
    elseif rollcheck == "longblade" then
        rollCheckID = skillLongBlade
        isAttribute = false
    elseif rollcheck == "axe" then
        rollCheckID = skillAxe
        isAttribute = false
    elseif rollcheck == "spear" then
        rollCheckID = skillSpear
        isAttribute = false
    elseif rollcheck == "athletics" then
        rollCheckID = skillAthletics
        isAttribute = false
    elseif rollcheck == "enchant" then
        rollCheckID = skillEnchant
        isAttribute = false
    elseif rollcheck == "destruction" then
        rollCheckID = skillDestruction
        isAttribute = false
    elseif rollcheck == "alteration" then
        rollCheckID = skillAlteration
        isAttribute = false
    elseif rollcheck == "illusion" then
        rollCheckID = skillIllusion
        isAttribute = false
    elseif rollcheck == "conjuration" then
        rollCheckID = skillConjuration
        isAttribute = false
    elseif rollcheck == "mysticism" then
        rollCheckID = skillMysticism
        isAttribute = false
    elseif rollcheck == "restoration" then
        rollCheckID = skillRestoration
        isAttribute = false
    elseif rollcheck == "alchemy" then
        rollCheckID = skillAlchemy
        isAttribute = false
    elseif rollcheck == "unarmored" then
        rollCheckID = skillUnarmored
        isAttribute = false
    elseif rollcheck == "security" then
        rollCheckID = skillSecurity
        isAttribute = false
    elseif rollcheck == "sneak" then
        rollCheckID = skillSneak
        isAttribute = false
    elseif rollcheck == "acrobatics" then
        rollCheckID = skillAcrobatics
        isAttribute = false
    elseif rollcheck == "lightarmor" then
        rollCheckID = skillLightArmor
        isAttribute = false
    elseif rollcheck == "shortblade" then
        rollCheckID = skillShortBlade
        isAttribute = false
    elseif rollcheck == "marksman" then
        rollCheckID = skillMarksman
        isAttribute = false
    elseif rollcheck == "mercantile" then
        rollCheckID = skillMercantile
        isAttribute = false
    elseif rollcheck == "speechcraft" then
        rollCheckID = skillSpeechcraft
        isAttribute = false
    elseif rollcheck == "handtohand" then
        rollCheckID = skillHandToHand
        isAttribute = false
    else rollCheckID = 27
    end
    if rollCheckID ~= 27 then
        if isAttribute == true then
            rollCheckValue = tes3mp.GetAttributeBase(pid, rollCheckID)
        else
            rollCheckValue = tes3mp.GetSkillBase(pid, rollCheckID)
        end
            maxroll = 100-rollCheckValue
            if maxroll < 1 then maxroll = 1
            end
            math.random()
            roll = math.random(0,maxroll) + rollCheckValue
            if roll > 100 then roll = 100
            end
            message = color.ForestGreen .. playerName .. " rolled " .. roll .. " on " .. rollcheck .. " check.\n" .. color.Default
        local cellDescription = Players[pid].data.location.cell
        if myMod.IsCellLoaded(cellDescription) == true then
            for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do
                tes3mp.SendMessage(visitorPid, message, false)
            end
        end
    else
        message = color.ForestGreen .. "Invalid attribute/skill.\n" .. color.Default
    	tes3mp.SendMessage(pid, message, false)
    end

end


return Methods
