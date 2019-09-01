local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
	UI.AddHeader("Welcome to DMWC - Warrior")
	-- General Settings
    UI.AddHeader("General")
	UI.AddToggle("Auto Target", nil, true)
	UI.AddToggle("Auto Charge", nil, true)
	UI.AddRange("Rage Dump", "Will Dump Rage after ", 0, 100, 5, 70)
	UI.AddToggle("Use Cleave", nil, false)
	UI.AddHeader("Attacks")
    UI.AddToggle("Use Rend", nil, true)
    UI.AddToggle("Use Overpower", nil, true)
    UI.AddToggle("Use Revenge", nil, true)
	-- ThunderClap
	UI.AddHeader("Thunderclap")
    UI.AddToggle("Use Thunderclap", nil, true)
	UI.AddRange("ThunderClap#",nil, 1,5,1,3)
	-- BBuffs / Debuffs	
	UI.AddHeader("Buffs & Debuffs - General")
	UI.AddToggle("Use BattleShout", nil, true)
 	-- Sunder
	UI.AddHeader("Sunder Armor")   
	UI.AddToggle("Use Sunder Armor", nil, true)
	UI.AddDropdown("Apply # Stacks of Sunder Armor", nil , {"1", "2", "3"}, 1)
 	-- Demoralizing Shout
	UI.AddHeader("Demoralizing Shout")  
	UI.AddToggle("Use Demoshout", nil, true)
	UI.AddDropdown("Demoshout at or above # Mobs", nil , {"1", "2", "3"}, 1)
	--Cooldowns
	UI.AddHeader("CD: Bloodrage")
	UI.AddDropdown("Use Bloodrage for 1 Pull | 2 Execute", nil , {"1", "2"}, 1)
    UI.AddRange("Bloodrage min HP", nil, 50, 100, 5, 75)
	UI.AddHeader("CD: Retaliation")	
	UI.AddDropdown("Use Retaliation when # Mobs", nil , {"2", "3", "4","5","1000"}, 3)
	UI.AddRange("Use Retaliation when below #% HP", nil, 0, 100, 5, 50)
	-- Defensive Settings
	UI.AddHeader("Defensives")
	UI.AddToggle("Use Defense Stance", nil, true)
	UI.AddDropdown("Defense Stance at or above # Mobs", nil , {"1", "2", "3","4"}, 1)
	UI.AddToggle("Use ShieldBlock", nil, true)
	UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
end