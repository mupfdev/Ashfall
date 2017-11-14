# NoLock script

## Use case
When a door is locked this script unlocks it. This is to prevent griefing.

## NoLock instructions

Add this at the top of server.lua:

```
NoLock = require("NoLock")
```

Then find:

```
function OnObjectLock(pid, cellDescription)
  myMod.OnObjectLock(pid, cellDescription) 
end
```

add this to it:

```
noLock.OnObjectLock(pid, cellDescription)
```

Now it should look like:
```
function OnObjectLock(pid, cellDescription)
  myMod.OnObjectLock(pid, cellDescription)
  noLock.OnObjectLock(pid, cellDescription)
end
```

## Credits
Credits fully go to: Atkana#0128 or Kibiri-daro
