local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, Enemy5Y, Enemy5YC, rageDanceCheck

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
    Enemy5Y, Enemy5YC = Player:GetEnemies(5)
  
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
    ["Taunt"] = true
}
local stanceCheckBers = {
    ["BersRage"] = true,
	["SunderArmor"] = true,
    ["Hamstring"] = true,
    ["Intercept"] = true,
    ["Pummel"] = true,
    ["Recklessness"] = true,
    ["Whirlwind"] = true,
	["Cleave"] = true,
	["HeroicStrike"] = true,
    ["Execute"] = true
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
     else
         return end
     end
local function smartCast(spell, Unit)
    -- If in Battle
	if Stance == "Battle" then
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
	if Stance == "Defense" then
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
	if Stance == "Bers" then
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

local function BuffPhase()
	-- Battleshout --
	if Setting("BattleShout") and not Buff.BattleShout:Exist(Player) then
		smartCast("BattleShout",Player)
	end
	--Bloodrage
	if Spell.Bloodrage:IsReady() and HP >= 50 then
		if Spell.Bloodrage:Cast(Target) then
			return true
		end
	end
end
local function DefensePhase()
	-- Defence Stance --
	if Setting("Use Defense Stance") and #Enemy5Y >= 1 and Player.Combat then
		if Spell.StanceDefense:Cast(Player) then
			return
		end
	end
	-- Shield Block ---
	if Setting("Use ShieldBlock") and Player.HP < Setting("Shieldblock HP") and #Enemy5Y >= 1 and Player.Combat then
		smartCast("ShieldBlock")
	end
end
local function CombatPhase1()
	-- Berserkerrage --
	if Stance == "Bers" then
		if Player.Combat and Target and Target.ValidEnemy then
			if Spell.BersRage:Cast(Target) then
			return
			end
		end
	end
	-- Whirlwind#1 --
	if Player.Combat and #Target:GetEnemies(20) == 1 then
		smartCast("Whirlwind")
	end
	-- SweepingStrikes --
	if Player.Combat and Setting("SweepingStrikes") and #Player:GetEnemies(5) >= 2 then
		smartCast("SweepStrikes",Player)
	end
	-- Whirlwind#2 --
	if Player.Combat and #Target:GetEnemies(20) >= 2 and Buff.SweepStrikes:Exist(Player) then
		smartCast("Whirlwind")
	end		
	-- Execute --
	if Setting("Execute") and Target.HP <= 20 and Player.Power >= 15 then
		if Player.HP >= 40 and Player.Power <= 15 and Spell.Bloodrage:IsReady() and Spell.Bloodrage:Cast(Player) then
			return
		end
		smartCast("Execute", Target)
	end
	-- OVERPOWER --
	if Setting("Overpower") and not Player.overpowerTime == false and Player.Power >= 5 and Spell.Overpower:CD() == 0 then
		smartCast("Overpower", Target)
	end
	-- REVENGE --
	if Setting("Revenge") and not Player.revengeTime == false and Player.Power >= 5 and Spell.Revenge:CD() == 0 then
		smartCast("Revenge", Target)
	end
	-- Hamstring
	if Target.Player and Spell.Hamstring:IsReady() and not Debuff.Hamstring:Exist(Target) then
		smartCast("Hamstring",Target)
	end
	-- Disarm
	if Target.Player and Spell.Disarm:IsReady() then
		smartCast("Disarm",Target)
	end
end
local function CombatPhase2()
	-- REND --
	if Setting("Rend") and Spell.Rend:IsReady() and not (Target.CreatureType == "Elemental" or Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem")then
		if Setting("Spread Rend") then
			for _,Unit in ipairs(Enemy5Y) do
				if not Debuff.Rend:Exist(Unit) and Unit.TTD >= 15 and Spell.Rend:Cast(Unit) then
					return true
				end
			end
		end
		if not Setting("Spread Rend") and Target.TTD >= 15 and not Debuff.Rend:Exist(Target) and Spell.Rend:Cast(Target) then
			return true
		end
	end
	-- SUNDER --
	if Setting("SunderArmor") and Spell.SunderArmor:IsReady() and not (Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem") then
		if Setting("Spread Sunder") then
			for _,Unit in ipairs(Enemy5Y) do
				if Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") and Unit.TTD >= 15 and Spell.SunderArmor:Cast(Unit) then
					return true
				end
			end
		end
		if not Setting("Spread Sunder") then
			if Debuff.SunderArmor:Stacks(Target) < Setting("Apply # Stacks of Sunder Armor") and Target.TTD >= 15 then
				if Spell.SunderArmor:Cast(Target) then
					return true
				end
			end
		end	
	end
	-- Demoralizing Shout --
	if Setting("Demoralizing Shout") and not Debuff.DemoShout:Exist(Target) and #Player:GetEnemies(10) >= Setting("Min targets for Demoralizing Shout") then
		if Spell.DemoShout:Cast(Target) then
			return
		end
	end
	-- Thunder Clap -- 
	if Setting("ThunderClap") and #Enemy5Y >= Setting("Min targets for Thunderclap") and Player.Power >= 20 and not Debuff.ThunderClap:Exist(Target) then
		smartCast("ThunderClap", Target)
	end
end
local function CombatPhase3()
	-- DUMP --
	if Buff.SweepStrikes:Exist(Player) and Spell.Whirlwind:CD() >= .1 then
		if Spell.Cleave:Cast() then
			return true
		end
	end
	if (Player.Power >= Setting("Rage Dump") or Spell.Whirlwind:CD() >= .1) and Player.SwingLeft <= 0.2 then
        if not IsCurrentSpell(845) or not IsCurrentSpell(285) then
            if #Player:GetEnemies(5) >= 2 then
                if Spell.Cleave:IsReady() and Spell.Cleave:Cast() then
                    return true
                end
            else
                if Spell.HeroicStrike:IsReady() and Spell.HeroicStrike:Cast() then
                    return true
                end
            end
        end
    end
end

function Warrior.Rotation()
    Locals()
	--ReturnToBattleStance
	if not select(2,GetShapeshiftFormInfo(1)) and Setting("Return to Battle Stance") and not Player.Combat then
		if Spell.StanceBattle:Cast(Player) then
			return true
		end
	end
	-- Targeting
	if not (Target and Target.ValidEnemy) and #Enemy5Y >= 1 and Player.Combat and Setting("AutoTarget") then
			TargetUnit(DMW.Attackable[1].unit)
	end
	-- Attacking
	if Target and Target.ValidEnemy and Target.Health > 1 then
		-- CHARGE --
		if Setting("Charge") and not Player.Combat and Target.Distance <= 25 and Target.Distance >= 8 then
			smartCast("Charge", Target)
		end
		-- Auto Attack --
		if not IsCurrentSpell(6603) and #Enemy5Y >= 1 then
			StartAttack(Target.Pointer)
		end
		-- Defensive --
		if DefensePhase() then
			return true
		end
		-- Apply Buffs --
		if BuffPhase() then
			return true
		end
		-- Counters and PVP Debuffs -- 
		if CombatPhase1() then
			return true
		end
		-- Apply Debuffs -- 
		if CombatPhase2() then
			return true
		end
		-- Dump exess Rage --
		if CombatPhase3() then
			return true
		end
	end
end