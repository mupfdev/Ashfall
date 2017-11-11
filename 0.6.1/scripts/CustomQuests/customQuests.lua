require("color")


Methods = {}

local questPlayerDataPath  = "path/to/folder/"
local questListPath  = "path/to/folder/where/the/textfile/is/"
local questListMain = questListPath .. "customQuestsMain.txt"
local questListSide = questListPath .. "customQuestsSide.txt"
local questListRandom = questListPath .. "customQuestsRandom.txt"
local CQversionNumber = "0.9.3"                         -- version of the script
local mainQuestReq = 20                                 -- required amount of completed main quests before one can do side quests
local CQlogLevel = 0                                    -- logging level, see tes3mp-server.default.cfg
local skipAllowed = 1                                   -- 0 false, 1 true
local skipItem = "gold_001"                             -- what item to use as a cost for skipping
local skipAmount = "10000"                              -- what amount
local skipMessage = "This will cost you 10000 gold."    -- message to display about cost
local skipQuestGUIID = 24601                            -- GUIID, probably dont need to touch
math.randomseed( os.time() )

Methods.init = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local questList = questListPath .. "customQuestsMain.txt"
    local message
    local pFile = io.open(questFile, "r")
    if pFile == nil then
        pFile = io.open(questFile, "w+")
        pFile:write("1\n")
        pFile:write("0\n")
        pFile:write("1\n")
        pFile:write("0\n")
        pFile:write("1\n")
        pFile:write("0")
        pFile:close()
        message = color.CornflowerBlue .. "Custom quests are enable on this server. Type /cqabout in chat for more information.\n" .. color.Default -- inform the user on 1st login that custom quests exist
        tes3mp.SendMessage(pid, message, false)
        message = "CQ: NEW FILE FOR " .. playerName .. " CREATED\n"
        tes3mp.LogMessage(CQlogLevel, message)
    end
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    pFile:close()
    pFile = io.open(questFile, "w+")
    if currentQM == nil then
        pFile:write("1\n")
    else
        pFile:write(currentQM .. "\n")
    end
    if currentQPM == nil then
        pFile:write("0\n")
    else
        pFile:write(currentQPM .. "\n")
    end
    if currentQS == nil then
        pFile:write("1\n")
    else
        pFile:write(currentQS .. "\n")
    end
    if currentQPS == nil then
        pFile:write("0\n")
    else
        pFile:write(currentQPS .. "\n")
    end
    if currentQR == nil then
        pFile:write("1\n")
    else
        pFile:write(currentQR .. "\n")
    end
    if currentQPR == nil then
        pFile:write("0\n")
    else
        pFile:write(currentQPR .. "\n")
    end
    pFile:close()
end

Methods.createFile = function(pid)
    local playerName = string.lower(tes3mp.GetName(pid))
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "w+")
    pFile:write("1\n")
    pFile:write("0\n")
    pFile:write("1\n")
    pFile:write("0\n")
    pFile:write("1\n")
    pFile:write("0")
    pFile:close()
    message = "CQ: FAILSAFE FOR " .. playerName .. " WITH PID " .. pid .. " TRIGGERED\n"
    tes3mp.LogMessage(CQlogLevel, message)
end

Methods.readMainFile = function(currentQ, playerName)
    local qFile = io.open(questListMain, "r")
    local j = 0
    local message
    local questString
    for line in qFile:lines() do
        j = j + 1
        if currentQ == j then
            questString = line
            message = "CQ: MAIN QUEST FOUND FOR " .. playerName .. " WITH ID " .. j .. "\n"
            tes3mp.LogMessage(CQlogLevel, message)
            break
        end
    end
    qFile:close()
    return questString
end

Methods.readSideFile = function(currentQ, playerName)
    local qFile = io.open(questListSide, "r")
    local j = 0
    local message
    local questString
    for line in qFile:lines() do
        j = j + 1
        if currentQ == j then
            questString = line
            message = "CQ: SIDE QUEST FOUND FOR " .. playerName .. " WITH ID " .. j .. "\n"
            tes3mp.LogMessage(CQlogLevel, message)
            break
        end
    end
    qFile:close()
    return questString
end

Methods.readRandomFile = function(currentQ, playerName)
    local qFile = io.open(questListRandom, "r")
    local j = 0
    local message
    local questString
    for line in qFile:lines() do
        j = j + 1
        if currentQ == j then
            questString = line
            message = "CQ: RANDOM QUEST FOUND FOR " .. playerName .. " WITH ID " .. j .. "\n"
            tes3mp.LogMessage(CQlogLevel, message)
            break
        end
    end
    qFile:close()
    return questString
end

Methods.registerKill = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questListMain = questListPath .. "customQuestsMain.txt"
    local questListSide = questListPath .. "customQuestsSide.txt"
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    currentQM = tonumber(currentQM)
    currentQPM = tonumber(currentQPM)
    currentQS = tonumber(currentQS)
    currentQPS = tonumber(currentQPS)
    currentQR = tonumber(currentQR)
    currentQPR = tonumber(currentQPR)
    pFile:close()
    local questString = {}
    local questStringFinal
    local questLine
    local currentQ
    local currentQP
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questStringFinal = questString[2]
        questLine = "Special"
        currentQ = currentQS
        currentQP = tonumber(currentQPS)
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questStringFinal = questString[3]
        questLine = "Random"
        currentQ = currentQR
        currentQP = tonumber(currentQPR)
    end
    tmp[2] = "TEMP"
    if questStringFinal == nil then
        tmp[2] = "MISSING"
    end
    local i
    local k
    local j
    if tmp[2] ~= "MISSING" then
        i = 1
        for word in string.gmatch(questStringFinal, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if tmp[2] == "hunt" then
            local target = {}
            local requirement = {}
            if questLine == "Random" then
                i = 5
            else
                i = 3
            end
            j = 1
            while tonumber(tmp[i]) == nil do
                target[j] = tmp[i]
                i = i + 1
                j = j + 1
            end
            if (j > 2 and tmp[2] == "travel") then
                message = "CQ: WARNING! MORE THAN ONE TARGET FOR FOR TRAVEL QUEST DETECTED\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            k = 1
            while tonumber(tmp[i]) ~= nil do
                requirement[k] = tmp[i]
                i = i + 1
                k = k + 1
            end
            if (k > 2 and tmp[2] ~= "gather") then
                message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR NON GATHER QUEST\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            if k > 2 then
                message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR HUNT QUEST\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            local killID = tes3mp.GetKillRefId(pid, 0)
            local j2
            for j2 = 1, j-1 do
                if killID == target[j2] then
                    currentQP = currentQP + 1
                    message = color.MediumTurquoise .. "Quest kill registered.\n" .. color.Default
                    tes3mp.SendMessage(pid, message, false)
                    message = "CQ: QUEST TARGET " .. killID .. " REGISTERED FOR " .. playerName .. " WITH ID " .. pid .. "\n"
                    tes3mp.LogMessage(CQlogLevel, message)
                end
            end
            if questLine == "Main" then
                currentQPM = currentQP
            elseif questLine == "Side" then
                currentQPS = currentQP
            elseif questLine == "Random" then
                currentQPR = currentQP
            else
                message = "CQ: UNRECOGNISED QUESTLINE TYPE FOR " .. pid .. "\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            pFile = io.open(questFile, "w+")
            pFile:write(currentQM .. "\n")
            pFile:write(currentQPM .. "\n")
            pFile:write(currentQS .. "\n")
            pFile:write(currentQPS .. "\n")
            pFile:write(currentQR .. "\n")
            pFile:write(currentQPR)
            pFile:close()
            message = "CQ: QUEST PROGRESS FOR " .. playerName .. " WITH PID " .. pid .. " STORED\n"
            tes3mp.LogMessage(CQlogLevel, message)
            requirement[1] = tonumber(requirement[1])
            if currentQP >= requirement[1] then
                message = "CQ: " .. playerName .. " WITH PID " .. pid .. " HAS MET QUEST REQUIREMENTS\n"
                tes3mp.LogMessage(CQlogLevel, message)
                customQuests.giveReward(pid)
            end
        end
    end
end

Methods.checkTravelCell = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questListMain = questListPath .. "customQuestsMain.txt"
    local questListSide = questListPath .. "customQuestsSide.txt"
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    currentQM = tonumber(currentQM)
    currentQPM = tonumber(currentQPM)
    currentQS = tonumber(currentQS)
    currentQPS = tonumber(currentQPS)
    currentQR = tonumber(currentQR)
    currentQPR = tonumber(currentQPR)
    pFile:close()
    local questString = {}
    local questStringFinal
    local questLine
    local currentQ
    local currentQP
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questStringFinal = questString[2]
        questLine = "Special"
        currentQ = currentQS
        currentQP = tonumber(currentQPS)
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questStringFinal = questString[3]
        questLine = "Random"
        currentQ = currentQR
        currentQP = tonumber(currentQPR)
    end
    tmp[2] = "TEMP"
    if questStringFinal == nil then
        tmp[2] = "MISSING"
    end
    local i
    local k
    local j
    if tmp[2] ~= "MISSING" then
        i = 1
        for word in string.gmatch(questStringFinal, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if tmp[2] == "travel" then
            local target = {}
            local requirement = {}
            if questLine == "Random" then
                i = 5
            else
                i = 3
            end
            j = 1
            while tonumber(tmp[i]) == nil do
                target[j] = tmp[i]
                i = i + 1
                j = j + 1
            end
            if (j > 2 and tmp[2] == "travel") then
                message = "CQ: WARNING! MORE THAN ONE TARGET FOR FOR TRAVEL QUEST DETECTED\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            k = 1
            while tonumber(tmp[i]) ~= nil do
                requirement[k] = tmp[i]
                i = i + 1
                k = k + 1
            end
            if (k > 2 and tmp[2] ~= "gather") then
                message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR NON GATHER QUEST\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            local currentCell = tes3mp.GetCell(pid)
            if target[1] == currentCell then
                customQuests.giveReward(pid)
            end
        end
    end
end

Methods.turnIn = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questListMain = questListPath .. "customQuestsMain.txt"
    local questListSide = questListPath .. "customQuestsSide.txt"
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    currentQM = tonumber(currentQM)
    currentQPM = tonumber(currentQPM)
    currentQS = tonumber(currentQS)
    currentQPS = tonumber(currentQPS)
    currentQR = tonumber(currentQR)
    currentQPR = tonumber(currentQPR)
    pFile:close()
    local questString = {}
    local questStringFinal
    local questLine
    local currentQ
    local currentQP
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questStringFinal = questString[2]
        questLine = "Special"
        currentQ = currentQS
        currentQP = tonumber(currentQPS)
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questStringFinal = questString[3]
        questLine = "Random"
        currentQ = currentQR
        currentQP = tonumber(currentQPR)
    end
    tmp[2] = "TEMP"
    if questStringFinal == nil then
        tmp[2] = "MISSING"
    end
    local i
    local k
    local j
    if tmp[2] ~= "MISSING" then
        i = 1
        for word in string.gmatch(questStringFinal, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if tmp[2] == "gather" then
            local target = {}
            local requirement = {}
            if questLine == "Random" then
                i = 5
            else
                i = 3
            end
            j = 1
            while tonumber(tmp[i]) == nil do
                target[j] = tmp[i]
                i = i + 1
                j = j + 1
            end
            k = 1
            while tonumber(tmp[i]) ~= nil do
                requirement[k] = tmp[i]
                i = i + 1
                k = k + 1
            end
            if (k > 2 and tmp[2] ~= "gather") then
                message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR NON GATHER QUEST\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            if (k ~= j and tmp[2] == "gather") then
                message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR GATHER QUEST\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
            local itemIndex = {}
            local itemCount = {}
            local canTurnIn = true
            for j2 = 1, j-1 do
                for index, item in pairs(Players[pid].data.inventory) do
                    if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", target[j2], true) then
                        itemIndex[j2] = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", target[j2])
                        itemCount[j2] = Players[pid].data.inventory[itemIndex[j2]].count
                    else
                        itemCount[j2] = 0
                    end
                end
            end
            for j2 = 1, j-1 do
                if tonumber(itemCount[j2]) < tonumber(requirement[j2]) then
                    canTurnIn = false
                end
            end
            if canTurnIn == true then
                for j2 = 1, j-1 do
                    Players[pid].data.inventory[itemIndex[j2]].count = Players[pid].data.inventory[itemIndex[j2]].count - tonumber(requirement[j2])
                    if Players[pid].data.inventory[itemIndex[j2]].count == 0 then
                        Players[pid].data.inventory[itemIndex[j2]] = nil
                    end
                end
                message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " SUCCESSFULLY GATHERED ALL THE ITEMS FOR THE GATHER QUEST WITH ID " .. currentQ .. "\n"
                tes3mp.LogMessage(CQlogLevel, message)
                Players[pid]:LoadInventory()
                Players[pid]:LoadEquipment()
                Players[pid]:Save()
                customQuests.giveReward(pid)
            else
                message = color.IndianRed .. "Item(s) missing.\n" .. color.Default
                tes3mp.SendMessage(pid, message, false)
                message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " DOES NOT HAVE ENOUGH ITEMS FOR THE GATHER QUEST WITH ID " .. currentQ .. "\n"
                tes3mp.LogMessage(CQlogLevel, message)
            end
        else
            message = color.IndianRed .. "This is not a gathering quest.\n" .. color.Default
            tes3mp.SendMessage(pid, message, false)
        end
    end
end

Methods.giveReward = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questListMain = questListPath .. "customQuestsMain.txt"
    local questListSide = questListPath .. "customQuestsSide.txt"
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    currentQM = tonumber(currentQM)
    currentQPM = tonumber(currentQPM)
    currentQS = tonumber(currentQS)
    currentQPS = tonumber(currentQPS)
    currentQR = tonumber(currentQR)
    currentQPR = tonumber(currentQPR)
    pFile:close()
    local questString = {}
    local questStringFinal
    local questLine
    local currentQ
    local currentQP
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questStringFinal = questString[2]
        questLine = "special"
        currentQ = currentQS
        currentQP = tonumber(currentQPS)
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questStringFinal = questString[3]
        questLine = "random"
        currentQ = currentQR
        currentQP = tonumber(currentQPR)
    end
    tmp[2] = "TEMP"
    if questStringFinal == nil then
        tmp[2] = "MISSING"
    end
    local i
    local k
    local j
    local j2
    local k2
    local completionMessage
    local target = {}
    local requirement = {}
    local rewardName = {}
    local rewardCount = {}
    local statIncrease
    if tmp[2] ~= "MISSING" then
        i = 1
        for word in string.gmatch(questStringFinal, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if questLine == "random" then
            i = 5
        else
            i = 3
        end
        j = 1
        while tonumber(tmp[i]) == nil do
            target[j] = tmp[i]
            i = i + 1
            j = j + 1
        end
        if (j > 2 and tmp[2] == "travel") then
            message = "CQ: WARNING! MORE THAN ONE TARGET FOR FOR TRAVEL QUEST DETECTED\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
        k = 1
        while tonumber(tmp[i]) ~= nil do
            requirement[k] = tmp[i]
            i = i + 1
            k = k + 1
        end
        if (k > 2 and tmp[2] ~= "gather") then
            message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR NON GATHER QUEST\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
        if (k ~= j and tmp[2] == "gather") then
            message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR GATHER QUEST\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
        j2 = 1
        while tonumber(tmp[i]) == nil do
            rewardName[j2] = tmp[i]
            i = i + 1
            j2 = j2 + 1
        end
        k2 = 1
        while tonumber(tmp[i]) ~= nil do
            rewardCount[k2] = tmp[i]
            i = i + 1
            k2 = k2 + 1
        end
        if k2 ~= j2 then
            message = "CQ: WARNING! MISMATCH ON REWARD NAME TO REWARD COUNT RATIO\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
        completionMessage = tmp[i]
    end
    local i2
    for i2 = 1, j2 - 1 do
        if rewardName[i2] == "strength" then
            statIncrease = tes3mp.GetAttributeBase(pid, 0) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 0, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "intelligence" then
            statIncrease = tes3mp.GetAttributeBase(pid, 1) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 1, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "willpower" then
            statIncrease = tes3mp.GetAttributeBase(pid, 2) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 2, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "agility" then
            statIncrease = tes3mp.GetAttributeBase(pid, 3) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 3, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "endurance" then
            statIncrease = tes3mp.GetAttributeBase(pid, 4) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 4, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "speed" then
            statIncrease = tes3mp.GetAttributeBase(pid, 5) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 5, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "personality" then
            statIncrease = tes3mp.GetAttributeBase(pid, 6) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 6, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "luck" then
            statIncrease = tes3mp.GetAttributeBase(pid, 7) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, 7, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        elseif rewardName[i2] == "random" then
            local statRoll
            math.random()
            statRoll = math.random(0,7)
            statIncrease = tes3mp.GetAttributeBase(pid, statRoll) + rewardCount[i2]
            tes3mp.SetAttributeBase(pid, statRoll, statIncrease)
            tes3mp.SendAttributes(pid)
            Players[pid]:SaveAttributes()
        else
            local items = { {rewardName[i2], rewardCount[i2], -1}}
            for i,item in pairs(items) do
                local structuredItem = { refId = item[1], count = item[2], charge = item[3] }
                table.insert(Players[pid].data.inventory, structuredItem)
            end
        end
    end
    Players[pid]:LoadInventory()
    Players[pid]:LoadEquipment()
    Players[pid]:Save()
    message = color.Peru .. "Quest completed! " .. completionMessage .. "\n" .. color.Default
    tes3mp.SendMessage(pid, message, false)
    message = "CQ: " .. playerName .. " WITH PID " .. pid .. " COMPLETED QUEST WITH ID " .. currentQ .. "\n"
    tes3mp.LogMessage(CQlogLevel, message)
    if(questLine == "main") then
        currentQM = currentQM + 1
        currentQPM = 0
    elseif (questLine == "special") then
        currentQS = currentQS + 1
        currentQPS = 0
    end
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questLine = "main"
        questStringFinal = questString[1]
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questLine = "special"
        questStringFinal = questString[2]
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questLine = "main"
        questStringFinal = questString[1]
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questLine = "random"
        questStringFinal = questString[3]
    end
    if questLine == "random" then
        currentQR = customQuests.generateNewRandomQuest(pid)
        currentQPR = 0
    end
    pFile = io.open(questFile, "w+")
    pFile:write(currentQM .. "\n")
    pFile:write(currentQPM .. "\n")
    pFile:write(currentQS .. "\n")
    pFile:write(currentQPS .. "\n")
    pFile:write(currentQR .. "\n")
    pFile:write(currentQPR)
    pFile:close()
    message = "CQ: NEW QUEST FOUND FOR " .. playerName .. "\n"
    tes3mp.LogMessage(CQlogLevel, message)
    if questStringFinal == nil then
        message = color.IndianRed .. "There are no more available quests.\n" .. color.Default
        tes3mp.SendMessage(pid, message, false)
    else
        message = color.BlueViolet .. "New " .. questLine .. " quest added. Use /questinfo to see the details.\n" .. color.Default
        tes3mp.SendMessage(pid, message, false)
    end
end

Methods.showQuestInfo = function(pid)
    local tmp = {}
    local playerName = string.lower(tes3mp.GetName(pid))
    local questListMain = questListPath .. "customQuestsMain.txt"
    local questListSide = questListPath .. "customQuestsSide.txt"
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    currentQM = tonumber(currentQM)
    currentQPM = tonumber(currentQPM)
    currentQS = tonumber(currentQS)
    currentQPS = tonumber(currentQPS)
    currentQR = tonumber(currentQR)
    currentQPR = tonumber(currentQPR)
    pFile:close()
    local questString = {}
    local questStringFinal
    local questLine
    local currentQ
    local currentQP
    questString[1] = customQuests.readMainFile(currentQM, playerName)
    questString[2] = customQuests.readSideFile(currentQS, playerName)
    questString[3] = customQuests.readRandomFile(currentQR, playerName)
    if (currentQM <= mainQuestReq and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
        questStringFinal = questString[2]
        questLine = "Special"
        currentQ = currentQS
        currentQP = tonumber(currentQPS)
    elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
        questStringFinal = questString[1]
        questLine = "Main"
        currentQ = currentQM
        currentQP = tonumber(currentQPM)
    elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
        questStringFinal = questString[3]
        questLine = "Random"
        currentQ = currentQR
        currentQP = tonumber(currentQPR)
    end
    tmp[2] = "TEMP"
    if questStringFinal == nil then
        tmp[2] = "MISSING"
    end
    local i
    local k
    local j
    local target = {}
    local requirement = {}
    if tmp[2] ~= "MISSING" then
        i = 1
        for word in string.gmatch(questStringFinal, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if questLine == "Random" then
            i = 5
        else
            i = 3
        end
        j = 1
        while tonumber(tmp[i]) == nil do
            target[j] = tmp[i]
            i = i + 1
            j = j + 1
        end
        if (j > 2 and tmp[2] == "travel") then
            message = "CQ: WARNING! MORE THAN ONE TARGET FOR FOR TRAVEL QUEST DETECTED\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
        k = 1
        while tonumber(tmp[i]) ~= nil do
            requirement[k] = tmp[i]
            i = i + 1
            k = k + 1
        end
        if (k > 2 and tmp[2] ~= "gather") then
            message = "CQ: WARNING! MISMATCH ON TARGET-TO-REQUIREMENT RATIO FOR NON GATHER QUEST\n"
            tes3mp.LogMessage(CQlogLevel, message)
        end
    end
    local tmpType
    if tmp[2] == "hunt" then
        tmpType = "Hunting"
    elseif tmp[2] == "travel" then
        tmpType = "Traveling "
    elseif tmp[2] == "gather" then
        tmpType = "Gathering"
    end
    local progress = {}
    local j2
    if tmp[2] == "gather" then
        for j2 = 1, j-1 do
            for index, item in pairs(Players[pid].data.inventory) do
                if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", target[j2], true) then
                    local itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", target[j2])
                    progress[j2] = tonumber(Players[pid].data.inventory[itemIndex].count)
                else
                    progress[j2] = 0
                end
            end
        end
        currentQP = progress[1]
    end
    if tmp[2] ~= "MISSING" then
        local messageBoxText = "Current quest information:\n"
        messageBoxText = messageBoxText .. "\n"
        messageBoxText = messageBoxText .. "Questline: #0066FF" .. questLine .. "#CAA560\n"
        if questLine ~= "Random" then
            messageBoxText = messageBoxText .. "Quest number: #00FF00" .. currentQ .. "#CAA560\n"
        end
        messageBoxText = messageBoxText .. tmp[1] .. "\n"
        messageBoxText = messageBoxText .. "Quest type: #FF9900" .. tmpType .. "#CAA560\n"
        if currentQP >= tonumber(requirement[1]) then
            messageBoxText = messageBoxText .. "Progress: " .. color.LimeGreen  .. currentQP .. "/" .. requirement[1] .. "#CAA560"
        else
            messageBoxText = messageBoxText .. "Progress: " .. color.Red  .. currentQP .. "/" .. requirement[1] .. "#CAA560"
        end
        if (tmp[2] ~= "gather" or j-1 < 2) then
            messageBoxText = messageBoxText .. "\n"
        else
            for j2 = 2, j-1 do
                if j-1 - j2 < 1 then
                    if progress[j2] >= tonumber(requirement[j2]) then
                        messageBoxText = messageBoxText .. " and " .. color.LimeGreen .. progress[j2] .. "/" .. requirement[j2] .. "#CAA560\n"
                    else
                        messageBoxText = messageBoxText .. " and " .. color.Red .. progress[j2] .. "/" .. requirement[j2] .. "#CAA560\n"
                    end
                else
                    if progress[j2] >= tonumber(requirement[j2]) then
                        messageBoxText = messageBoxText .. ", " .. color.LimeGreen .. progress[j2] .. "/" .. requirement[j2] .. "#CAA560"
                    else
                        messageBoxText = messageBoxText .. ", " .. color.Red .. progress[j2] .. "/" .. requirement[j2] .. "#CAA560"
                    end
                end
            end
        end
        tes3mp.MessageBox(pid, -1, messageBoxText)
        message = "CQ: DISPLAYING QUEST INFO FOR " .. playerName .. " WITH PID " .. pid .. "\n"
        tes3mp.LogMessage(CQlogLevel, message)
    else
        message = color.Magenta .. "There are no more quests.\n" .. color.Default
        tes3mp.SendMessage(pid, message, false)
    end
end

Methods.showAbout = function(pid)
    local messageBoxText
    local playerName = tes3mp.GetName(pid)
    messageBoxText = "About Custom Quests version " .. CQversionNumber .. "\n"
    messageBoxText = messageBoxText .. "\n"
    messageBoxText = messageBoxText .. "Custom Quests is a script that allows server owners to add various quests for players to do.\n"
    messageBoxText = messageBoxText .. "The quests can involve traveling, gathering items and killing specific targets.\n"
    messageBoxText = messageBoxText .. "The quests can also be split up into different questlines - main, special and random.\n"
    messageBoxText = messageBoxText .. "While main and special quests are on-time only, random quests are repeatable and a new quest is picked each time you complete the previous one.\n"
    messageBoxText = messageBoxText .. "Type /questinfo in the chat now to see details about your current quest!\n"
    messageBoxText = messageBoxText .. "\n"
    messageBoxText = messageBoxText .. "Known issues:\n"
    messageBoxText = messageBoxText .. "1) Kills do not register when multiple players have the creature loaded. Cause: TES3MP 0.6.1. Solution: hunt alone.\n"
    messageBoxText = messageBoxText .. "2) /questdeliver or /questinfo shows that the items are not there. Cause: packets from client have not been sent to server. Solution: change cell (enter/leave building, for example).\n"
    messageBoxText = messageBoxText .. "\n"
    messageBoxText = messageBoxText .. "Special thanks to:\n"
    if playerName == "mupf" then
        messageBoxText = messageBoxText .. color.LimeGreen .. "You, " .. color.Yellow .. "David C." ..  "#CAA560, various people from TES3MP discord\n"
        messageBoxText = messageBoxText .. "If not for you, this would not be possible."
    else
        messageBoxText = messageBoxText .. color.LimeGreen .. "mupf, " .. color.Yellow .. "David C." ..  "#CAA560, various people from TES3MP discord\n"
        messageBoxText = messageBoxText .. "And You - " .. color.SteelBlue .. playerName .. "#CAA560 - if not for players like you, this would not be possible."
    end
    tes3mp.MessageBox(pid, -1, messageBoxText)
end

Methods.skipQuestBox = function(pid)
    if skipAllowed == 1 then
        local tmp = {}
        local playerName = string.lower(tes3mp.GetName(pid))
        local questListMain = questListPath .. "customQuestsMain.txt"
        local questListSide = questListPath .. "customQuestsSide.txt"
        local questListRandom = questListPath .. "customQuestsRandom.txt"
        local questFile  = questPlayerDataPath .. playerName .. ".txt"
        local message
        local pFile = io.open(questFile, "r")
        local currentQM = pFile:read()
        if currentQM == nil then
            pFile:close();
            customQuests.createFile(pid)
            message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
            tes3mp.LogMessage(CQlogLevel, message)
            pFile = io.open(questFile, "r")
            currentQM = 1
        end
        local currentQPM = pFile:read()
        local currentQS = pFile:read()
        local currentQPS = pFile:read()
        local currentQR = pFile:read()
        local currentQPR = pFile:read()
        currentQM = tonumber(currentQM)
        currentQPM = tonumber(currentQPM)
        currentQS = tonumber(currentQS)
        currentQPS = tonumber(currentQPS)
        currentQR = tonumber(currentQR)
        currentQPR = tonumber(currentQPR)
        pFile:close()
        local questString = {}
        local questStringFinal
        local questLine
        local currentQ
        local currentQP
        questString[1] = customQuests.readMainFile(currentQM, playerName)
        questString[2] = customQuests.readSideFile(currentQS, playerName)
        questString[3] = customQuests.readRandomFile(currentQR, playerName)
        if (currentQM <= mainQuestReq and questString[1] ~= nil) then
            questLine = "Main"
        elseif (currentQM > mainQuestReq and questString[2] ~= nil) then
            questLine = "Special"
        elseif (currentQM > mainQuestReq and questString[2] == nil and questString[1] ~= nil) then
            questLine = "Main"
        elseif (questString[1] == nil and questString[2] == nil and questString[3] ~= nil) then
            questLine = "Random"
        end
        if questLine == "Random" then
            local label = "Are you sure you want to skip the quest?\n"
            label = label .. skipMessage
            local buttonData = "Yes;No"
            tes3mp.CustomMessageBox(pid, skipQuestGUIID, label, buttonData)
        else
            message = color.Magenta .. "This is not a random quest.\n" .. color.Default
            tes3mp.SendMessage(pid, message, false)
        end
    else
        message = color.Magenta .. "You are not allowed to skip quests on this server.\n" .. color.Default
        tes3mp.SendMessage(pid, message, false)
    end
end

Methods.skipQuest = function(pid)
    local playerName = string.lower(tes3mp.GetName(pid))
    local questFile  = questPlayerDataPath .. playerName .. ".txt"
    local message
    local pFile = io.open(questFile, "r")
    local currentQM = pFile:read()
    if currentQM == nil then
        pFile:close();
        customQuests.createFile(pid)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " HAS MISSING DATA IN SAVEFILE\n"
        tes3mp.LogMessage(CQlogLevel, message)
        pFile = io.open(questFile, "r")
        currentQM = 1
    end
    local currentQPM = pFile:read()
    local currentQS = pFile:read()
    local currentQPS = pFile:read()
    local currentQR = pFile:read()
    local currentQPR = pFile:read()
    pFile:close()
    local itemCount
    local itemIndex
    local canTurnIn = true
    for index, item in pairs(Players[pid].data.inventory) do
        if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", skipItem, true) then
            itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", skipItem)
            itemCount = Players[pid].data.inventory[itemIndex].count
        else
            itemCount = 0
        end
    end
    if tonumber(itemCount) < tonumber(skipAmount) then
        canTurnIn = false
    end
    if canTurnIn == true then
        Players[pid].data.inventory[itemIndex].count = Players[pid].data.inventory[itemIndex].count - tonumber(skipAmount)
        if Players[pid].data.inventory[itemIndex].count == 0 then
            Players[pid].data.inventory[itemIndex] = nil
        end
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " SUCCESSFULLY SKIPPED RANDOM QUEST\n"
        tes3mp.LogMessage(CQlogLevel, message)
        Players[pid]:LoadInventory()
        Players[pid]:LoadEquipment()
        Players[pid]:Save()
        currentQR = customQuests.generateNewRandomQuest(pid)
        currentQPR = 0
        pFile = io.open(questFile, "w+")
        pFile:write(currentQM .. "\n")
        pFile:write(currentQPM .. "\n")
        pFile:write(currentQS .. "\n")
        pFile:write(currentQPS .. "\n")
        pFile:write(currentQR .. "\n")
        pFile:write(currentQPR)
        pFile:close()
    else
        message = color.IndianRed .. "Item missing.\n" .. color.Default
        tes3mp.SendMessage(pid, message, false)
        message = "CQ: " ..  playerName .. " WITH PID " .. pid .. " DOES NOT HAVE ENOUGH ITEMS TO SKIP RANDOM QUEST\n"
        tes3mp.LogMessage(CQlogLevel, message)
    end
end

Methods.generateNewRandomQuest = function(pid)
    local tmp = {}
    local questListRandom = questListPath .. "customQuestsRandom.txt"
    local qFile = io.open(questListRandom, "r")
    local message
    local level = tonumber(Players[pid].data.stats.level)
    local questVector = {}
    local j = 0
    local i
    local k = 1
    local k2
    local questRoll
    local questID
    for line in qFile:lines() do
        j = j + 1
        i = 1
        for word in string.gmatch(line, '([^;]+)') do
            tmp[i] = word
            i = i + 1
        end
        if level >= tonumber(tmp[4]) then
            for k2 = 1, tonumber(tmp[3]) do
                questVector[k] = j
                k = k + 1
            end
        end
    end
    qFile:close()
    math.random()
    if k > 1 then
        questRoll = math.random(1,k-1)
        questID = questVector[questRoll]
    else
        questID = nil
    end
    return questID
end

Methods.OnGUIAction = function(pid, idGui, data)
	if idGui == skipQuestGUIID then
		if tonumber(data) == 0 then -- Yes
			customQuests.skipQuest(pid)
			return true
		elseif tonumber(data) == 1 then -- No
			return true
		end
	end
end

return Methods
