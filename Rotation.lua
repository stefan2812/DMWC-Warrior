local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, rageDanceCheck

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
  
    if select(2,GetShapeshiftFormInfo(1)) then
        Stance = "Battle"
    elseif select(2,GetShapeshiftFormInfo(2)) then
        Stance = "Defense"
    else
        Stance = "Bers"
    end
    if Talent.TacticalMastery.Rank >= 4 then
        rageDanceCheck = true
    else
        rageDanceCheck = false
    end

end

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
	["Cleave"] = true,
	["HeroicStrike"] = true,
	["MortalStrike"] = true,
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
	["Cleave"] = true,
	["HeroicStrike"] = true,
	["MortalStrike"] = true,
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
    ["Whirlwind"] = true,
	["Cleave"] = true,
	["HeroicStrike"] = true,
	["MortalStrike"] = true
    
}
local function stanceDanceCast(spell, Unit, stance)
    if rageDanceCheck then
        if stance == 1 then
            if Spell.StanceBattle:Cast() then end
        elseif stance == 2 then
            if Spell.StanceDefense:Cast() then end
        elseif stance == 3 then
            if Spell.StanceBers:Cast() then end
        end
    end
end
local function regularCast(spell, Unit, pool)
    if pool and Spell[spell]:Cost() > Player.Power then
        return true
    end
	if Spell[spell]:Cast(Unit) then
        return true
    end
end
local function smartCast(spell, Unit, pool)
    if pool and Spell[spell]:Cost() > Player.Power then
        return true
    end
 -- If in Battle
	if select(2,GetShapeshiftFormInfo(1)) then
		if stanceCheckBattle[spell] then
        if Stance == "Battle" then
            if Spell[spell]:Cast(Unit) then
                return true
            end
        else
            stanceDanceCast(spell, Unit, 1)
        end
		elseif stanceCheckDefence[spell] then
			if Stance == "Defense" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit, 2)
			end
		elseif stanceCheckBers[spell] then
			if Stance == "Bers" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit,3)
			end
		else
			if Spell[spell]:Cast(Unit) then
				return true
			end
		end
	end
	-- If in Defense
	if select(2,GetShapeshiftFormInfo(2)) then
		if stanceCheckDefence[spell] then
        if Stance == "Defense" then
            if Spell[spell]:Cast(Unit) then
                return true
            end
        else
            stanceDanceCast(spell, Unit, 2)
        end
		elseif stanceCheckBattle[spell] then
			if Stance == "Battle" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit, 1)
			end
		elseif stanceCheckBers[spell] then
			if Stance == "Bers" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit,3)
			end
		else
			if Spell[spell]:Cast(Unit) then
				return true
			end
		end
	end
	-- If in Berserk
	if select(2,GetShapeshiftFormInfo(3)) then
		if stanceCheckBers[spell] then
        if Stance == "Bers" then
            if Spell[spell]:Cast(Unit) then
                return true
            end
        else
            stanceDanceCast(spell, Unit, 3)
        end
		elseif stanceCheckBattle[spell] then
			if Stance == "Battle" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit, 1)
			end
		elseif stanceCheckDefence[spell] then
			if Stance == "Defense" then
				if Spell[spell]:Cast(Unit) then
					return true
				end
			else
				stanceDanceCast(spell, Unit,2)
			end
		else
			if Spell[spell]:Cast(Unit) then
				return true
			end
		end
	end
end

function Warrior.Rotation()
    Locals()
	-------------------------
	--ReturnToBattleStance --
	if not select(2,GetShapeshiftFormInfo(1)) and Setting("Return to Battle Stance") and not Player.Combat then
		if Spell.StanceBattle:Cast(Player) then
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
			smartCast("Charge", Target)
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
				regularCast("BattleShout", Player, true)
			end
			
			---------------
			-- Bloodrage --
			if Spell.Bloodrage:IsReady() and HP >= 50 then
				regularCast("Bloodrage", Player, true)
			end
			
		------------------	
		--DEFENSE PHASE---
		------------------
		
			--------------------
			-- Defence Stance --
			if Setting("Use Defense Stance") and #Player:GetEnemies(5) >= 1 and not select(2,GetShapeshiftFormInfo(2)) then
				regularCast("StanceDefense", Player, true)
			end
			
			------------------
			-- Shield Block --
			
			if Setting("Use ShieldBlock") and HP < Setting("Shieldblock HP") and #Player:GetEnemies(5) >= 1 then
				smartCast("ShieldBlock", Player)
			end
			
			-----------------
			-- Retaliation -- 
			
			if HP <=35 and Spell.Retaliation:IsReady() then
				smartCast("Retaliation", Player)
			end
--------------------------------------------------------------------------------------		
---------------------------------------- COMBAT --------------------------------------
--------------------------------------------------------------------------------------
			
			-------------------
			-- Berserkerrage --
			
			if Stance == "Bers" then
				if Spell.BersRage:IsReady() then
					regularCast("BersRage", Player, true)
				end
			end
			
			---------------
			-- OVERPOWER --
			if #Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0 then
				for _,Unit in ipairs(Player:GetEnemies(5)) do
					for i = 1, #Player.OverpowerUnit do
						if Unit.GUID == Player.OverpowerUnit[i].overpowerUnit then
							smartCast("Overpower", Unit, true)
						end
					end 
				end
				return true
			end
			
			-------------
			-- REVENGE --
			if Spell.Revenge:IsReady() and Spell.Revenge:CD() == 0 then
				for _,Unit in ipairs(Player:GetEnemies(5)) do
					regularCast("Revenge", Unit, true)
				end
			end
			
			-------------	
			-- Execute --
			if Setting ("Execute all enemies") then
				if Setting("Execute") then
					for _,Unit in ipairs(Player:GetEnemies(5)) do
						if Unit.HP < 20 and Unit.Distance < 5 then
							local oldTarget = Target and Target.Pointer or false
							TargetUnit(Unit.Pointer)
							if smartCast("Execute", Target, true) then
								if oldTarget ~= false then
									TargetUnit(oldTarget)
								end
							return true
							end
						end
					end
				end
			end
			if not Setting ("Execute all enemies") and Target.HP < 20 then
				smartCast("Execute", Target, true)
			end
			
			---------------------
			-- MortalStrike --
			
			if Setting ("MortalStrike") and ((Spell.SweepStrikes:CD() >= .1 and Spell.Whirlwind:CD() >= .1) or #Player:GetEnemies(5) == 1) then
				regularCast("MortalStrike",Target,true)
			end
			
			-----------------
			-- Whirlwind# --
			
			if #Target:GetEnemies(20) == 1 or (#Target:GetEnemies(20) >= 2 and (Buff.SweepStrikes:Exist(Player) or Spell.SweepStrikes:CD() >= .1)) then
				smartCast("Whirlwind", Target, true)
			end

			---------------------
			-- SweepingStrikes --
			
			if Setting("SweepingStrikes") and #Player:GetEnemies(5) >= 2 and Spell.SweepStrikes:CD() == 0 then
				smartCast("SweepStrikes",Player, true)
			end
			
			---------------
			-- Hamstring --
			
			if Target.Player and Spell.Hamstring:IsReady() and not Debuff.Hamstring:Exist(Target) then
				smartCast("Hamstring",Target)
			end
			
			-------------
			-- Disarm --
			
			if Spell.Disarm:CD() == 0 and Debuff.Hamstring:Exist(Target) then
				smartCast("Disarm",Target, true)
			end
		
			----------
			-- REND --
			
			if Setting("Rend") and Spell.Rend:IsReady() and not (Target.CreatureType == "Elemental" or Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem")then
				if Setting("Spread Rend") then
					for _,Unit in ipairs(Player:GetEnemies(5)) do
						if not Debuff.Rend:Exist(Unit) and Unit.TTD >= 15 then
							smartCast("Rend", Unit, true)
						end
					end
				end
				if not Setting("Spread Rend") and Target.TTD >= 15 and not Debuff.Rend:Exist(Target) then
					smartCast("Rend", Target, true)
				end
			end
			
			------------
			-- SUNDER --
			
			if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not (Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem") then
				if Setting("Spread Sunder") then
					for _,Unit in ipairs(Player:GetEnemies(5)) do
						if Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") and Unit.TTD >= 15 then
							regularCast("SunderArmor",Unit,true)
						end
					end
				end
				if not Setting("Spread Sunder") then
					if Debuff.SunderArmor:Stacks(Target) < Setting("Apply # Stacks of Sunder Armor") and Target.TTD >= 15 then
						regularCast("SunderArmor",Target,true)
					end
				end	
			end
			
			------------------------
			-- Demoralizing Shout --
			
			if Setting("Demoralizing Shout") and not Debuff.DemoShout:Exist(Target) and #Player:GetEnemies(10) >= Setting("Min targets for Demoralizing Shout") then
				regularCast("DemoShout",Target,true)
			end
			
			------------------
			-- Thunder Clap -- 
			
			if Setting("ThunderClap") and #Player:GetEnemies(5) >= Setting("Min targets for Thunderclap") and not Debuff.ThunderClap:Exist(Target) then
				smartCast("ThunderClap", Target, true)
			end
		
			----------
			-- DUMP --

			if Buff.SweepStrikes:Exist(Player) and Spell.Whirlwind:CD() >= .1 then
				regularCast("Cleave",Target,true)
			end
			
			if Setting("Whirlwind") then
				if Player.Power >= Setting("Rage Dump") and Player.SwingLeft <= 0.2 and Spell.Whirlwind:CD() >= .1 and Spell.SweepStrikes:CD() >= .1 then
					if not IsCurrentSpell(845) and not IsCurrentSpell(285) then
						if #Player:GetEnemies(5) >= 2 then
							regularCast("Cleave",Target,true)
						else
							regularCast("HeroicStrike",Target,true)
						end
					end
				end
			end
			if not Setting("Whirlwind") then
				if Player.Power >= Setting("Rage Dump") then
					if not IsCurrentSpell(845) or not IsCurrentSpell(285) then
						if #Player:GetEnemies(5) >= 2 then
							regularCast("Cleave",Target,true)
						else
							regularCast("HeroicStrike",Target,true)
						end
					end
				end
			end
		end -- if Combat end
	end -- if valid target end
end -- Rotation end