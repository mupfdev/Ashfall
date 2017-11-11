--Setup instructions:
-- 1. Place this file in \mp-stuff\scripts\
-- 2. Add [ RPRolls = require("RPRolls") ] (without the square brackets) at the top of server.lua
-- 3. Add [ math.randomseed(os.time()) ] (without the square brackets) somewhere at the top of server.lua (for example: after "timeCounter = config.timeServerInitTime")
-- 4. Add [ elseif cmd[1] == "roll" then RPRolls.doRoll(pid, playerName, cmd[2]) ] (without the square brackets) after last "elseif cmd[1] == ..." statement in server.lua
-- 5. Add [ /roll <skill/attribute> - perform <skill/attribute> - 100 roll" ] (without square brackets) at the end of "local helptext = ..."

This scripts adds a /roll <skill/attirbute> command (by default available to everyone) which chooses a random value between player's specified skill/attribute and 100. then displays the result in local chat for everyone to see the results. The script was made with RP server in mind, hence the name.
