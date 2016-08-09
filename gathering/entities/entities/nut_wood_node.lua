ENT.Type = "anim"
ENT.PrintName = "Древесина"
ENT.Author = "DrodA"
ENT.Category = "NutScript Mining System"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/gm_forest/wood_a.mdl") --В строгом порядке изменить модель!
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetPersistent(true)
		
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end
end
condition = 5
function ENT:OnTakeDamage(dmg) -- предметы выпадают при ударе определенным классом оружия
	local player = dmg:GetAttacker()
	local skill = player:getChar():getAttrib("wdc")
	if (skill == nil) then
		skill = 0
	end
	local chance = math.random(1, 100) + skill

	if( player:IsPlayer() and IsValid(player:GetActiveWeapon()) and (player:GetActiveWeapon():GetClass() == "nut_axe_hatchet")) then
		if (condition == 0) then
			player:notify("Ресурс иссяк.")
			timer.Simple(600, function()
			condition = 5
			end)
		else
			if (chance > 60) and (chance <= 90) then
				player:getChar():getInv():add("wood")
				condition = condition - 1
				player:notify("Вы добыли древесину.")
				player:getChar():updateAttrib("wdc", 0.1)
				end
			if (chance > 90) and (chance <=100) then
				player:getChar():getInv():add("pitch")
				player:notify("Вы добыли немного смолы.")
				player:getChar():updateAttrib("wdc", 0.2)
			end
		end
	end
end

function ENT:OnRemove()
	condition = 5
end