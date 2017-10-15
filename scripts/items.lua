-- items.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")
PvP = require("PvP")


Methods = {}


-- Add [ items = require("items") ] to the top of server.lua
-- Find "OnPlayerEquipment(pid)" inside server.lua and insert:
-- [ items.BannedItemSets(pid) ]
-- [ items.BannedPvEItems(pid) ]
-- [ items.BannedPvPItems(pid) ]
-- [ items.IronFork(pid) ]
-- [ items.TsiyasRing(pid) ]
-- directly underneath it.


-- Sets which are only limited in use and banned combinations.
Methods.BannedItemSets = function(pid)
	 local message
	 local list = {}
	 local c = 0
	 local i = 1

	 -- Boots of Blinding Speed & Cuirass of the Savior's Hide.
	 list = { "cuirass_savior_unique", "boots of blinding speed[unique]" }

	 while list[i] ~= nil do
			if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
			i = i + 1
	 end
	 if c > 1 and tes3mp.GetRace(pid) ~= "breton" then
			message = color.CornflowerBlue .. "You are not supposed to see this, mortal.\n"
			tes3mp.UnequipItem(pid, 1) -- Slot_Cuirass
	 end

	 -- Boots of Blinding Speed as a Breton.
	 if tes3mp.HasItemEquipped(pid, "boots of blinding speed[unique]") and tes3mp.GetRace(pid) == "breton" then
			message = color.CornflowerBlue .. "These boots are not for you, Breton.\n"
			tes3mp.UnequipItem(pid, 7) -- Slot_Boots

			--
			tes3mp.SendEquipment(pid)
			message = message .. color.Default
			tes3mp.SendMessage(pid, message, false)
	 end

	 return 0
end


Methods.BannedPvEItems = function(pid)
	 local message = color.CornflowerBlue .. ""
	 local list = {}
	 local c = 0
	 local i = 1

	 -- PvP
	 if PvP.IsPvP(pid) == true then return -1 end

	 list = {
			"BM Nord Leg",
			"azura_star_unique"
	 }

	 while list[i] ~= nil do
			if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
			i = i + 1
	 end

	 if c >= 1 then
			message = color.CornflowerBlue .. "You can't use this item in the wild.\n"
			tes3mp.UnequipItem(pid, 16) -- Slot_CarriedRight

			--
			tes3mp.SendEquipment(pid)
			message = message .. color.Default
			tes3mp.SendMessage(pid, message, false)
	 end

	 return 0
end


Methods.BannedPvPItems = function(pid)
	 local message = color.CornflowerBlue .. ""
	 local list = {}
	 local c = 0
	 local i = 1

	 -- PvP
	 if PvP.IsPvP(pid) == false then return -1 end

	 list = {
			-- Deadric Armor
			"daedric_cuirass",
			"daedric_pauldron_left",
			"daedric_pauldron_right",
			"daedric_gauntlet_left",
			"daedric_gauntlet_right",
			"daedric_greaves",
			"daedric_boots",
			"daedric_shield",
			"daedric_fountain_helm",
			"daedric_terrifying_helm",
			"daedric_god_helm",
			"daedric_towershield",
			"azura's servant",
			"daedric_cuirass_htab",
			"daedric_greaves_htab"
	 }

	 while list[i] ~= nil do
			if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
			i = i + 1
	 end

	 if c >= 1 then
			message = color.CornflowerBlue .. "You can't use this item within this realm.\n"
			-- Unequips everything. Needs to be fixed.
			for i = 0, 18 do tes3mp.UnequipItem(pid, i) end

			--
			tes3mp.SendEquipment(pid)
			message = message .. color.Default
			tes3mp.SendMessage(pid, message, false)
	 end

	 return 0
end


Methods.IronFork = function(pid)
	 if tes3mp.HasItemEquipped(pid, "iron fork") then
			local message = color.CornflowerBlue .. ""
			local cell
			local pos = {}
			local rot = {}

			message = color.MediumSpringGreen .. "You have entered a storage safezone.\n"
			message = message .. color.CornflowerBlue .. "Even if you don't like portkeys, it feels good to be somewhere familiar.\n"
			cell    = "Vivec, St. Delyn Waist North-Two"
			pos[0]  = 5.941999912262
			pos[1]  = 15.234999656677
			pos[2]  = -127
			rot[0]  = -0.000152587890625
			rot[1]  = -3.1416797637939

			if tes3mp.GetCell(pid) == "Vivec, St. Delyn Waist North-Two" then
				 message = color.LightBlue .. "The sensation of travelling by portkey is universally agreed to be uncomfortable.\n"
				 cell    = "Vivec, Arena Pit"
				 pos[0]  = "913.79772949219"
				 pos[1]  = "-12.880634307861"
				 pos[2]  = "-459.41949462891"
				 rot[0]  = "-0.15609979629517"
				 rot[1]  = "-1.569390296936"
			end


			if tes3mp.GetCell(pid) == "Vivec, Arena Pit" then
				 message = color.CornflowerBlue .. "Wake Up. You're Here. Why are you shaking? Are you ok? Wake up. Stand up.\n"
				 cell    = "ToddTest"
				 pos[0]  = 2176
				 pos[1]  = 3648
				 pos[2]  = -191
				 rot[0]  = -0.000152587890625
				 rot[1]  = -3.1416797637939
			end

			if tes3mp.GetCell(pid) == "ToddTest" then
				 message = color.LightBlue .. "It feels quite unpleasent to travel by portkey.\n"
				 cell    = "-2, -9"
				 pos[0]  = -11150.272460938
				 pos[1]  = -70746.1796875
				 pos[2]  = 235.42088317871
				 rot[0]  = -0.057221055030823
				 rot[1]  = -0.22354483604431
			end

			if tes3mp.GetHealthCurrent(pid) <= (tes3mp.GetHealthBase(pid)/100)*10 then
				 message = color.CornflowerBlue .. "Suddenly you found yourself floating in the air. Uh-oh!\n"
				 cell    = "-2, -9"
				 pos[0]  = -11150.272460938
				 pos[1]  = -70746.1796875
				 pos[2]  = 10235.42088317871
				 rot[0]  = -0.057221055030823
				 rot[1]  = -0.22354483604431
			end

			tes3mp.UnequipItem(pid, 16) -- Slot_CarriedRight
			tes3mp.SendEquipment(pid)

			tes3mp.SetPos(pid, pos[0], pos[1], pos[2])
			tes3mp.SetRot(pid, rot[0], rot[1])
			tes3mp.SetCell(pid, cell)
			tes3mp.SendCell(pid)
			tes3mp.SendPos(pid)

			message = message .. color.Default
			tes3mp.SendMessage(pid, message, false)
	 end
end


Methods.TsiyasRing = function(pid)
	 local tsiyasRingModel = "mudcrab"

	 if tes3mp.HasItemEquipped(pid, "common_ring_tsiya") then
			tes3mp.SetCreatureModel(pid, tsiyasRingModel, false)
			tes3mp.SendBaseInfo(pid)
	 end
end


return Methods
