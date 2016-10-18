local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1), AleXXX_007"
PLUGIN.desc = "Allows you craft some items."

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Crafting Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

PLUGIN.menuEnabled = true -- menu can be toggled off.
PLUGIN.reqireBlueprint = true

nut.lang.Add("crafting", "Craft")

nut.lang.Add("craftingtable", "Workshop")
nut.lang.Add("req_moremat", "You need more materials for %s.")
nut.lang.Add("req_moreattrib", "You need more attributes to %s.")
nut.lang.Add("req_blueprint", "You need blueprint %s to create %s.")
nut.lang.Add("req_diffplace", "You need another workshop to craft %s.")
nut.lang.Add("req_morespace", "You have no inventory space.")
nut.lang.Add("donecrafting", "You created %s.")
nut.lang.Add("icat_material", "Materials")

nut.lang.Add("craft_menu_tip1", "You can craft items by clicking on their icons.")
nut.lang.Add("craft_menu_tip2", "Book icon .")

nut.lang.Add("crft_text", "Creating %s\n%s\n\nRequires:\n")
nut.lang.Add("crft_text_att", "Req. attribs:\n%s%s")

RECIPES = {}
RECIPES.recipes = {}
function RECIPES:Register( tbl )
	if !tbl.CanCraft then
		function tbl:CanCraft( player )
			for k, v in pairs( self.items ) do
				if !player:HasItem( k, v ) then
					player.notify("You have no materials to craft this.")
					return false					
				end
			end
			for k, v in pairs( self.requiredattrib ) do
				if (player:getChar():getAttrib(k) == nil) then
				player:getChar():setAttrib(k, 0)
				end
			
				if (player:getChar():getAttrib(k) < v) then
					player.notify("You must have more attribs to craft this.")
					return false			
				end
			end
			return true
		end
	end
	if !tbl.ProcessCraftItems then
		function tbl:ProcessCraftItems( player )

			player:EmitSound( "hgn/crussaria/items/itm_ammo_down.wav" )
			for k, v in pairs( self.items ) do
				for i = 1, v do
					player:getChar():getInv():hasItem( k ):remove()
				end
			end
			for k, v in pairs( self.updateattrib ) do
				player:getChar():updateAttrib(k, v)
			end
			for k, v in pairs( self.result ) do
				
				if (!player:getChar():getInv():add(k, v)) then
					netstream.Start(client, "vendorAdd", uniqueID)
				end
			player:notifyLocalized( "donecrafting", self.name )

		end
	end
	self.recipes[ tbl.uid ] = tbl
end
end
nut.util.Include("sh_recipies.lua")
nut.util.Include("sh_menu.lua")


function RECIPES:Get( name )
	return self.recipes[ name ]
end
function RECIPES:GetAll()
	return self.recipes
end
function RECIPES:GetItem( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.items
end
function RECIPES:GetResult( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.result
end
function RECIPES:GetUpdateAttrib( uniqueID, ammount )
	local tblRecipe = self:Get( uniqueID, ammount )
	return tblRecipe.updateattrib
end
function RECIPES:GetRequiredAttrib( uniqueID, ammount )
	local tblRecipe = self:Get( uniqueID, ammount )
	return tblRecipe.requiredattrib
end
function RECIPES:CanCraft( player, item )
	local tblRecipe = self:Get( item )
	if PLUGIN.reqireBlueprint then
		if !tblRecipe.noBlueprint then
			local name_bp = ( tblRecipe.uid )
			if !player:HasItem( name_bp ) then
				return 2
			end
		end
	end
	if (tblRecipe.place ~= player:getChar():getData("CraftPlace")) then
		return 3
	end
	if !tblRecipe:CanCraft( player ) then
		return 1
	end
	return 0
end
--[[			for k, v in pairs( tblRecipe.place ) do
				if (player:getChar():getData("CraftPlace") ~= k) then
					nut.util.Notify("Вы используете неправильную мастерскую.")
					return false
				end
			end
]]
local entityMeta = FindMetaTable("Entity")
function entityMeta:IsCraftingTable()
	return self:GetClass() == "nut_craftingtable"	
end

if CLIENT then return end
util.AddNetworkString("nut_CraftItem")
net.Receive("nut_CraftItem", function(length, client)
	local item = net.ReadString()
	local cancraft = RECIPES:CanCraft( client, item )
	local tblRecipe = RECIPES:Get( item )
	if cancraft == 0 then
		tblRecipe:ProcessCraftItems( client )
	else
		if cancraft == 2 then
			player.notify( nut.lang.Get( "req_blueprint", tblRecipe.name, tblRecipe.name ), client )
		elseif cancraft == 3 then
			player.notify( nut.lang.Get( "req_diffplace", tblRecipe.name ), client )
		end
	end
end)

function PLUGIN:LoadData()
	local data = self:getData() or {}
	for k, v in pairs(data) do
		local position = v.pos
		local angles = v.angles
		local entity = ents.Create("nut_craftingtable")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	for k, v in pairs(ents.FindByClass("nut_craftingtable")) do
		data[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
		}
	end
	self:setData(data)
end
