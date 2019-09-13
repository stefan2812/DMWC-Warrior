local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
    
	UI.AddHeader("General")
	UI.AddToggle("AutoTarget", "Auto Targets mobs while in Combat", false)
	UI.AddToggle("Dont waste RAGE", nil, false)
	UI.AddRange("Dump RAGE above", "Will Dump Rage after ", 0, 100, 5, 70, true)
	
	UI.AddHeader("Interrupt")
	UI.AddToggle("Use Pummel",nil, false)
	UI.AddToggle("Use ShieldBash",nil, false)

	UI.AddHeader("Spells")
	UI.AddToggle("MortalStrike", "Use MortalStrike", false)
	UI.AddToggle("Whirlwind", "Use WW", false)
	UI.AddToggle("Hamstring < 30% Enemy HP", "Use Hamstring on mobs below 30% to make them easier to catch", false, true)
	UI.AddToggle("Demo Shout", "Use Demoralizing Shout", false)
	UI.AddToggle("ThunderClap", "Use Thunderclap", false)
	UI.AddDropdown("Demo Shout at/above", "Demoshout when more then # Targets ", {"1","2","3","4","5"}, "2")
	UI.AddDropdown("ThunderClap at/above", "ThunderClap when more then # Targets ", {"1","2","3","4","5"}, "3")
	UI.AddToggle("Execute", "Use Execute", false)

	UI.AddHeader("Cooldowns")
	UI.AddToggle("Bloodrage", "Use Bloodrage when available", false)
    UI.AddToggle("Berserker Rage", "Use Berserker Rage", false)
	UI.AddToggle("SweepingStrikes", "Use SweepingStrikes Talent, when two Targets available", false)

	UI.AddHeader("Mobility")
	UI.AddToggle("Use Charge", "Auto Charges a selected Target when not in Combat", false)
	UI.AddToggle("Use Intercept", "Auto Intercepts a selected Target when in Combat", false)
		
	UI.AddHeader("Debuffs")
    UI.AddToggle("Rend", "Applies Rend debuff to Targets", false)
	--UI.AddToggle("Spread Rend", "Spread Rend to all targets within 5yd", false)
	UI.AddToggle("SunderArmor", "Applies SunderArmor debuff to Targets", false)
	UI.AddBlank(false)
	UI.AddDropdown("Apply # Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", {"1","2","3","4","5"}, "3")
	
	UI.AddHeader("Stance")
	UI.AddToggle("Use Defense Stance")
	UI.AddToggle("Use Berserk Stance")
	UI.AddToggle("Return to Battle Stance after Combat","Returns into Battlestance after Combat",false, true)
	
	UI.AddHeader("Defensives")
	UI.AddToggle("Use ShieldBlock", nil, true)
	UI.AddToggle("Use ShieldWall", nil, true)
	UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
	UI.AddRange("ShieldWall HP", nil, 1, 100, 5, 50)
	UI.AddToggle("Use LastStand", nil, true)
	UI.AddToggle("Retaliation",nil,false)
	UI.AddRange("LastStand HP", nil, 1, 100, 5, 50)
	

	UI.AddHeader("Not for general use")
	UI.AddToggle("Skip Ravenger",nil,false)
	UI.AddToggle("Debug","Adds Debug prints to Chat", false)

end
