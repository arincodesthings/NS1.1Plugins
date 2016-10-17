ITEM.name = "Armor Base"
ITEM.desc = "A armor."
ITEM.category = "armor"
ITEM.isCloth = true
ITEM.model = ''
	if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",

	onRun = function(item)
		local inv = item.player:getChar():getInv()
		for k, v in pairs(inv:getItems()) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]
				if (itemTable.isCloth and itemTable:getData("equip")) then
					item.player:notify("You're already wearing armor")
					return false
				end
			end
		end
		item.player:getChar():setModel(item.SetModel)
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", true)
        item.player:getChar():setData("armored",true)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item.player:getChar():setModel( nut.faction.indices[item.player:Team()].models[1])
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", false)
		item.player:getChar():setData("armored",false)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	return !self:getData("equip")
end
ITEM.permit = "arm"