CURRENT VERSION: 0.9.3

CHANGELOG:
0.9.3:
	• Added 3 types of questlines: Main, Side (Special) and Random:
		• Quest selection will prioritise in the following order: Main, if current main quest ID < mainQuestReq, then Side, then (any remaining) Main and finally - Random.
		• Side/special questline can be used for events and such and it can be forced to take priority over everything else.
		• Main questline remains as it used to be before.
		• Random quests can be used to give something for end-game players to do, as well as low-level players, thanks to level requirement variables.
	• Added all 8 attributes as possible rewards, as well as an option to chose a random attribute.
	• Added some more failsaves in case of corrupted save data.
	• Although player files are not compatible with 0.9.2 exactly, they will be updated automatically.
	• Added ability to skip quests (in case of random ones).
	• Added /cqabout command which displays information about the script itself.
0.9.2: 
	• Completely rewrote how quests are saved and loaded. All previous player files should be deleted. All quests should be rewriten in new format (see below).
	• Now supports multiple targets in case of hunt and gathering quests
	• Now supports multiple rewards for quests
	• Added a bit of logging to the server (options to disable as well as more logging will come with later versions)
	• Most of the code is now commented, in case you decide to make some changes

=============================================================

TO SEE THE SCRIPT IN ACTION (v0.9.3), CHECK OUT THIS ALBUM: https://imgur.com/a/PFsBq
LEGACY ALBUM (v0.9.1): https://imgur.com/a/lRKpe

KNOWN ISSUES:
	1) Only player with lowest PID (highest autohority?) will receive the kill during "hunting" quests in the local area (3x3 cells, I believe) - make sure you spread out if you are hunting with others.
	2) /questdeliver and /questinfo incorrectly displays amount of items in inventory. This is because the server has not received a packet from client about inventory changes. Change cell to force an update.

=============================================================

INSTALLATION:
To properly install this script, you first need to make changes to server.lua file:

1. add [ customQuests = require("customQuests") ] (no square brackets) somewhere at the top, along with other "require" lines (to make sure the script is loaded).

2. add

#DEB887/cqabout - Information about the custom quests script\
#DEB887/questinfo - Information about the quest\
#DEB887/questdeliver - Turn in quest (only needed for gathering quests)\
#DEB887/questskip - Skip current random quest (if allowed)#CAA560"

somewhere at  [local helptext = ... ] lines of code, to include these 4 lines in /help function.

3. add [ customQuests.init(pid) ] (no square brackets) after "myMod.OnPlayerConnect(pid, playerName)" (to initialize quest progress file for each player0.

4. add

elseif cmd[1] == "questinfo" then
    customQuests.showQuestInfo(pid)
elseif cmd[1] == "questdeliver" then
    customQuests.turnIn(pid)
elseif cmd[1] == "cqabout" then
    customQuests.showAbout(pid)
elseif cmd[1] == "questskip" then
    customQuests.skipQuestBox(pid)

where all the chat commands go (can possibly do it after the "elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then" command block (to allow people to use these commands).

5. Find "function OnPlayerCellChange(pid)" and under it add [ customQuests.checkTravelCell(pid) ] (no square brackets).

6. Find "function OnPlayerKillCount(pid)" and under it add [ customQuests.registerKill(pid) ] (no square brackets).

7. Find "function OnGuiAction(pid, idGui, data)" and under it add [ if customQuests.OnGUIAction(pid, idGui, data) then return end ] (no square brackets).

8. Save server.lua file

Now that the server.lua file is modified, you need to specific the paths for quest list, as well as progress files for each player.

Open customQuests.lua and find

    local questPlayerDataPath  = "path/to/folder/"
    local questListPath  = "path/to/folder/where/the/textfile/is/"

Change the first path to the path where player progress files will be saved (can use the empty /quests/ folder provided)
Change the second path to where files for questlines (customQuestsMain.txt customQuestsSide.txt and customQuestsRandom.txt) are located.

There are some other changes you can make at the top of this file:

local mainQuestReq = 20                                 Normally, special/side quests are prioritized. However, if the current main quest number is smaller than this value, main quests will be prioritized. Can use this if you want players to complete certain amount of quests first, before they can start the special quests.
local CQlogLevel = 0                                    Logging level, see tes3mp-server.default.cfg
local skipAllowed = 1                                   Defines whether skipping random quests is allowed or not. 0 false, 1 true
local skipItem = "gold_001"                             What item to use as a cost for skipping
local skipAmount = "10000"                              Amount of the item needed to skip the quest
local skipMessage = "This will cost you 10000 gold."    Message to display about cost when trying to skip the quest.

=============================================================

ADDING YOU OWN QUESTS:

Once you're done, you can open the questline files to add your own quests.
One quest is completely contained within one line - make sure to not add line unnecessary line breaks.
All variables are separated by ";" (semicolon) symbol - DO NOT use it in ANY of your variables for quests or you WILL break things and I will be VERY unlikely to help you because I specifically told you NOT to do it.
Include a semicolon after the last variable (completionmessage) as well.

The template for Main and Side questlines goes as follows:

description;type;target1;target2;...;targetn;targetcount1;targetcount2;...;targetcountn;rewardname1;rewardname2;...;rewardnamen;rewardcount1;rewardcount2;...;rewardcountn;completionmessage;

Expanding on each variable:
Decription - any string you wish, which is seen when a player uses command /questinfo. Use it to describe the quest's requirements as well as mention rewards.
Type - type of the quest. Currently, the only supported types are hunt, travel and gather. Any other string can and will break the server so DO NOT USE ANYTHING ELSE.
Target[n] - target IDs. In case of hunt quests, include all creatures the player can hunt to count towards the quest. Including multiple IDs are useful in case of creatures which come in form of a diseases or bligthed one as well.
	- in case of travel quest, it should be the name of the cell. Currently, only one cell "target" is supported, so DO NOT use more than 1.
	- in case of gather quest, include all names of items you want player to gather. Each item will have its required amount and they are mapped in same order as the item IDs were.
Targetcount[n] - amount of targets required for the quest. In case of hunt quest, only ONE number is supported currently. That means that ALL listed kills will count towards one goal.
	- in case of travel quest, this number does not matter much - leave it as a 1 just for safety, though.
	- in case of gather quest, each number is mapped to the item required with same [n]. As such, you can request players to deliver multiple items in various amounts
Rewardname[n] - the ID of item reward you want to give player. Supports multiple items. Can also use attribute name such as "strength" or "endurance" (no quatation marks) to reward an increase in attribute as well. Alternatively, you can use "random" (no quatation marks) to increase a RANDOM attirbute.
Rewardcount[n] - same as with target count, you define the amount of the reward[n] you want to give.
Completionmessage - When a player completes a quest, "Quest completed!" message will appear in chat for them. This variable is a string that is displayed for the player after the initial quest completion message. This is best used to inform the player that the rewards are put in his inventory, and, depending on how you write your quests, can be used to hint at the next one.

For random quests, the template changes:

description;type;rarity;levelrequirement;target1;target2;...;targetn;targetcount1;targetcount2;...;targetcountn;rewardname1;rewardname2;...;rewardnamen;rewardcount1;rewardcount2;...;rewardcountn;completionmessage;

The two new variables are:
Rarity - a natural number from 1 to +infinity. Describes how rare that particular random quest is (the lower the number, the more rare it is).
LevelRequirement - required level for the player to first be able to obtain the quest. If the player's level is lower than that, the quest will not be included in the list of possible quests.

If you are lost on how to make your own quests, look at the sample ones provided already or contact me on discord (Сквиш (NerevarineLoL)#6329) for more help.