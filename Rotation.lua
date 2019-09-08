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
	["Undead"] = true,
	["Elemental"] = true,
	["Totem"] = true,
	["Mechanical"] = true
}
local SunderImmune = {
	["Totem"] = true,
	["Mechanical"] = true
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
	["MortalStrike"] = true,
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
	if Setting("Debug") then
		if (value ~= prev) then
			print("Dumping "..tostring(value).." Rage - Current: "..tostring(Player.Power).." Rage - to cast spell: "..tostring(spell))
			prev = value
		end
	end
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
	if rageDanceCheck then
		if Setting("Whirlwind") and spell == "Rend" and Spell.Whirlwind:CD() == 0 then
			return true
		end
		if Setting("Debug") then
			if spell ~= prevs then
				print("spell = "..tostring(spell).." , Unit = ".. tostring(Unit) .. " , stance = "..tostring(stance))
				prevs = spell
			end
		end
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
    if pool and Spell[spell]:Cost() > Player.Power then
		if spell == "SweepStrikes" and not select(2,GetShapeshiftFormInfo(1)) then
            Spell.StanceBattle:Cast()
        end
		return true
	end
	if Setting("Dont waste more then 5 rage when Dancing") and Player.Power >= 31 then
		if DumpBeforeDance(Player.Power - 25, spell) then
			return true
		end
	end
	if Setting("Whirlwind") and spell == "Rend" and Spell.Whirlwind:CD() == 0 then
		return true
	end

	timer = DMW.Time
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

function Warrior.Rotation()
	Locals()
	if not Player.Combat and Setting("Debug") then
		if not prevs == nil then  
			prevs = nil
		end
		if not prev == nil then
			prev = nil
		end
	end

	if DMW.Time <= timer + 0.3 then 
		return true 
	end
	-------------------------
	--ReturnToBattleStance --
	
	if not select(2,GetShapeshiftFormInfo(1)) and Setting("Return to Battle Stance") and not Player.Combat then
		if regularCast("StanceBattle", Player) then
			return true
		end
	end

	--------------------------------------------------------------------------------------		
	------------------------------------- Targeting --------------------------------------
	--------------------------------------------------------------------------------------
	
	if Player.Combat and not (Target and Target.ValidEnemy) and #Player:GetEnemies(5) >= 1 and  Setting("AutoTarget") then
			TargetUnit(DMW.Attackable[1].unit)
	end
	
	--------------------------------------------------------------------------------------		
	------------------------------------- Opening ----------------------------------------
	--------------------------------------------------------------------------------------
	
	if Target and Target.ValidEnemy and Target.Health > 1 then
		------------
		-- CHARGE --
		
		if Setting("Charge") and not Player.Combat and Target.Distance <= 25 and Target.Distance >= 8 and HP >= 40 then
			if smartCast("Charge", Target) then
				return true 
			end
		end
		
		---------------
		-- Hamstring --

		if Setting("Hamstring on low mob") and Player.Combat and Target.HP <= 30 and Target.Distance <= 5 and not Debuff.Hamstring:Exist(Target) and not (#Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0) then
			smartCast("Hamstring", Target, true)
			return true
		end

		--------------------
		-- Use BersStance --

		if Setting("Use Berserk Stance") and Player.Combat and not select(2,GetShapeshiftFormInfo(3)) and Spell.Charge:CD() >= 11 and #Target:GetEnemies(20) == 1 then
            if regularCast("StanceBers", Player) then
				return true
			end
		elseif Setting("Use Berserk Stance") and Player.Combat and not select(2,GetShapeshiftFormInfo(3)) and Spell.Charge:CD() >= 11 and #Target:GetEnemies(8) >= 2 then
			if smartCast("SweepStrikes", Player, true) then
				return true
			end
		end

		-----------------
		-- Auto Attack --
		
		if not IsCurrentSpell(6603) and Target.Distance <= 5 then
			StartAttack(Target.Pointer)
		end
		
		
		
	--------------------------------------------------------------------------------------	
	------------------------------------- Preparation ------------------------------------
	--------------------------------------------------------------------------------------
	if Player.Combat then	
			-----------------
			-- Battleshout --
			
			if Setting("BattleShout") and not Buff.BattleShout:Exist(Player) then
				if regularCast("BattleShout", Player, true) then
					return true
				end
			end

			---------------
			-- Interrupt --
			
			if Setting("Interrupt with Pummel") and Spell.Pummel:Known() then
				for _, Unit in ipairs(Player:GetEnemies(15)) do
					if Unit:Interrupt() then
						if smartCast("Pummel",Unit,true) then
							return true
						end
					end
				end
			end
			---------------------
			-- SweepingStrikes --
			
			if Setting("SweepingStrikes") and #Player:GetEnemies(8) >= 2 and Spell.SweepStrikes:CD() == 0 then
				if smartCast("SweepStrikes",Player, true) then
					return true
				end
			end
			
			---------------
			-- Bloodrage --
			if Setting("Bloodrage") and Spell.Bloodrage:IsReady() and HP >= 50 then
				regularCast("Bloodrage", Player)
			end

			---------------
			-- Bers Rage --
			if Setting("BersRage") and Spell.BersRage:CD() == 0 and Target.TTD >= 4 then
				smartCast("BersRage", Player)
			end

		------------------	
		--DEFENSE PHASE---
		------------------
		
			--------------------
			-- Defence Stance --
			if Setting("Use Defense Stance") and #Player:GetEnemies(5) >= 1 and not select(2,GetShapeshiftFormInfo(2)) then
				if regularCast("StanceDefense", Player) then
					return true
				end
			end
			
			------------------
			-- Shield Block --
			
			if Setting("Use ShieldBlock") and HP < Setting("Shieldblock HP") and #Player:GetEnemies(5) >= 1 then
				if smartCast("ShieldBlock", Player) then
					return true
				end
			end
			
			-----------------
			-- Retaliation -- 
			
			if Setting("Retaliation") and ((HP <=35 and Spell.Retaliation:CD() == 0) or (HP <=70 and Spell.Retaliation:CD() == 0 and #Player:GetEnemies(5) >= 2)) then
				if smartCast("Retaliation", Player) then
					return true
				end
			end
	--------------------------------------------------------------------------------------		
	------------------------------------- COMBAT -----------------------------------------
	--------------------------------------------------------------------------------------
			
			-------------------
			-- Berserkerrage --
			
			if select(2,GetShapeshiftFormInfo(3)) then
				if Setting("BersRage") and Spell.BersRage:CD() == 0 then
					regularCast("BersRage",Player)
				end
			end
			
			---------------
			-- OVERPOWER --
			if #Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0 then
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
			if Spell.Revenge:IsReady() and Spell.Revenge:CD() == 0 then
				for _,Unit in ipairs(Player:GetEnemies(5)) do
					if regularCast("Revenge", Unit, true) then
						return true
					end
				end
			end
			
			-------------	
			-- Execute --

			if Setting ("Execute") and Target.HP < 20 then
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
			
			if Setting ("MortalStrike") and ((Spell.SweepStrikes:CD() >= .1 and Spell.Whirlwind:CD() >= .1) or #Player:GetEnemies(20) == 1) then
				if smartCast("MortalStrike",Target,true) then
					return true
				end
			end
			
			-----------------
			-- Whirlwind# --
			
			if Setting("MortalStrike") then
				if Target.Distance <= 8 and Setting("Whirlwind") and (#Target:GetEnemies(20) == 1 and Spell.MortalStrike:CD() >= .01) or (#Target:GetEnemies(20) >= 2 and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1)) then
					if Spell.Whirlwind:CD() == 0 and Target.HP >= 20 then
						if smartCast("Whirlwind", Player) then
							return true
						end
					end
				end
			else
				if Target.Distance <= 8 and Setting("Whirlwind") and #Target:GetEnemies(20) == 1 or (#Target:GetEnemies(20) >= 2 and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1)) then
					if Spell.Whirlwind:CD() == 0 and Target.HP >= 20 then
						if smartCast("Whirlwind", Player) then
							return true
						end
					end
				end
			end
			
			---------------
			-- Hamstring --
			
			if Target.Player and Spell.Hamstring:IsReady() and not Debuff.Hamstring:Exist(Target) then
				if smartCast("Hamstring",Target) then
					return true
				end
			end
			
			-------------
			-- Disarm --
			
			if Spell.Disarm:CD() == 0 and Debuff.Hamstring:Exist(Target) then
				if smartCast("Disarm",Target, true) then
					return true
				end
			end
		
			----------
			-- REND --

			if Setting("Rend") and not RendImmune[Target.CreatureType] then
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
			
			if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not SunderImmune[Target.CreatureType] then
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
			
			if Setting("Demoralizing Shout") and not Debuff.DemoShout:Exist(Target) and #Player:GetEnemies(10) >= Setting("Min targets for Demoralizing Shout") then
				if regularCast("DemoShout",Target,true) then
					return true
				end
			end
			
			------------------
			-- Thunder Clap -- 
			
			if Setting("ThunderClap") and #Player:GetEnemies(5) >= Setting("Min targets for Thunderclap") and not Debuff.ThunderClap:Exist(Target) and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1) then
				if smartCast("ThunderClap", Target, true) then
					return true
				end
			end
		
			----------
			-- DUMP --		
			if Setting("Whirlwind") then
				if Player.Power >= Setting("Rage Dump") and Player.SwingLeft <= 0.4 then
					if Spell.Whirlwind:CD() == 0 and select(2,GetShapeshiftFormInfo(3)) then
						if regularCast("Whirlwind", Player) then
							return true
						end
					else
						if not IsCurrentSpell(845) and not IsCurrentSpell(285) then
							if #Player:GetEnemies(5) >= 2 then
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
						if #Player:GetEnemies(5) >= 2 then
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
		end -- if Combat end
	end -- if valid target end
end -- Rotation end