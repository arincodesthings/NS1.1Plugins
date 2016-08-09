ENT.Type = "anim"
ENT.PrintName = "Plant"
ENT.Author = "AleXXX_007"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true


function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_lab/box01a.mdl") -- Your model here (MUSTN'T BE AN EFFECT!)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self:SetModelScale(1)
		self:SetNetworkedBool("Usable", true)
		self:SetPersistent(true)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end
end

function ENT:Use(activator)
	local skill = activator:getChar():getAttrib("frm")
	if skill == nil then
		skill = 0
	end
	local skilltime = math.random(6, 10) - skill/20
	local chance = math.random(1, 100) + skill/2
	if activator:KeyDown(IN_DUCK) and self:GetNetworkedBool("Usable") == true then
		activator:setAction("Gathering...", skilltime, function()
			if activator:KeyDown(IN_DUCK) then
				if chance >= 50 and chance < 75 then
					activator:getChar():getInv():add("example_plant")
					activator:notify("You have collected plant.")
				else
					activator:notify("You destroyed the plant!")
				end
				activator:getChar():updateAttrib("frm", math.random(0.1, 0.5))
				self:SetNetworkedBool("Usable", false)
				self:SetModelScale(0.5)
				timer.Simple(math.random(180, 600), function() --Respawn time of the plant
					self:SetNetworkedBool("Usable", true)
					self:SetModelScale(1)
					self:SetModel("models/props_lab/box01a.mdl")
				end)
			else
				activator:notify("You interrupted the gathering!")
			end
		end)
	elseif !activator:KeyDown(IN_DUCK) then
		activator:notify("You must sit to gather the plant.")
	else
		activator:notify("Plant isn't grow!")
	end
end
function ENT:OnRemove()
	self:SetNetworkedBool("Usable", true)
end