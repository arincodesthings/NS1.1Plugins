ITEM.name = "CPOutfit Base"
ITEM.desc = "shit."
ITEM.category = "CP Outfit"
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.cpoutfit = nil
ITEM.cparmband = nil
ITEM.cppvisor = nil
ITEM.cpsvisor = nil
ITEM.rank = nil
ITEM.changeModel = false

local function processOutfit(item, player)
	if item.cpoutfit then
		local outfit = player:getChar():getData("CP08_Outfit", "0_0000000000_0_0_0") 
		local strTable = string.Explode("_", outfit)
		local uID = strTable[1]
	    local bodygroups =strTable[2]
	    local gasmaskID = strTable[3]
	    local gasmaskShockID = strTable[4]
	    local gasmaskGlow = strTable[5]

		local newOutfit = ""

		if item.cpoutfit.uniform then
			newOutfit = newOutfit .. tostring(item.cpoutfit.uniform) .. "_"
		else
			newOutfit = newOutfit .. uID .. "_"
		end

		if item.cpoutfit.bodygroups then
			newOutfit = newOutfit .. tostring(item.cpoutfit.bodygroups) .. "_"
		else
			newOutfit = newOutfit .. bodygroups .. "_"
		end

		if item.cpoutfit.gasmask then
			newOutfit = newOutfit .. tostring(item.cpoutfit.gasmask) .. "_"
		else
			newOutfit = newOutfit .. gasmaskID .. "_"
		end

		if item.cpoutfit.gasmaskshock then
			newOutfit = newOutfit .. tostring(item.cpoutfit.gasmaskshock) .. "_"
		else
			newOutfit = newOutfit .. gasmaskShockID .. "_"
		end

		if item.cpoutfit.glow then
			newOutfit = newOutfit .. tostring(item.cpoutfit.glow)
		else
			newOutfit = newOutfit .. gasmaskGlow
		end

		ReadCPOutfit(player, newOutfit)
		player:getChar():setData("CP08_Outfit", newOutfit)
	end

	if item.cparmband then
		ReadCPArmband(player, item.cparmband)
		player:getChar():setData( "CP08_Armband", item.cparmband )
	end

	if item.cppvisor and item.cpsvisor then
		ReadCPVisors(player, item.cppvisor, item.cpsvisor)
		player:getChar():setData( "CP08_PVisor", item.cppvisor )
		player:getChar():setData( "CP08_SVisor", item.cpsvisor )
	end

	if item.rank then
		--if player:isCombine() then
			local name = player:GetName()
			local finished = string.gsub(name,"(CP%:.*%.).*(%.%d+)","%1"..item.rank.."%2")
			player:getChar():setName(finished)
		--end
	end
end

ITEM.functions.Equip = {
	name = "Экипировать",
	tip = "Надеть данный предмет на себя.",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player

		if cpoutfit.IsSupported(client:GetModel()) then
			processOutfit(item, client)
		else
			if item.changeModel then
				if !client:isFemale() then
					client:getChar():setModel("models/metropolice/c08.mdl")
				else
					client:getChar():setModel("models/metropolice/c08_female_2.mdl")
				end
				client:SetupHands()
				
				processOutfit(item, client)
			end
		end
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}