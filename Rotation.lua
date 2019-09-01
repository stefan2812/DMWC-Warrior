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
end

local function Execute()
	-----------------
	--- Bloodrage ---
	-----------------
	if Setting("Use Bloodrage for 1 Pull | 2 Execute") == 2 and Spell.Execute:IsReady() and Player.HP >= Setting("Bloodrage min HP") then
		if Spell.Bloodrage:Cast(Player) then 
			return true 
		end
	end
	---------------
	--- Execute ---
	---------------
	if Spell.Execute:IsReady() then
		if Spell.Execute:Cast(Target) then 
			return true 
		end
	end
end

local function Defense()
	---------------
	--- Revenge ---
	---------------
	if Setting ("Use Revenge") and Spell.Revenge:IsReady() and Stance == "Defense" then
		for _,Unit in ipairs(Enemy5Y) do
			if Spell.Revenge:Cast(Unit) then 
				break
			end
		end
	end
	---------------------
	--- Retaliation 1 ---
	---------------------
	if #Enemy5Y >= Setting("Use Retaliation when # Mobs") and Spell.Retaliation:IsReady() then
		if Spell.Retaliation:Cast(Player) then
			return
		end
	end
	---------------------
	--- Retaliation 2 ---
	---------------------	
	if Player.HP <= Setting("Use Retaliation when below #% HP") and Spell.Retaliation:IsReady() then
		if Spell.Retaliation:Cast(Player) then
			return
		end
	end
	------------------
	--- Demo Shout ---
	-------------------		
	if not Debuff.DemoShout:Exist(Target) and #Enemy5Y >= Setting("Demoshout at or above # Mobs") and Setting ("Use Demoshout") then
		if Spell.DemoShout:Cast(Target) then
			return
		end
	end
	----------------------
	--- Defence Stance ---
	----------------------
	if Setting("Use Defense Stance") and #Enemy5Y >= Setting"Defense Stance at or above # Mobs" then
		if Spell.StanceDefense:Cast(Player) then
			return
		end
	end
	--------------------
	--- Shield Block ---
	--------------------
	if Setting("Use ShieldBlock") and Player.HP < Setting("Shieldblock HP") and #Enemy5Y >= 1 and not Buff.ShieldBlock:Exist(Player) then
		if Spell.ShieldBlock:Cast(Player) then
			return
		end
	end
	---------------------
	--- Battle Stance ---
	---------------------
	if Setting("Use Defense Stance") and #Enemy5Y < Setting"Defense Stance at or above # Mobs" and Player.HP >= 30 then
		if Spell.StanceBattle:Cast(Player) then
			return
		end
	end
	
end

local function Opener()
	--------------------
	--- Auto Charge ----
	--------------------
	if Setting("Auto Charge") and Spell.Charge:IsReady() and not Player.Combat and Target.Distance <= 25 and Target.Distance >= 8 then
		if Spell.Charge:Cast(Target) then 
			return 
		end
	end
	------------------
	--- Blood Rage ---
	------------------
	if Setting("Use Bloodrage for 1 Pull | 2 Execute") == 1 and Player.HP >= Setting("Bloodrage min HP") and #Enemy5Y <= 2 and Player.Combat then
		if Spell.Bloodrage:Cast(Player) then 
			return 
		end
	end
	-------------------
	--- Auto Attack ---
	-------------------
	if Target.Distance <= 5 and not IsCurrentSpell(6603) then
		StartAttack(Target.Pointer)
	end
	----------------------
	--- Thunder Clap #1---
	----------------------
	if Stance == "Battle" and Setting("Use Thunderclap") and Target.Distance <= 5 then
		if #Enemy5Y >= Setting("ThunderClap#") then
			if Spell.ThunderClap:Cast() then
				return true
			end
		end
	end
end

local function DumpRage()
	if Player.Power >= Setting("Rage Dump") then
		--------------
		--- Cleave ---
		--------------
		if not IsCurrentSpell(845) and Player.Power >= 20 and Setting ("Use Cleave") and #Enemy5Y >= 2 then
			if Spell.Cleave:IsReady() and Spell.Cleave:Cast() then
				return true
			end
		end
		--------------------
		--- HeroicStrike ---
		--------------------
		if not IsCurrentSpell(285) then
			if Spell.HeroicStrike:IsReady() and Spell.HeroicStrike:Cast() then
				return true
			end
		end
	end
end

local function RendAndSunder()
	if #Enemy5Y >= 1 then 
		----------------------
		--- Sunder Armor 1 ---
		----------------------
		if (Target.Distance <= 5 and Stance == "Defense" and Setting ("Use Sunder Armor")) or (Debuff.SunderArmor:Duration() < 5 and Setting ("Use Sunder Armor")) and not (Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem") and Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor")then
			if Spell.SunderArmor:IsReady() then
				for _,Unit in ipairs(Enemy5Y) do
					if Unit.Facing then
						if (Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") or Debuff.SunderArmor:Duration() < 5) and Spell.SunderArmor:Cast(Unit) then
							return true
						end
					end
				end
			end
		end
		------------
		--- Rend ---
		------------				
		if Setting ("Use Rend") and Target.Distance <= 5 and Spell.Rend:IsReady() and not (Target.CreatureType == "Elemental" or Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem")then
			for _,Unit in ipairs(Enemy5Y) do
				if Unit.Facing then
					if not Debuff.Rend:Exist(Unit) and Spell.Rend:Cast(Unit) then
						return true
					end
				end
			end
		end
		----------------------
		--- Sunder Armor 2 ---
		----------------------
		if (Target.Distance <= 5 and Stance == "Battle" and Setting ("Use Sunder Armor")) or (Debuff.SunderArmor:Duration() < 5 and Setting ("Use Sunder Armor")) then
			if Spell.SunderArmor:IsReady() and not (Target.CreatureType == "Undead" or Target.CreatureType == "Mechanical" or Target.CreatureType == "Totem") then
				for _,Unit in ipairs(Enemy5Y) do
					if Unit.Facing then
						if (Debuff.SunderArmor:Stacks(Unit) < Setting("Apply # Stacks of Sunder Armor") or Debuff.SunderArmor:Duration() < 5) and Spell.SunderArmor:Cast(Unit) then
							return true
						end
					end
				end
			end
		end
	end
end

function Warrior.Rotation()
    Locals()
	if Rotation.Active() then	
		if Player.Combat then
			---------------------
			--- Check Defense ---
			---------------------
			if Defense() then
				return true
			end
			---------------------
			--- Check Execute ---
			---------------------		
			if Execute() then
				return true
			end
		end
		--------------------
		--- Check Target ---
		--------------------
		if not (Target and Target.ValidEnemy) and #Enemy5Y >= 1 and Setting("Auto Target")then
			TargetUnit(DMW.Attackable[1].unit)
		end
		if Target and Target.ValidEnemy then
			--------------
			--- Opener ---
			--------------		
			if Opener() then
				return true
			end
			------------------------
			--- Sweeping Strikes ---
			------------------------			
			if #Player:GetEnemies(5) >= 2 then
                if Spell.SweepStrikes:Cast(Player) then 
                    return true
                end
            end
			------------------------
			--- Hamstring PVP ---
			------------------------	
			if Target.Player and not Debuff.Hamstring:Exist(Target) and Spell.Hamstring:Cast(Target) then
				return true
			end
			--------------------
			--- Disarm ---
			--------------------
			if Target.Player and Spell.Disarm:IsReady() and Spell.Disarm:Cast(Target) then
				return true

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
			if not Debuff.DemoShout:Exist(Target) and #Enemy5Y >= Setting("Demoshout at or above # Mobs") and Setting ("Use Demoshout") then
				if Spell.DemoShout:Cast(Target) then
					return
				end
			end
			-----------------
			--- Overpower ---
			-----------------
			if Setting ("Use Overpower") and Spell.Overpower:IsReady() and Stance == "Battle" then
				for _,Unit in ipairs(Enemy5Y) do
					if Unit.Facing then
						if Spell.Overpower:Cast(Unit) then 
							break
						end
					end
				end
			end
			---------------------
			--- Rend & Sunder ---
			---------------------
			if RendAndSunder() then
				return true
			end		
			-----------------
			--- Dump Rage ---
			-----------------
			if DumpRage() then
				return true
			end
		end
	end
end