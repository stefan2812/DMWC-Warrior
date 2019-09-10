local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, rageDanceCheck, timer

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
	HP = (Player.Health / Player.HealthMax) * 100
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = Player.Target or false
    HUD = DMW.Settings.profile.HUD
	CDs = Player:CDs()
    if Talent.TacticalMastery.Rank >= 4 then
        rageDanceCheck = true
    else
        rageDanceCheck = false
	end
	if timer == nil then 
		timer = DMW.Time 
	end
end

local RendImmune = {
	["6"] = true,
	["4"] = true,
	["11"] = true,
	["9"] = true
}
local SunderImmune = {
	["11"] = true,
	["9"] = true
}
local stanceCheckBattle = {
	["Overpower"] = true,
	["Hamstring"] = true,
	["MockingBLow"] = true,
	["Rend"] = true,
	["SunderArmor"] = true,
	["Retaliation"] = true,
	["SweepStrikes"] = true,
	["ThunderClap"] = true,
	["Charge"] = true,
	["Execute"] = true,
	["ShieldBash"] = true
}
local stanceCheckDefence = {
	["Rend"] = true,
	["SunderArmor"] = true,
	["Disarm"] = true,
	["Revenge"] = true,
	["ShieldBlock"] = true,
	["ShieldBash"] = true,
	["ShieldWall"] = true,
	["Taunt"] = true
}
local stanceCheckBers = {
	["Execute"] = true,
	["BersRage"] = true,
	["SunderArmor"] = true,
	["Hamstring"] = true,
	["Intercept"] = true,
    ["Pummel"] = true,
	["Recklessness"] = true,
    ["Whirlwind"] = true
}

local function regularCast(spell, Unit, pool)
    if pool and Spell[spell]:Cost() > Player.Power then
        return true
    end
	if Spell[spell]:Cast(Unit) then
        return true
    end
end
local function DumpBeforeDance(value, spell)

	---------------------------
	-- Check Debug Settings ---

	if Setting("Debug") then
		if (value ~= prev) then
			print("Dumping "..tostring(value).." Rage - Current: "..tostring(Player.Power).." Rage - to cast spell: "..tostring(spell))
			prev = value
		end
	end

	---------------------------
	-- Dump base on Settings --

    if value >= 30 then
		if Setting("MortalStrike") and Spell.MortalStrike:Cast(Target) then 
			return true 
		end
    elseif value >= 20 then
            if #Player:GetEnemies(5) >= 2 then
				if Spell.ThunderClap:Cast(Target) then 
					return true 
				end
				if regularCast("Cleave") then
					return true
				end
			else
				if regularCast("HeroicStrike") then
					return true
				end
			end
    elseif value >= 10 then
		if Spell.Hamstring:Cast(Target) and not Debuff.Hamstring:Exist(Target) then 
			return true 
		end
    end
end
local function stanceDanceCast(spell, Unit, stance)

	---------------------------------
	-- Check Talent Mastery Talent --

	if rageDanceCheck then

		-----------------------
		-- Check WW Settings --

		if Setting("Whirlwind") and spell == "Rend" and Spell.Whirlwind:CD() == 0 then
			return true
		end

		--------------------------
		-- Check Debug Settings --

		if Setting("Debug") then
			if spell ~= prevs then
				print("spell = "..tostring(spell).." , Unit = ".. tostring(Unit) .. " , stance = "..tostring(stance))
				prevs = spell
			end
		end

		-------------------------------------
		-- Check required Stance and Dance --

        if stance == 1 then
            if Spell.StanceBattle:Cast() then end
        elseif stance == 2 then
            if Spell.StanceDefense:Cast() then end
        elseif stance == 3 then
            if Spell.StanceBers:Cast() then end
        end
    end
end
local function smartCast(spell, Unit, pool)
	-------------------------------
	-- Check Pooling requirement --

	if pool and Spell[spell]:Cost() > Player.Power then
		if spell == "SweepStrikes" and not select(2,GetShapeshiftFormInfo(1)) then
            Spell.StanceBattle:Cast()
        end
		return true
	end

	------------------------------
	-- Check Anti Waste Setting --

	if Setting("Dont waste more then 5 rage when Dancing") and Player.Power >= 31 then
		if DumpBeforeDance(Player.Power - 25, spell) then
			return true
		end
	end

	-------------------------------------------
	-- Prevent Dancing for Rend from Berserk --

	--if Setting("Whirlwind") and spell == "Rend" and Spell.Whirlwind:CD() == 0 then
	--	return true
	--end

	timer = DMW.Time
	
	---------------------------------------
	-- Check required Stance to Dance to --

	if select(2,GetShapeshiftFormInfo(1)) then
		if not stanceCheckBattle[spell] then
			if stanceCheckDefence[spell] then
				stanceDanceCast(spell, Unit, 2)
			elseif stanceCheckBers[spell] then
				stanceDanceCast(spell, Unit, 3)
			else
				if Spell[spell]:Cast(Unit) then return true end
			end
		else
			if Spell[spell]:Cast(Unit) then return true end
		end
	elseif select(2,GetShapeshiftFormInfo(3)) then
		if not stanceCheckBers[spell] then
			if stanceCheckBattle[spell] then
				stanceDanceCast(spell, Unit, 1)
			elseif stanceCheckDefence[spell] then
				stanceDanceCast(spell, Unit, 2)
			else
				if Spell[spell]:Cast(Unit) then return true end
			end
		else
			if Spell[spell]:Cast(Unit) then return true end
		end
	elseif select(2,GetShapeshiftFormInfo(2)) then
		if not stanceCheckDefence[spell] then
			if stanceCheckBattle[spell] then
				stanceDanceCast(spell, Unit, 1)
			elseif stanceCheckBers[spell] then
				stanceDanceCast(spell, Unit, 3)
			else
				if Spell[spell]:Cast(Unit) then return true end
			end
		else
			if Spell[spell]:Cast(Unit) then return true end
		end
	end
end
local function DebugSettings()
	-------------------
	-- Debug Setting --

	if not Player.Combat and Setting("Debug") then
		if not prevs == nil then  
			prevs = nil
		end
		if not prev == nil then
			prev = nil
		end
	end
end
local function Pace()
	------------------------
	-- control dance pace --

	if DMW.Time <= timer + 0.2 then 
		return true 
	end
end
local function Dumping()	
	if Setting("Whirlwind") and Spell.Whirlwind:Known() then
		if Player.Power >= Setting("Rage Dump") and Player.SwingLeft <= 0.4 then
			if Spell.Whirlwind:CD() == 0 and select(2,GetShapeshiftFormInfo(3)) and Target.Distance <= 8 then
				if regularCast("Whirlwind", Player) then
					return true
				end
				if Setting("MortalStrike") and Target.Distance <= 8 and Spell.MortalStrike:Known() and Spell.MortalStrike:CD() == 0 then
					if regularCast("MortalStrike", Target, true) then
						return true
					end
				end
			else
				if not IsCurrentSpell(845) and not IsCurrentSpell(285) then
					if #Player:GetEnemies(5) >= 2 and Spell.Cleave:Known() then
						if regularCast("Cleave",Target,true) then
							return true
						end
					else
						if regularCast("HeroicStrike",Target,true) then
							return true
						end
					end
				end
			end
		end
	end
	if not Setting("Whirlwind") then
		if Player.Power >= Setting("Rage Dump") and Player.SwingLeft <= 0.4 then
			if not IsCurrentSpell(845) or not IsCurrentSpell(285) then
				if #Player:GetEnemies(5) >= 2 and Spell.Cleave:Known() then
					if regularCast("Cleave",Target,true) then
						return true
					end
				else
					if regularCast("HeroicStrike",Target,true) then
						return true
					end
				end
			end
		end
	end
end
local function Cooldowns()
	---------------------
	-- SweepingStrikes --
	if Setting("SweepingStrikes") and #Player:GetEnemies(8) >= 2 and Spell.SweepStrikes:CD() == 0 and Spell.SweepStrikes:Known() then
		if smartCast("SweepStrikes",Player, true) then
			return true
		end
	end
	---------------
	-- Bloodrage --
	if Setting("Bloodrage") and Spell.Bloodrage:IsReady() and HP >= 50 and Spell.Bloodrage:Known() then
		regularCast("Bloodrage", Player)
	end
	---------------
	-- Bers Rage --
	if Setting("BersRage") and Spell.BersRage:CD() == 0 and Target.TTD >= 4 and Spell.BersRage:Known() then
		smartCast("BersRage", Player)
	end
end
local function Defense()
	--------------------
	-- Defence Stance --
	
	if Setting("Use Defense Stance") and #Player:GetEnemies(5) >= 1 and not select(2,GetShapeshiftFormInfo(2)) and Spell.StanceDefense:Known() then
		if regularCast("StanceDefense", Player) then
			return true
		end
	end
	
	------------------
	-- Shield Block --
	
	if Setting("Use ShieldBlock") and HP < Setting("Shieldblock HP") and #Player:GetEnemies(5) >= 1 and Spell.ShieldBlock:Known() then
		if smartCast("ShieldBlock", Player) then
			return true
		end
	end
	
	-----------------
	-- Retaliation -- 
	
	if Setting("Retaliation") and Spell.Retaliation:Known() and ((HP <=35 and Spell.Retaliation:CD() == 0) or (HP <=70 and Spell.Retaliation:CD() == 0 and #Player:GetEnemies(5) >= 2)) then
		if smartCast("Retaliation", Player) then
			return true
		end
	end

	----------------
	-- ShieldWall --	

	if Setting("ShieldWall") and HP <= Setting("Use ShieldWall at # % HP") and Spell.ShieldWall:CD() == 0 and Spell.ShieldWall:Known() then
		if smartCast("ShieldWall",Player) then
			return true
		end
	end

	----------------
	-- LastStand --

	if Setting("LastStand") and HP <= Setting("Use LastStand at # % HP") and Spell.LastStand:CD() == 0 and Spell.LastStand:Known() then
		if regularCast("LastStand",Player) then
			return true
		end
	end
end
local function ReturnToBattle()
	if not select(2,GetShapeshiftFormInfo(1)) and Setting("Return to Battle Stance") and not Player.Combat and Spell.StanceBattle:Known() then
		if regularCast("StanceBattle", Player) then
			return true
		end
	end
end
local function AutoTarget()
	if Player.Combat and not (Target and Target.ValidEnemy) and #Player:GetEnemies(5) >= 1 and  Setting("AutoTarget") then
		TargetUnit(DMW.Attackable[1].unit)
	end
end
local function StartAA()
	if not IsCurrentSpell(6603) and Target.Distance <= 5 then
		StartAttack(Target.Pointer)
	end
end
local function Opener()
	------------
	-- CHARGE --
	
	if Setting("Charge") and not Player.Combat and Target.Distance <= 25 and Target.Distance >= 8 and HP >= 40 and Spell.Charge:Known() then
		if smartCast("Charge", Target) then
			return true 
		end
	end

	if Player.Combat and Setting("Intercept") and select(2,GetShapeshiftFormInfo(3)) and Spell.Intercept:CD() == 0 and Target.Distance <= 25 and Target.Distance >= 8 then
		if regularCast("Intercept", Target) then
			return true 
		end
	end
		
	---------------
	-- Hamstring --
	if Setting("Hamstring on low mob") and Player.Combat and Spell.Hamstring:Known() and Target.HP <= 30 and Target.Distance <= 5 and not Debuff.Hamstring:Exist(Target) and not (#Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0) then
		if smartCast("Hamstring", Target, true) then
			return true
		end
	end

	--------------------
	-- Use BersStance --

	if Setting("Use Berserk Stance") and Player.Combat and not select(2,GetShapeshiftFormInfo(3)) and Spell.Charge:CD() >= 11 and #Target:GetEnemies(20) == 1 and Spell.StanceBers:Known() then
        if regularCast("StanceBers", Player) then
			return true
		end
	elseif Setting("Use Berserk Stance") and Player.Combat and not select(2,GetShapeshiftFormInfo(3)) and Spell.Charge:CD() >= 11 and #Target:GetEnemies(8) >= 2 and Spell.SweepStrikes:Known() then
		if smartCast("SweepStrikes", Player, true) then
			return true
		end
	end
end
local function Buffing()
	-----------------
	-- Battleshout --
	
	if Setting("BattleShout") and not Buff.BattleShout:Exist(Player) and Spell.BattleShout:Known() then
		if regularCast("BattleShout", Player, true) then
			return true
		end
	end
end
local function Interrupt()
	---------------
	-- Interrupt --
	if Target and Setting("Interrupt with Pummel") and Target:Interrupt() and Spell.Pummel:Known() and Spell.Pummel:CD() == 0 then
		if smartCast("Pummel",Target) then
			return true
		end
	end

	if Setting("Interrupt with Pummel") and Spell.Pummel:Known() and Spell.Pummel:CD() == 0 then
		for _, Unit in ipairs(Player:GetEnemies(15)) do
			if Unit:Interrupt() then
				if smartCast("Pummel",Unit) then
					return true
				end
			end
		end
	end
	if Target and Setting("Interrupt with ShieldBash") and Target:Interrupt() and Spell.ShieldBash:Known() and Spell.ShieldBash:CD() == 0 then
		if smartCast("ShieldBash",Target) then
			return true
		end
	end
	if Setting("Interrupt with ShieldBash") and Spell.ShieldBash:Known() and Spell.Pummel:CD() == 0 then
		for _, Unit in ipairs(Player:GetEnemies(15)) do
			if Unit:Interrupt() then
				if smartCast("ShieldBash",Unit) then
					return true
				end
			end
		end
	end
end
local function Combat()
	-------------------
	-- Berserkerrage --
	
	if select(2,GetShapeshiftFormInfo(3)) then
		if Setting("BersRage") and Spell.BersRage:CD() == 0 and Spell.BersRage:Known() then
			regularCast("BersRage",Player)
		end
	end
			
	---------------
	-- OVERPOWER --
	if #Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0 and Spell.Overpower:Known() then
		for _,Unit in ipairs(Player:GetEnemies(5)) do
			for i = 1, #Player.OverpowerUnit do
				if Unit.GUID == Player.OverpowerUnit[i].overpowerUnit then
					if smartCast("Overpower", Unit, true) then
						return true
					end
				end
			end 
		end
		return true
	end
			
	-------------
	-- REVENGE --
	if Spell.Revenge:IsReady() and Spell.Revenge:CD() == 0 and Spell.Revenge:Known() then
		for _,Unit in ipairs(Player:GetEnemies(5)) do
			if regularCast("Revenge", Unit, true) then
				return true
			end
		end
	end
			
	-------------	
	-- Execute --

	if Setting ("Execute") and Target.HP < 20 and Spell.Execute:Known() then
		if not select(2,GetShapeshiftFormInfo(1)) then
			if smartCast("Execute", Target, true) then
				return true
			end
		else
			if regularCast("Execute", Target, true) then
				return true
			end
		end
	end
			
	---------------------
	-- MortalStrike --
		
	if Setting ("MortalStrike") and ((Spell.SweepStrikes:CD() >= .1 and Spell.Whirlwind:CD() >= .1) or #Player:GetEnemies(20) == 1) and Spell.MortalStrike:Known() then
		if regularCast("MortalStrike",Target, true) then
			return true
		end
	end
			
	-----------------
	-- Whirlwind# --
			
	if Setting("MortalStrike") then
		if Target.Distance <= 8 and Setting("Whirlwind") and (#Target:GetEnemies(20) == 1 and Spell.MortalStrike:CD() >= .01) or (#Target:GetEnemies(20) >= 2 and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1)) then
			if Spell.Whirlwind:CD() == 0 and Target.HP >= 20 and Spell.Whirlwind:Known() then
				if smartCast("Whirlwind", Player) then
					return true
				end
			end
		end
	else
		if Target.Distance <= 8 and Setting("Whirlwind") and #Target:GetEnemies(20) == 1 or (#Target:GetEnemies(20) >= 2 and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1)) then
			if Spell.Whirlwind:CD() == 0 and Target.HP >= 20 and Spell.Whirlwind:Known() then
				if smartCast("Whirlwind", Player) then
					return true
				end
			end
		end
	end
			
	---------------
	-- Hamstring --
			
	if Target.Player and Spell.Hamstring:IsReady() and not Debuff.Hamstring:Exist(Target) and Spell.Hamstring:Known() then
		if smartCast("Hamstring",Target) then
			return true
		end
	end
	
	-------------
	-- Disarm --
			
	if Setting("Use Disarm") then
		if Target.Player and Spell.Disarm:CD() == 0 and Debuff.Hamstring:Exist(Target) and Spell.Disarm:Known() then
			if smartCast("Disarm",Target, true) then
				return true
			end
		end
	end
	
	----------
	-- REND --

	if Setting("Rend") and not RendImmune[Target.CreatureType] and Spell.Rend:Known() then
		if Setting("Spread Rend") then
			for _,Unit in ipairs(Player:GetEnemies(5)) do
				if not Debuff.Rend:Exist(Unit) and Unit.TTD >= 4 then
					if smartCast("Rend", Unit, true) then
						return true
					end
				end
			end
		end
		if not Setting("Spread Rend") and Target.TTD >= 4 and not Debuff.Rend:Exist(Target) then
			if smartCast("Rend", Target, true) then
				return true
			end
		end
	end

	------------
	-- SUNDER --
			
	if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not SunderImmune[Target.CreatureType] and Spell.SunderArmor:Known() then
		if Setting("Spread Sunder") then
			for _,Unit in ipairs(Player:GetEnemies(5)) do
				if Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") and Unit.TTD >= 4 then
					if regularCast("SunderArmor",Unit,true) then
						return true
					end
				end
			end
		end
		if not Setting("Spread Sunder") then
			if Debuff.SunderArmor:Stacks(Target) < Setting("Apply # Stacks of Sunder Armor") and Target.TTD >= 4 then
				if regularCast("SunderArmor",Target,true) then
					return true
				end
			end
		end	
	end
			
	------------------------
	-- Demoralizing Shout --
		
	if Setting("Demoralizing Shout") and Spell.DemoShout:Known() and not Debuff.DemoShout:Exist(Target) and #Player:GetEnemies(10) >= Setting("Min targets for Demoralizing Shout") then
		if regularCast("DemoShout",Target,true) then
			return true
		end
	end
			
	------------------
	-- Thunder Clap -- 
			
	if Setting("ThunderClap") and Spell.ThunderClap:Known() and #Player:GetEnemies(5) >= Setting("Min targets for Thunderclap") and not Debuff.ThunderClap:Exist(Target) and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1) then
		if smartCast("ThunderClap", Target, true) then
			return true
		end
	end
end
local function TestingMode()
 	if Target and Player.Combat then
		if #Player:GetEnemies() >= Setting("Testing above") then
			if Player:GCDRemain() > 0 then
				smartCast("ShieldBlock",Player)
			end
			if regularCast("DemoShout",Player) then
				return true
			end
		end
	end
end

function Warrior.Rotation()
	Locals()
	
	DebugSettings()
	
	if Setting("Skip Ravenger") and select(8, ChannelInfo("Player")) == 9632 and #Player:GetEnemies(8) <= 1 then
		RunMacroText("/stopcasting")
	end
	
	if Pace() then
		return true
	end

	if Interrupt() then
		return true
	end
	
	if ReturnToBattle() then
		return true
	end

	AutoTarget()

	if Target and Target.ValidEnemy and Target.Health > 1 then
		
		if Defense() then
			return true
		end
		
		if Setting("TestingMode") then
			if TestingMode() then
				return true
			end
		end

		if Opener() then
			return true
		end
		
		if StartAA() then
			return true
		end

		if Player.Combat then	
			
			if Buffing() then
				return true
			end
			
			if Cooldowns() then
				return true
			end

			if Combat() then
				return true
			end

			if Dumping() then
				return true
			end
		end -- if Combat end
	end -- if valid target end
end -- Rotation end