AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Corpse"
ENT.Author = "AleXXX_007"
ENT.Category = "NutScript"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		self.dummy = ents.Create("prop_ragdoll")		
		self.dummy:SetModel(self:GetNetVar("model"))
		self.dummy:SetPos(self:GetPos())
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetParent(self)
		self.dummy:Spawn()

		self:DeleteOnRemove(self.dummy)
	end
	
	function ENT:OnRemove()
		timer.Remove("chop")
	end
	
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:Use(activator)
		local wep = activator:GetActiveWeapon():GetClass()
		local skill = activator:getChar():getAttrib("hnt")
		if skill == nil then
			skill = 0
		end
		local chance = math.random(1, 100) + skill/2
		local animal = self:GetNetVar("animal")
		local animalAtt = self:GetNetVar("animal")*math.random(0.1, 1)
		local attribTime = math.random(10, 25) - skill * 0.2
		if ((wep == "nut_dagger_iron") or (wep == "nut_dagger_ironknife") or (wep == "nut_dagger_steel") or (wep == "nut_dagger_steelknife"))  then
			if (activator:KeyDown(IN_DUCK)) then
				activator:notify("Продолжайте сидеть до конца разделки!")
				timer.Create("chop", 2, 0, function()
					sound.Play("physics/flesh/flesh_squishy_impact_hard".. math.random(1, 4)..".wav", self:GetPos(), 75)
				end)
				activator:setAction("Разделываем...", attribTime, function()
					if (activator:KeyDown(IN_DUCK)) and (activator:GetPos():Distance(self:GetPos()) <= 200) then
						if (chance > 60) and (chance < 80) then
							if (animal == 1) then
								activator:getChar():getInv():add("deer_meat")
							elseif (animal == 2) then
								activator:getChar():getInv():add("goat_meat")
							elseif (animal == 3) then
								activator:getChar():getInv():add("bear_meat")
							end
						activator:notify("Вы повредили шкуру, но добыли мясо.")
						elseif (chance > 80) and (chance < 100) then
							if (animal == 1) then
								activator:getChar():getInv():add("deer_meat")
								activator:getChar():getInv():add("deer_hide")
							elseif (animal == 2) then
								activator:getChar():getInv():add("goat_meat")
								activator:getChar():getInv():add("goat_hide")
							elseif (animal == 3) then
								activator:getChar():getInv():add("bear_meat")
								activator:getChar():getInv():add("bear_hide")
							end
						activator:notify("Вы добыли шкуру и мясо.")
						elseif (chance < 100) then
							if (animal == 1) then
								activator:getChar():getInv():add("deer_meat")
								activator:getChar():getInv():add("deer_hide")
								activator:getChar():getInv():add("deer_sinew")
							elseif (animal == 2) then
								activator:getChar():getInv():add("goat_meat")
								activator:getChar():getInv():add("goat_hide")
								activator:getChar():getInv():add("goat_horn")
							elseif (animal == 3) then
								activator:getChar():getInv():add("bear_meat")
								activator:getChar():getInv():add("bear_hide")
								activator:getChar():getInv():add("bear_fat")
							end
						activator:notify("Вы мастерски разделали тушу.")
						else
						activator:notify("Вам не удалось разделать тушу.")
						end
						timer.Remove("chop")
						self:Remove()
						activator:getChar():updateAttrib("hnt", animalAtt)
					else
						activator:notify("Вы прервали разделку!")
						timer.Remove("chop")
						return
					end
				end)
			else
			activator:notify("Вы должны присесть, чтобы разделать животное.")
			end
		else
		activator:notify("Вы должны использовать нож, чтобы разделать животное.")
		end
	end
end