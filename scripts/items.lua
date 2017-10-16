-- items.lua -*-lua-*-
-- "THE BEER-WARE LICENSE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer


require("color")


Methods = {}


-- Add [ items = require("items") ] to the top of server.lua
-- Find "OnPlayerEquipment(pid)" inside server.lua and insert:
-- [ items.UnequipBannedItems(pid) ]
-- [ items.IronFork(pid) ]
-- [ items.TsiyasRing(pid) ]
-- directly underneath it.


local itemList = {}
local slotHelmet        = 0;
local slotCuirass       = 1;
local slotGreaves       = 2;
local slotLeftPauldron  = 3;
local slotRightPauldron = 4;
local slotLeftGauntlet  = 5;
local slotRightGauntlet = 6;
local slotBoots         = 7;
local slotShirt         = 8;
local slotPants         = 9;
local slotSkirt         = 10;
local slotRobe          = 11;
local slotLeftRing      = 12;
local slotRightRing     = 13;
local slotAmulet        = 14;
local slotBelt          = 15;
local slotCarriedRight  = 16;
local slotCarriedLeft   = 17;
local slotAmmunition    = 18;


function PlayerHasItemEquipped(pid, list)
	 local c = 0
	 local i = 1

	 while list[i] ~= nil do
			if tes3mp.HasItemEquipped(pid, tostring(list[i])) then c = c + 1 end
			i = i + 1
	 end

	 if c > 0 then return true else return false end
end


Methods.UnequipBannedItems = function(pid)
	 local message = color.Crimson .. "Banned items have been unequipped.\n"
	 local c = 0
	 local i = 1

	 -- Over-powerful item-sets and combinations:

	 -- Boots of Blinding Speed & Cuirass of the Savior's Hide.
	 itemList = { "cuirass_savior_unique", "boots of blinding speed[unique]" }

	 while itemList[i] ~= nil do
			if tes3mp.HasItemEquipped(pid, tostring(itemList[i])) then c = c + 1 end
			i = i + 1
	 end
	 if c > 1 and tes3mp.GetRace(pid) ~= "breton" then
			message = color.CornflowerBlue .. "You are not supposed to see this, mortal.\n"
			tes3mp.UnequipItem(pid, slotCuirass)
			tes3mp.SendEquipment(pid)
	 end

	 -- Boots of Blinding Speed as a Breton.
	 if tes3mp.HasItemEquipped(pid, "boots of blinding speed[unique]") and tes3mp.GetRace(pid) == "breton" then
			message = color.CornflowerBlue .. "These boots are not for you, Breton.\n"
			tes3mp.UnequipItem(pid, slotBoots)
			tes3mp.SendEquipment(pid)
			c = c + 1
	 end

	 -- Ridiculously over-powerful items which can be obtained without
	 -- difficulty. Or items that simply destroy the overall balance:

	 -- Helm.
	 itemList = { "daedric_fountain_helm", "daedric_terrifying_helm", "daedric_god_helm" }
	 if PlayerHasItemEquipped(pid, itemList) then
			tes3mp.UnequipItem(pid, slotHelm)
			c = c + 1
	 end

	 -- Cuirass.
	 itemList = { "daedric_cuirass", "daedric_cuirass_htab" }
	 if PlayerHasItemEquipped(pid, itemList) then
			tes3mp.UnequipItem(pid, slotCuirass)
			c = c + 1
	 end

	 -- Greaves.
	 itemList = { "daedric_greaves", "daedric_greaves_htab" }
	 if PlayerHasItemEquipped(pid, itemList) then
			tes3mp.UnequipItem(pid, slotGreaves)
			c = c + 1
	 end

	 -- LeftPauldron, RightPauldron.
	 itemList = { "daedric_pauldron_left", "daedric_pauldron_right" }
	 if PlayerHasItemEquipped(pid, itemList) then
			for i = slotLeftPauldron, slotRightPauldron do
				 tes3mp.UnequipItem(pid, i)
				 c = c + 1
			end
	 end

	 -- LeftGauntlet, RightGauntlet.
	 itemList = { "gauntlet_fists_l_unique", "gauntlet_fists_r_unique", "daedric_gauntlet_left", "daedric_gauntlet_right" }
	 if PlayerHasItemEquipped(pid, itemList) then
			for i = slotLeftGauntlet, slotRightGauntlet do
				 tes3mp.UnequipItem(pid, i) end
			c = c + 1
	 end

	 -- Boots.
	 itemList = { "daedric_boots" }
	 if PlayerHasItemEquipped(pid, itemList) then
			tes3mp.UnequipItem(pid, slotBoots)
			c = c + 1
	 end

	 -- LeftRing, RightRing.
	 itemList = { "Helseth's Ring" }
	 if PlayerHasItemEquipped(pid, itemList) then
			for i = slotLeftRing, slotRightRing do
				 tes3mp.UnequipItem(pid, i)
			end
			c = c + 1
	 end

	 -- CarriedRight, CarriedLeft.
	 itemList = { "towershield_eleidon_unique", "azura's servant", "spell_breaker_unique", "daedric_shield", "daedric_towershield", "Gravedigger"}
	 if PlayerHasItemEquipped(pid, itemList) then
			for i = slotCarriedRight, slotCarriedLeft do
				 tes3mp.UnequipItem(pid, i)
			end
			c = c + 1
	 end

	 if c > 0 then
			tes3mp.SendEquipment(pid)
			message = message .. color.Default
			tes3mp.SendMessage(pid, message, false)
	 end
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

			tes3mp.UnequipItem(pid, slotCarriedRight)
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
