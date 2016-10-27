ENT.Type = "anim"
ENT.PrintName = "Ore Node"
ENT.Author = "AleXXX_007 & DrodA"
ENT.Category = "NutScript Mining System"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_debris/concrete_cornerpile01a.mdl") --Your model here.
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
	local skill = player:getChar():getAttrib("mng")
	if (skill == nil) then
		skill = 0
	end
	local chance = math.random(1, 100) + skill/2
	if( player:IsPlayer() and IsValid(player:GetActiveWeapon()) and (player:GetActiveWeapon():GetClass() == "YOUR_WEAPON_CLASS_HERE")) then
		if (self:GetNetworkedInt("condition") == 0) then
			player:notify("Resource Drained.")
			timer.Simple(600, function()
				self:SetNetworkedInt("condition", math.random(2, 7))
			end)
		else
			if chance >= 50 and chance < 75 then
				player:getChar():getInv():add("stone")
				player:notify("You get some ore.")
			elseif chance >=75 and chance <= 90 then
				player:getChar():getInv():add("stone1")
				player:notify("You get some ore.")
			elseif chance >=90 then
				player:getChar():getInv():add("stone2")
				player:notify("You get some ore.")
			end
			self:SetNetworkedInt("condition", self:SetNetworkedInt("condition") - 1)
			player:getChar():updateAttrib("mng", 0.05)
		end
	end
end