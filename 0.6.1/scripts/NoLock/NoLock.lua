NoLock = {}

NoLock.OnObjectLock = function(pid, cellDescription)
    local lcell = LoadedCells[cellDescription]
    tes3mp.ReadLastEvent()
    for i = 0, tes3mp.GetObjectChangesSize() - 1 do
        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)
        local lockLevel = tes3mp.GetObjectLockLevel(i)

        --Do a check to see if this is something you don't want to lock
        if true then
            --We assume this is being done after myMod saves the lock data, so we don't have to check anything's valid
            lcell.data.objectData[refIndex].lockLevel = 0
            for pid, player in pairs(Players) do
                lcell:SendObjectsLocked(pid)
            end
        end
    end
end

return NoLock

