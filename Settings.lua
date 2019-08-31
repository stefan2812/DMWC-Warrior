local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
	-- General Settings
    UI.AddHeader("General")
	UI.AddToggle("Auto Target", nil, true)
	UI.AddToggle("Auto Charge", nil, true)
	UI.AddRange("Rage Dump", "Will Dump Rage after ", 0, 100, 5, 70)
	-- Skill Settings
	UI.AddHeader("Skills")
    UI.AddToggle("Rend", nil, true)
	UI.AddDropdown("Use Bloodrage for 1 Pull | 2 Execute", nil , {"1", "2"}, 1)
    UI.AddRange("Bloodrage min HP", nil, 50, 100, 5, 75)
    UI.AddToggle("BattleShout", nil, true)
    UI.AddToggle("Overpower", nil, true)
    UI.AddToggle("Revenge", nil, true)
    UI.AddToggle("Rend", nil, true)
    UI.AddToggle("Sunder Target", nil, true)
	UI.AddDropdown("Apply # Stacks of Sunder Armor", nil , {"1", "2", "3"}, 1)
    UI.AddToggle("Thunderclap", nil, true)
	UI.AddToggle("Demoshout", nil, true)
	UI.AddDropdown("Demoshout at or above # Mobs", nil , {"1", "2", "3"}, 1)
	-- Defensive Settings
	UI.AddHeader("Defensives")
	UI.AddToggle("Defense Stance", nil, true)
	UI.AddDropdown("Defense Stance at or above # Mobs", nil , {"1", "2", "3"}, 1)
	UI.AddToggle("ShieldBlock", nil, true)
	UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
	UI.AddDropdown("Use Retaliation when # Mobs", nil , {"2", "3", "4","5"}, 3)
	UI.AddRange("Use Retaliation when below #% HP", nil, 10, 100, 5, 50)
end