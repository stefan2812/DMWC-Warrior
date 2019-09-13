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
	if pool then 
		if spell == "Execute" then
			if (Spell[spell]:Cost() + 5) > Player.Power then
				return true
			end
		else
			if Spell[spell]:Cost() > Player.Power then
				return true
			end
		end
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
				if Setting ("DumpUpSunder") and not SunderImmune[Target.CreatureType] and Debuff.SunderArmor:Stacks(Target) < 5 then
					if regularCast("SunderArmor",Target) then
						print("DumpUpSunder")
						return true
					end
				else
					if regularCast("HeroicStrike",Target) then
						return true
					end
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
				print("Spell = "..tostring(spell).." , RagePre = "..tostring(Player.Power).." , RagePost = "..tostring(Player.Power - Spell[spell]:Cost()).." , Stance = "..tostring(stance))
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

	if Setting("Dont waste RAGE") and Player.Power >= 31 then
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
	-- Ccontrol dance pace --
	if DMW.Time <= timer + 0.2 then 
		return true 
	end
end
local function Defense()
	-- Defence Stance --
	if Setting("Use Defense Stance") and #Player:GetEnemies(5) >= 1 and not select(2,GetShapeshiftFormInfo(2)) and Spell.StanceDefense:Known() then
		if regularCast("StanceDefense", Player) then
			return true
		end
	end
	-- Shield Block --
	if Setting("Use ShieldBlock") and HP < Setting("Shieldblock HP") and #Player:GetEnemies(5) >= 1 and Spell.ShieldBlock:Known() then
		if smartCast("ShieldBlock", Player) then
			return true
		end
	end
	-- Retaliation -- 
	if Setting("Retaliation") and Spell.Retaliation:Known() and ((HP <=35 and Spell.Retaliation:CD() == 0) or (HP <=70 and Spell.Retaliation:CD() == 0 and #Player:GetEnemies(5) >= 2)) then
		if smartCast("Retaliation", Player) then
			return true
		end
	end
	-- ShieldWall --	
	if Setting("Use ShieldWall") and HP <= Setting("ShieldWall HP") and Spell.ShieldWall:CD() == 0 and Spell.ShieldWall:Known() then
		if smartCast("ShieldWall",Player) then
			return true
		end
	end
	-- LastStand --
	if Setting("Use LastStand") and HP <= Setting("LastStand HP") and Spell.LastStand:CD() == 0 and Spell.LastStand:Known() then
		if regularCast("LastStand",Player) then
			return true
		end
	end
end
local function ReturnToBattle()
	-- Return to Battle Stance --
	if not select(2,GetShapeshiftFormInfo(1)) and Setting("Return to Battle Stance after Combat") and not Player.Combat and Spell.StanceBattle:Known() then
		if regularCast("StanceBattle", Player) then
			return true
		end
	end
end
local function AutoTarget()
	-- Auto Targeting --
	if Player.Combat and not (Target and Target.ValidEnemy) and #Player:GetEnemies(5) >= 1 and  Setting("AutoTarget") then
		TargetUnit(DMW.Attackable[1].unit)
	end
end
local function Buffing()
	-- Battleshout --
	if Player.Combat then
		if not Buff.BattleShout:Exist(Player) and Spell.BattleShout:Known() then
			if regularCast("BattleShout", Player, true) then
				return true
			end
		end
		if Setting("Demo Shout") and not Debuff.DemoShout:Exist(Target) then
			if #Player:GetEnemies(5) >= Setting ("Demo Shout at/above") then
				if regularCast("DemoShout",Target) then
					return true
				end
			end
		end
	end
end
local function Interrupt()
	-- Interrupt Target with Pummel --
	if Target and Setting("Use Pummel") and Target:Interrupt() and Spell.Pummel:Known() and Spell.Pummel:CD() == 0 then
		if smartCast("Pummel",Target) then
			return true
		end
	end
	-- Interrupt surroundings with Pummel --
	if Setting("Use Pummel") and Spell.Pummel:Known()and Spell.Pummel:CD() == 0 then
		for _, Unit in ipairs(Player:GetEnemies(15)) do
			if Unit:Interrupt() then
				if smartCast("Pummel",Unit) then
					return true
				end
			end
		end
	end
	-- Interrupt Target with ShieldBash --
	if Target and Setting("Use ShieldBash") and Target:Interrupt() and Spell.ShieldBash:Known() and Spell.ShieldBash:CD() == 0 then
		if smartCast("ShieldBash",Target) then
			return true
		end
	end
	-- Interrupt surroundings with Pummel --
	if Setting("Use ShieldBash") and Spell.ShieldBash:Known() and Spell.ShieldBash:CD() == 0 then
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
	if not Player.Combat and Target and Target.ValidEnemy then
		if Setting("Use Charge") and Target.Distance >= 8 and Target.Distance <= 25 then
			if smartCast("Charge", Target) then 
				return true
			end
		end
	end
	if Player.Combat and Target and Target.ValidEnemy and Target.Health > 1 then
		-- Sweeping Strikes --
		if Setting("SweepingStrikes") then
			if Spell.SweepStrikes:Known() and Spell.SweepStrikes:CD()== 0 and #Player:GetEnemies(5) >= 2 then
				--if Setting("Debug") then
				--	PlaySound(416)
				--	print("Casting SweepStrikes because :"..tostring(#Player:GetEnemies(5)).." Enemies within 5yds")
				--end
				if smartCast("SweepStrikes",Player,true) then
					return true
				end
			end
		end
		if not IsCurrentSpell(6603) and Target.Distance <= 5 then
			StartAttack(Target.Pointer)
		end
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
		-- REVENGE --
		if Spell.Revenge:IsReady() and Spell.Revenge:CD() == 0 and Spell.Revenge:Known() then
			for _,Unit in ipairs(Player:GetEnemies(5)) do
				if regularCast("Revenge", Unit, true) then
					return true
				end
			end
		end
		-- Execute --
		if Target.HP < 20 then
			if Setting("Execute") and Spell.Execute:Known()	then
				if select(2,GetShapeshiftFormInfo(2)) then
					if smartCast("Execute", Target, true) then
						return true
					end
				else
					if regularCast("Execute", Target, true) then
						return true
					end
				end
			elseif not Setting("Execute") then
				if regularCast("HeroicStrike",Target,true)  then
					return true
				end
			end
		end
		-- Bloodrage --
		if Setting("Bloodrage") and Spell.Bloodrage:IsReady() then
			regularCast("Bloodrage", Player)
		end
		-- Bers Rage --
		if Setting("Berserker Rage") and Spell.BersRage:CD() == 0 and Target.TTD >= 4 and Spell.BersRage:Known() then
			smartCast("BersRage", Player)
		end
		-- Intercept --
		if Setting("Use Intercept") and Spell.Intercept:CD() == 0 and Target.Distance >= 8 and Target.Distance <= 25 and Player.Power >= 10 and Player.Power <= 25 then
			if smartCast("Intercept",Target,true) then
				return true
			end
		end
		-- Hamstring --
		if Setting("Hamstring < 30% Enemy HP") and Player.Combat and Spell.Hamstring:Known() and Target.HP <= 30 and Target.Distance <= 5 and not Debuff.Hamstring:Exist(Target) and not (#Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0) then
			if smartCast("Hamstring", Target, true) then
				return true
			end
		end
		-- Mortalstrike --
		if Setting("MortalStrike") and Spell.MortalStrike:Known() and Spell.MortalStrike:CD() == 0 then
			if regularCast("MortalStrike",Target, true) then
				return true
			end
		end
		-- SunderArmor --
		if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not SunderImmune[Target.CreatureType] then
			if Debuff.SunderArmor:Stacks(Target) < Setting("Apply # Stacks of Sunder Armor") and Target.TTD >= 2 then
				if regularCast("SunderArmor",Target,true) then
					return true
				end
			end
		end
		-- Rend --
		if Setting("Rend") and Spell.Rend:Known() and not RendImmune[Target.CreatureType] then
			if Target.TTD >= 2 and not Debuff.Rend:Exist(Target) then
				if smartCast("Rend",Target,true) then
					return true
				end
			end
			if Setting("Spread Rend") and #Player:GetEnemies(5) >= 2 then
				for _,Unit in ipairs(Player:GetEnemies(5)) do
					if not RendImmune[Unit.CreatureType] then
						if Unit.TTD >= 2 and not Debuff.Rend:Exist(Unit) then
							if smartCast("Rend",Unit,true) then
								return true
							end
						end
					end
				end
			end
		end
		-- Whirlwind -- 
		if Setting("Whirlwind") and Player.Power >= 25 and Spell.Whirlwind:Known() and Spell.Whirlwind:CD() == 0 then
			if smartCast("Whirlwind",Player,true) then
				return true
			end
		end
		if (Spell.Whirlwind:CD() > .1 or not Spell.Whirlwind:Known() or not Setting("Whirlwind")) and (Spell.MortalStrike:CD() > .1 or not Spell.MortalStrike:Known() or not Setting("MortalStrike")) and Player.Power >= Setting("Dump RAGE above") then
			if #Player:GetEnemies(5) >= 2 then
				if regularCast("Cleave",Target) then
					return true
				end
			else
				if Setting ("DumpUpSunder") and not SunderImmune[Target.CreatureType] and Debuff.SunderArmor:Stacks(Target) < 5 then
					if regularCast("SunderArmor",Target) then
						print("DumpUpSunder")
						return true
					end
				else
					if regularCast("HeroicStrike",Target) then
						return true
					end
				end
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

	if Buffing() then
		return true
	end

	if Defense() then
		return true
	end

	if Combat() then
		return true
	end

end -- Rotation end
