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
    if pool and Spell[spell]:Cost() > Player.Power then
        return true
    end
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
	-- Shield Block --
	if Setting("Use ShieldBlock") and HP < Setting("Shieldblock HP") and #Enemy5Y >= 1 and Player.Combat then
		smartCast("ShieldBlock")
	end
	-- Retaliation -- 
	if HP <=35 and Spell.Retaliation:IsReady() then
		smartCast("Retaliation")
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
	-- OVERPOWER --
	if #Player.OverpowerUnit > 0 and Spell.Overpower:CD() == 0 then
        for _,Unit in ipairs(Enemy5Y) do
            for i = 1, #Player.OverpowerUnit do
                if Unit.GUID == Player.OverpowerUnit[i].overpowerUnit then
                    smartCast("Overpower", Unit, true)
                end
            end 
        end
        return true
    end
	-- REVENGE --
	if Spell.Revenge:IsReady() and Player.Power >= 5 and Spell.Revenge:CD() == 0 then
		for _,Unit in ipairs(Enemy5Y) do
            if Spell.Revenge:Cast(Unit) then 
                return true
            end
        end
	end
	-- Whirlwind#1 --
	if Player.Combat and #Target:GetEnemies(20) == 1 then
		smartCast("Whirlwind", Target, true)
	end
	-- SweepingStrikes --
    if Setting("SweepingStrikes") and #Player:GetEnemies(5) >= 2 and Spell.SweepStrikes:CD() == 0 then
        smartCast("SweepStrikes",Player, true)
    end
	-- Whirlwind#2 --
	if Player.Combat and #Target:GetEnemies(20) >= 2 and Buff.SweepStrikes:Exist(Player) then
		smartCast("Whirlwind", Target, true)
	end		
	-- Execute --
	if Setting("Execute") then
		for _,Unit in ipairs(Enemy5Y) do
            if Unit.HP < 20 then
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
	-- Hamstring
	if Target.Player and Spell.Hamstring:IsReady() and not Debuff.Hamstring:Exist(Target) then
		smartCast("Hamstring",Target)
	end
	-- Disarm
	 if Spell.Disarm:CD() == 0 and Debuff.Hamstring:Exist(Target) then
        smartCast("Disarm",Target, true)
    end
end
local function CombatPhase2()
	-- REND --
	if Setting("Rend") and Spell.Rend:IsReady() and not (Target.CreatureType == "Elemental" or Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem")then
		if Setting("Spread Rend") then
			for _,Unit in ipairs(Enemy5Y) do
				if not Debuff.Rend:Exist(Unit) and Unit.TTD >= 15 then
					smartCast("Rend", Unit, true)
				end
			end
		end
		if not Setting("Spread Rend") and Target.TTD >= 15 and not Debuff.Rend:Exist(Target) then
			smartCast("Rend", Target, true)
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
	if (Player.Power >= Setting("Rage Dump") or Spell.Whirlwind:CD() >= .1) then
        if not IsCurrentSpell(845) or not IsCurrentSpell(285) then
            if #Player:GetEnemies(5) >= 2 then
                smartCast("Cleave", Target, true)
            else
                smartCast("HeroicStrike", Target, true)
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
		if Setting("Charge") and not Player.Combat and Target.Distance <= 25 and Target.Distance >= 8 and HP >= 40 then
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