PLUGIN.name = "Butcherable animals"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Butcher dead animals to get meat, bones and hides!"
local PLUGIN = PLUGIN

function PLUGIN:OnNPCKilled(entity)
	local corpse = ents.Create("nut_corpse")
	corpse:SetPos(entity:GetPos())
	corpse:SetAngles(entity:GetAngles())
	corpse:SetNetVar("model", entity:GetModel())
	corpse:SetNetVar("animal", 1)
	corpse:Spawn()
	entity:Remove()
end