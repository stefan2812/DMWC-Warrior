local DMW = DMW
DMW.Rotations.WARRIOR = {}
local Warrior = DMW.Rotations.WARRIOR
local UI = DMW.UI

function Warrior.Settings()
    
	UI.AddHeader("General")
	UI.AddToggle("AutoTarget", "Auto Targets mobs while in Combat", false)
	UI.AddToggle("Hamstring on low mob", "Use Hamstring on mobs below 30% to make them easier to catch", false)
	UI.AddRange("Rage Dump", "Will Dump Rage after ", 0, 100, 1, 70)
	UI.AddHeader("Opener")
    UI.AddToggle("Charge", "Auto Charges a selected Target when not in Combat", false)
	UI.AddToggle("Whirlwind", "Use WW", false)
	UI.AddToggle("Bloodrage", "Use Bloodrage when available", false)
	UI.AddHeader("Debuffs")
    UI.AddToggle("Rend", "Applies Rend debuff to Targets", false)
	UI.AddToggle("Spread Rend", "Spread Rend to all targets within 5yd", false)
	UI.AddToggle("SunderArmor", "Applies SunderArmor debuff to Targets", false)
	UI.AddToggle("Spread Sunder", "Spread Sunder Armor to all targets within 5yd", false)
	UI.AddRange("Apply # Stacks of Sunder Armor", "Apply # Stacks of Sunder Armor", 1, 5, 1, 1)
	UI.AddToggle("Demoralizing Shout", "Use Demoralizing Shout", false)
	UI.AddRange("Min targets for Demoralizing Shout", "Demoshout when more then # Targets ", 1, 10, 1, 1)
	UI.AddToggle("ThunderClap", "Use Thunderclap", false)
	UI.AddRange("Min targets for Thunderclap", "Thunderclap when more then # Targets ", 1, 5, 1, 3)
	UI.AddHeader("Buffs")
    UI.AddToggle("BattleShout", "Uses Battleshout to Buff", false)
    UI.AddToggle("SweepingStrikes", "Use SweepingStrikes Talent, when two Targets available", false)
	UI.AddToggle("MortalStrike", "Use MortalStrike", false)
    	UI.AddToggle("BersRage", "Use Berserker Rage", false)
	
	UI.AddHeader("Finisher")
	UI.AddToggle("Execute", "Use Execute to finish off Target below 20%", false)
	--UI.AddToggle("Execute all enemies", "Use Execute on all available Units", false)
	
	UI.AddHeader("Stance")
	UI.AddToggle("Use Defense Stance")
	UI.AddToggle("Use Berserk Stance")
	UI.AddToggle("Return to Battle Stance","Returns into Battlestance after Combat",false)
	
	UI.AddHeader("Defensives")
	UI.AddToggle("Use ShieldBlock", nil, true)
	UI.AddRange("Shieldblock HP", nil, 30, 100, 10, 50)
end
