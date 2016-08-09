ITEM.name = "Furniture base"
ITEM.desc = "Base as it is."
ITEM.category = "Furniture"
ITEM.model = "models/props_c17/FurnitureCouch001a.mdl"


ITEM.functions.use = {
	name = "Поставить",
	tip = "placeTip",
	icon = "icon16/anchor.png",	
	onRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local furniture = ents.Create("nut_furniture")
			furniture:SetPos(trace.HitPos + trace.HitNormal)
			furniture:Spawn()
			client:notify("Е - lock, ALT + E - pick up.")
			hook.Run("OnFurnitureSpawned", furniture, item)
		end
		return
	end,
}