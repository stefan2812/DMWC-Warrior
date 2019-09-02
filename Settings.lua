local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
    
	UI.AddHeader("General")
    UI.AddToggle("AutoTarget", "Auto Targets mobs while in Combat", false)
	UI.AddRange("Rage Dump", "Will Dump Rage after ", 0, 100, 1, 70)
	UI.AddHeader("Opener")
    UI.AddToggle("Charge", "Auto Charges a selected Target when not in Combat", false)
	
	UI.AddHeader("Debuffs")
    UI.AddToggle("Rend", "Applies Rend debuff to Targets", false)
	UI.AddToggle("SunderArmor", "Applies SunderArmor debuff to Targets", false)
	UI.AddRange("Apply # Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", 1, 3, 1, 1)
	UI.AddToggle("Demoralizing Shout", "Use Demoralizing Shout", false)
	UI.AddRange("Min targets for Demoralizing Shout", "Demoshout when more then # Targets ", 1, 10, 1, 1)
	UI.AddToggle("ThunderClap", "Use Thunderclap", false)
	UI.AddRange("Min targets for Thunderclap", "Thunderclap when more then # Targets ", 1, 5, 1, 3)
	
	UI.AddHeader("Buffs")
    UI.AddToggle("BattleShout", "Uses Battleshout to Buff", false)
    UI.AddToggle("SweepingStrikes", "Use SweepingStrikes Talent, when two Targets available", false)
    
	UI.AddHeader("Counters")
    UI.AddToggle("Overpower", "Use Overpower when available", false)
    UI.AddToggle("Revenge", "Use Revenge when available", false)
	UI.AddHeader("Finisher")
	UI.AddToggle("Execute", "Use Execute to finish off enemies below 20%", false)
	
	UI.AddHeader("Stance")
	UI.AddToggle("Use Defense Stance")
	
	UI.AddHeader("Defensives")
	UI.AddToggle("Use ShieldBlock", nil, true)
	UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
end