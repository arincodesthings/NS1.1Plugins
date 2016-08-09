ENT.Type = "anim"
ENT.PrintName = "Example Plant"
ENT.Author = "AleXXX_007 & DrodA"
ENT.Category = "NutScript Farming System"
ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/aoc_trees/aoc_lowveg14.mdl") --Your model here (MUST'NT BE AN EFFECT)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self:SetModelScale(0.5)
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		self:SetNetworkedBool("Usable", false)
	end
end

function ENT:OnTakeDamage()
	local player = dmg:GetAttacker()
	if( player:IsPlayer() ) then self:Remove() end
end

function ENT:Use(activator)
	local opentime = math.random(11, 15)
	local random_opentime = math.random(1, 5) + opentime
	local skill = activator:getChar():getAttrib("frm")
		if (skill == nil) then
		skill = 0
		end
	local attribtime = skill * 0.1
	local chance = math.random(1, 100) - skill/2
	
	if self:GetNetworkedBool("Usable") == true then
		self:SetNetworkedBool("Usable", false)
		activator:setAction("Harvesting...", random_opentime - attribtime, function()
			if (activator:GetPos():Distance(self:GetPos()) <= 100) then
				self:EmitSound("player/footsteps/grass"..math.random(1, 4)..".wav")
				activator:getChar():updateAttrib("frm", 0.010) -- attribute
				if (chance <= 70) and (chance > 40) then
					activator:getChar():getInv():add("example_seed")
					activator:notify("After your collection only seeds survived.")
				end
				if (chance <= 40) and (chance > 20) then
					activator:getChar():getInv():add("example_seed")
					activator:getChar():getInv():add("example_plant")
					activator:notify("You have successfully gathered the harvest.")
				end
				if (chance <= 20) then
					activator:getChar():getInv():add("example_seed")
					activator:getChar():getInv():add("example_seed")
					activator:getChar():getInv():add("example_plant")
					activator:notify("You have masterfully gathered the harvest.")
				end
				if (chance > 70) then
					activator:notify("You destroyed the harvest.")
				end
				timer.Simple(0, function()self:Remove() end)
			end
		end)
	else
		activator:notify("Plant will grow soon.")
	end
end

