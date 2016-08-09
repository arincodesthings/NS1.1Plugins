ITEM.name = "Alcohol"
ITEM.desc = "Simple."
ITEM.category = "Alcohol"
ITEM.model = "models/props/furnitures/gob/l6_jar_oil/l6_jar_oil.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.force = 0
ITEM.thirst = 0
ITEM.quantity = 1

ITEM.functions.use = {
	name  = "Drink",
	icon = "icon16/drink.png",
	onRun = function(item)
		local client = item.player
		local quantity = item:getData("quantity", item.quantity)
		if item.thirst > 0 then client:restoreThirst(item.thirst) end
		quantity = quantity - 1
		if (quantity >= 1) then			
			client:getChar():setData("drunk", client:getChar():getData("drunk") + item.force)
			item:setData("quantity", quantity)
			client:EmitSound( "physics/flesh/flesh_bloody_break.wav", 75, 200 )
			hook.Run("Drunk", client)
			return false	
		end		
		if quantity == 0 then 
			client:getChar():getInv():add("water_empty") 
			return true
		end	
	end
}