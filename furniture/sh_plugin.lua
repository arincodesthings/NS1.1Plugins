PLUGIN.name = "Furniture"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds placable furniture."

function PLUGIN:OnFurnitureSpawned(furniture, item, load)
	
	furniture:SetModel(item.model)
	furniture:PhysicsInit(SOLID_VPHYSICS)
	furniture:SetMoveType(MOVETYPE_VPHYSICS)
	furniture:SetUseType(SIMPLE_USE)
	if (!load == true) then
		furniture:SetMaterial("models/wireframe")
	end
	local physicsObject = furniture:GetPhysicsObject()
	if (IsValid(physicsObject)) then
		physicsObject:EnableMotion(true)
		physicsObject:Wake()
	end

	if (item.player and IsValid(item.player)) then
		furniture:setNetVar("ownerChar", item.player:getChar().id)
	end
	furniture:setNetVar("ItemId", item.uniqueID)
	furniture:setNetVar("placed", false)
end

function PLUGIN:LoadData()
	local savedTable = self:getData() or {}
	if (savedTable.furnitureEntities) then
		for k, v in ipairs(savedTable.furnitureEntities) do
			local furniture = ents.Create("nut_furniture")
			
			furniture:SetPos(v.pos)
			furniture:SetAngles(v.ang)
			furniture:SetModel(v.model)
			furniture:PhysicsInit(SOLID_VPHYSICS)
			furniture:SetMoveType(MOVETYPE_VPHYSICS)
			furniture:SetUseType(SIMPLE_USE)
			furniture:Spawn()
			local physicsObject = furniture:GetPhysicsObject()
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false)
				physicsObject:Sleep()
			end
			furniture:setNetVar("ownerChar", v.owner)
			furniture:setNetVar("ItemId", v.item)
			furniture.id = v.id
		end
	end
end

function PLUGIN:SaveData()
	local saveTable = {}
	local validFurniture = {}
	saveTable.furnitureEntities = {}

	for _, v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "nut_furniture") and (v:GetNetVar("placed") == true) then
			table.insert(saveTable.furnitureEntities, {model = v:GetModel(), pos = v:GetPos(), ang = v:GetAngles(), id = v.id, owner = v:getOwner(), item = v:getItem()})
			table.insert(validFurniture, v.id)
		end
	end
	self:setData(saveTable)
end

function FindFurnitureByID(id)
	for k, v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "nut_furniture" and v.id == id) then
			return v
		end
	end
end