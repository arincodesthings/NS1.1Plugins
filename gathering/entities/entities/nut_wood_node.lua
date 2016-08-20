ENT.Type = "anim"
ENT.PrintName = "Древесина"
ENT.Author = "DrodA"
ENT.Category = "NutScript Mining System"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/gm_forest/wood_a.mdl")  --Your model here.
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetPersistent(true)
		self:SetNetworkedInt("condition", math.random(2, 7))
		
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end
end

function ENT:OnTakeDamage(dmg) -- Items adds to attacker's inventory, while hitting with certain weapon class
	local player = dmg:GetAttacker()
	local skill = player:getChar():getAttrib("wdc")
	if (skill == nil) then
		skill = 0
	end
	local chance = math.random(1, 100) + skill

	if( player:IsPlayer() and IsValid(player:GetActiveWeapon()) and (player:GetActiveWeapon():GetClass() == "YOUR_WEAPON_CLASS_HERE")) then
		if (self:GetNetworkedInt("condition") == 0) then
			player:notify("Ресурс иссяк.")
			timer.Simple(600, function()
				self:SetNetworkedInt("condition", math.random(2, 7))
			end)
		else
			if (chance > 60) and (chance <= 90) then
				player:getChar():getInv():add("wood")
				self:SetNetworkedInt("condition", self:GetNetworkedInt("condition") - 1)
				player:notify("You get some wood.")
				player:getChar():updateAttrib("wdc", 0.1)
			end
		end
	end
end