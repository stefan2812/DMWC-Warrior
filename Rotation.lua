local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, Enemy5Y, Enemy5YC, rageDanceCheck

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
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
        rageDanceCheck = false
end

local function smartCast(spell, Unit)
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

local function DEF()
	----------------------
	--- Defence Stance ---
	----------------------
	if Setting("Defense Stance") and #Enemy5Y >= Setting"Defense Stance at or above # Mobs" then
		if Spell.StanceDefense:Cast(Player) then
			return
		end
	end
	--------------------
	--- Shield Block ---
	--------------------
	if Setting("ShieldBlock") and Player.HP < Setting("Shieldblock HP") and #Enemy5Y >= 1 then
		if Spell.ShieldBlock:Cast(Player) then
			return
		end
	end
	---------------
	--- Revenge ---
	---------------
	if Spell.Revenge:IsReady() and Stance == "Defense" then
		for _,Unit in ipairs(Enemy5Y) do
			if Spell.Revenge:Cast(Unit) then 
				break
			end
		end
	end
	---------------------
	--- Battle Stance ---
	---------------------
	if Setting("Defense Stance") and #Enemy5Y < Setting"Defense Stance at or above # Mobs" and Player.HP >= 30 then
		if Spell.StanceBattle:Cast(Player) then
			return
		end
	end
	
end

function Warrior.Rotation()
    Locals()
	if Rotation.Active() then
		-----------------
		--- Check Def ---
		-----------------
		if Player.Combat then
			if DEF() then
				return true
			end
		end
		--------------------
		--- Check Target ---
		--------------------
		if not (Target and Target.ValidEnemy) and #Enemy5Y >= 1 and Setting("Auto Target")then
			TargetUnit(DMW.Attackable[1].unit)
		end
		--------------------
		--- Auto Charge ----
		--------------------
		if Target and Target.ValidEnemy then
			if Setting("Auto Charge") and Spell.Charge:IsReady() and not Player.Combat then
				if Spell.Charge:Cast(Target) then 
					return true 
				end
			end
			------------------
			--- Blood Rage ---
			------------------
			if Setting ("Bloodrage") and Player.HP >= Setting("Bloodrage HP") and #Enemy5Y <= 2 and Player.Combat then
				if Spell.Bloodrage:Cast(Player) then 
					return true 
				end
			end
			-------------------
			--- Auto Attack ---
			-------------------
			if not IsCurrentSpell(6603) then
				StartAttack(Target.Pointer)
			end
			--------------------
			--- Battle Shout ---
			--------------------
			if not Buff.BattleShout:Exist(Player) and Spell.BattleShout:Cast(Player) then
				return true
			end
			------------------
			--- Demo Shout ---
			-------------------		
			if not Debuff.DemoShout:Exist(Target) and Spell.DemoShout:Cast(Target) and #Enemy5Y >= Setting("Demoshout at or above # Mobs") and Setting ("Demoshout") then
				return true
			end
			-----------------
			--- Overpower ---
			-----------------
			if Spell.Overpower:IsReady() and Stance == "Battle" then
				for _,Unit in ipairs(Enemy5Y) do
					if Spell.Overpower:Cast(Unit) then 
						break
					end
				end
			end
			--------------------
			--- Thunder Clap ---
			--------------------
			if Stance == "Battle" then
				if #Enemy5Y >= 2 then
					if Spell.ThunderClap:Cast() then
						return true
					end
				end
			end
			---------------------
			--- Rend & Sunder ---
			---------------------
			if #Enemy5Y >= 1 and not (Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem") then 
				----------------------
				--- Sunder Armor 1 ---
				----------------------
				if Stance == "Defense" and Setting ("Sunder Target") then
					if Spell.SunderArmor:IsReady() then
						for _,Unit in ipairs(Enemy5Y) do
							if Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") and Spell.SunderArmor:Cast(Unit) then
								return true
							end
						end
					end
				end
				------------
				--- Rend ---
				------------				
				if Spell.Rend:IsReady() then
					for _,Unit in ipairs(Enemy5Y) do
						if not Debuff.Rend:Exist(Unit) and Spell.Rend:Cast(Unit) then
							return true
						end
					end
				end
				----------------------
				--- Sunder Armor 2 ---
				----------------------
				if Stance == "Battle" and Setting ("Sunder Target") then
					if Spell.SunderArmor:IsReady() then
						for _,Unit in ipairs(Enemy5Y) do
							if Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") and Spell.SunderArmor:Cast(Unit) then
								return true
							end
						end
					end
				end
			end
			-----------------
			--- Dump Rage ---
			-----------------
			if Player.Power >= Setting("Rage Dump") then
				if not IsCurrentSpell(285) then
					if Spell.HeroicStrike:IsReady() and Spell.HeroicStrike:Cast() then
						return true
					end
				end
			end
		end
	end
end