local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
	--General    
    UI.AddHeader("General")
	UI.AddToggle("Auto Target", nil, true)
	UI.AddToggle("Auto Charge", nil, true)
	UI.AddRange("Rage Dump", "Will Dump Rage after ", 0, 100, 1, 70)
	--Skills
	UI.AddHeader("Skills")
    UI.AddToggle("Rend", nil, true)
	UI.AddToggle("Bloodrage", nil, true)
    UI.AddRange("Bloodrage HP", nil, 75, 100, 1, 75)
    UI.AddToggle("BattleShout", nil, true)
    UI.AddToggle("Overpower", nil, true)
    UI.AddToggle("Revenge", nil, true)
    UI.AddToggle("Rend", nil, true)
    UI.AddToggle("Sunder Target", nil, true)
	UI:AddRange("Sunder Stacks", nil, 1, 3, 1, 1)
    UI.AddToggle("Thunderclap", nil, true)
	UI.AddToggle("Demoshout", nil, true)
	UI.AddRange("Demoshout at or above # Mobs", nil, 1, 3, 1, 1)
	--Defensives	
	UI.AddHeader("Defensives")
	UI.AddToggle("Defense Stance", nil, true)
	UI.AddRange("Defense Stance at or above # Mobs", nil, 1, 3, 1, 1)
	UI.AddToggle("ShieldBlock", nil, true)
	UI.AddRange("Shieldblock HP", nil, 25, 100, 1, 50)
end