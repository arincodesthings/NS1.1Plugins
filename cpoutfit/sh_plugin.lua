PLUGIN.name = "Customizable Metropolice"
PLUGIN.author = "Schwarzkruppzo, AleXXX_007 (NS 1.1)"
PLUGIN.desc = "Makes your metropolices cool as fuck."

function ReadCPOutfit( ply, str )
    if !IsValid( ply ) then return end
    if !cpoutfit.IsSupported(ply:GetModel()) then return end

    local strTable = string.Explode( "_", str )
    
    local uID = tonumber(strTable[1])
    local bodygroups = tostring(strTable[2])
    local gasmaskID = tonumber(strTable[3])
    local gasmaskShockID = tonumber(strTable[4])
    local gasmaskGlow = tonumber(strTable[5])
    
    if bodygroups then
        for i = 1, 9 do
            local number = string.sub( bodygroups, i, i )
            if number and number != "" then
                ply:SetBodygroup( i, tonumber(number) )
            end
        end
    end

    cpoutfit.SetPlayerOutfit(ply, "uniform", uID )
    cpoutfit.SetPlayerOutfit(ply, "gasmask_style", gasmaskID )
    cpoutfit.SetPlayerOutfit(ply, "gasmaskshock_style", gasmaskShockID )
    cpoutfit.SetPlayerOutfit(ply, "visor_style", gasmaskGlow )
end

function ReadCPArmband( ply, str )
    if !IsValid( ply ) then return end
    if !cpoutfit.IsSupported(ply:GetModel()) then return end

    local codeTable = string.Explode("_", str)

    if codeTable then
        local bg_color = Color(255,255,255)
        local icon_color = Color(255,255,255)
        local text_color = Color(255,255,255)

        if codeTable[1] then
            local r, g, b = codeTable[1]:match("%((%d+),(%d+),(%d+)%)")
            bg_color = Color( r, g, b )
        end

        if codeTable[3] then
            local r, g, b, a = codeTable[3]:match("%((%d+),(%d+),(%d+),(%d+)%)")
            icon_color = Color( r, g, b, a )
        end

        if codeTable[5] then
            local r, g, b, a = codeTable[5]:match("%((%d+),(%d+),(%d+),(%d+)%)")
            text_color = Color( r, g, b, a )
        end

        local backgroundID = tonumber(codeTable[2])
        local iconID = tonumber(codeTable[4])
        local textID = tonumber(codeTable[6])

        ply:SetArmbandCode( bg_color, backgroundID, icon_color, iconID, text_color, textID )
    end
end

function ReadCPVisors( ply, pvisor, svisor )
    if !IsValid( ply ) then return end
    if !cpoutfit.IsSupported(ply:GetModel()) then return end

    if pvisor then
        local pvisor_table = string.Explode( "_", pvisor )
        ply:SetPrimaryVisorColor( Vector( tonumber(pvisor_table[1]), tonumber(pvisor_table[2]), tonumber(pvisor_table[3]) ) )
    end

    if svisor then
        local svisor_table = string.Explode( "_", svisor )
        ply:SetSecondaryVisorColor( Vector( tonumber(svisor_table[1]), tonumber(svisor_table[2]), tonumber(svisor_table[3]) ) )
    end
end

if (SERVER) then
	function PLUGIN:PostPlayerLoadout(player)
		local outfit = player:getChar():getData("CP08_Outfit", "0_0000000000_0_0_0")  
		local armband = player:getChar():getData("CP08_Armband", "(0,0,0)_0_(0,0,0,0)_0_(0,0,0,0)_0") 
		local pvisor = player:getChar():getData("CP08_PVisor", "0_0_0")
		local svisor = player:getChar():getData("CP08_SVisor", "0_0_0")
		local skin_overwrite = player:getChar():getData("MdlSkin", 0)
		local bodygroups = player:getChar():getData("BodyGroups", {})

		for k, v in pairs( player:GetBodyGroups() ) do
			player:SetBodygroup( v.id, 0 )
		end

		for k, v in pairs( bodygroups ) do
			for z, x in pairs( v ) do
				player:SetBodygroup( z, tonumber(x) )
			end
		end
		
		player:SetSubMaterial( nil, nil )

		if cpoutfit.IsSupported(player:GetModel()) then
			ReadCPOutfit(player, outfit)
			ReadCPArmband(player, armband)
			ReadCPVisors(player, pvisor, svisor)
		end

		if skin_overwrite then
			player:SetSkin(skin_overwrite)
		end
	end

	function PLUGIN:OnCharCreated(client, character)
        if character:getFaction() == FACTION_MPF then
            character:setData("CP08_Outfit", "0_0000000000_0_0_1")
			character:setData("CP08_Armband", "(100,125,140)_8_(50,255,60,255)_1_(200,225,170,255)_37")
			character:setData("CP08_PVisor", "-1_-1_-1")
			character:setData("CP08_SVisor", "0_3_3.5")
        end
	end

end