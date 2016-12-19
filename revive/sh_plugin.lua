PLUGIN.name = "Revive"
PLUGIN.author = "_FR_Starfox64 (NS 1.0), Neon (NS 1.1), AleXXX_007"
PLUGIN.desc = "Players never dies! They just lose consciousness."

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Revive Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

local PLUGIN = PLUGIN

nut.command.add("respawn", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function (client, arguments)
	local target
		if arguments[1] == nil then
			target = client
		end	
		if !target then
			target = nut.command.findPlayer(client, arguments[1])
		end
		if target:getChar() then
			local check, pos
			for k,v in ipairs(ents.FindByClass("prop_ragdoll")) do
				if (IsValid(v.player) and v.player == target) then
					check = true
					pos = v:GetPos()
				end
			end
			if check then
				target:UnSpectate()
				target:Spawn()
				target:SetPos(pos)
				target:notify("Вы были возрождены!")
				client:notify("Персонаж ".. target:getChar():getName() .." был возрожден.")
			else
				client:notify("Персонаж ".. target:getChar():getName() .." находится в добром здравии и не может быть возрожден.")
			end
		end
	end
})

if CLIENT then
	local owner, w, h, ceil, ft, clmp
	ceil = math.ceil
	clmp = math.Clamp
	local aprg, aprg2 = 0, 0
	function nut.hud.drawDeath()
		owner = LocalPlayer()
		ft = FrameTime()
		w, h = ScrW(), ScrH()

		if (owner:getChar()) then
			if (owner:Alive()) then
				if (aprg != 0) then
					aprg2 = clmp(aprg2 - ft*1.3, 0, 1)
					if (aprg2 == 0) then
						aprg = clmp(aprg - ft*.7, 0, 1)
					end
				end
			else
				if (aprg2 != 1) then
					aprg = clmp(aprg + ft*.5, 0, 1)
					if (aprg == 1) then
						aprg2 = clmp(aprg2 + ft*.4, 0, 1)
					end
				end
			end
		end

		if (IsValid(nut.char.gui) and nut.gui.char:IsVisible() or !owner:getChar()) then
			return
		end

		surface.SetDrawColor(25, 0, 0, ceil((aprg^.5) * 155))
		surface.DrawRect(-1, -1, w+2, h+2)
		local tx, ty = nut.util.drawText("Вы без сознания.", w/2, h/10, ColorAlpha(color_white, aprg2 * 255), 1, 1, "nutDynFontMedium", aprg2 * 255)
	end
	
	netstream.Hook("nut_DeadBody", function( index )
		local ragdoll = Entity(index)

		if IsValid(ragdoll) then
			ragdoll.isDeadBody = true
		end
	end)
else
	function PLUGIN:PlayerSpawn( client )
		client:UnSpectate()
		if not client:getChar() then 
			return 
		end

		if IsValid(SCHEMA.Corpses[client]) then
			SCHEMA.Corpses[client]:Remove()
		end
	end

	--[[
		Purpose: Called when the player has died with a valid character.
	--]]

	SCHEMA.Corpses = SCHEMA.Corpses or {}

	function SCHEMA:DoPlayerDeath( client, attacker, dmg )
		if not client:getChar() then 
			return 
		end
		
		--client:getChar():decreaseAttribs(20, math.random(10, 20))
		--client:ChatPrint("Некоторые навыки Вашего персонажа были понижены!")
		--client:getChar():setData( "bleeding", false);
		--client:getChar():setData( "bleeding_level", 0);
		
		SCHEMA.Corpses[client] = ents.Create("prop_ragdoll")
		SCHEMA.Corpses[client]:SetPos(client:GetPos())
		SCHEMA.Corpses[client]:SetModel(client:GetModel())
		SCHEMA.Corpses[client]:Spawn()
		SCHEMA.Corpses[client]:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		local phys = SCHEMA.Corpses[client]:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:ApplyForceCenter(client:GetVelocity() * 15);
		end
		SCHEMA.Corpses[client].player = client
		SCHEMA.Corpses[client]:SetNWFloat("Time", CurTime() + nut.config.deathTime)
		SCHEMA.Corpses[client]:SetNWBool("Body", true)

		timer.Simple(0.5, function()
			netstream.Start(nil, "nut_DeadBody", SCHEMA.Corpses[client]:EntIndex())
		end)

		hook.Run("GenerateEvidences", client, SCHEMA.Corpses[client], attacker, dmg)
		client:getChar():resetParts()
		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(SCHEMA.Corpses[client])
		timer.Simple(0.01, function()
			if(client:GetRagdollEntity() != nil and client:GetRagdollEntity():IsValid()) then
				client:GetRagdollEntity():Remove()
			end
		end)
	end
	function RevivePlayer(client)
		local check, pos
		for k,v in ipairs(ents.FindByClass("prop_ragdoll")) do
			if (IsValid(v.player) and v.player == client) then
				check = true
				pos = v:GetPos()
				
				break
			end
		end
		if !check then return end
		
		client:UnSpectate()
		client:Spawn()
		client:SetPos(pos)
	end
	
	function PLUGIN:KeyRelease(client, key)
		if (key == IN_USE) then
			local tr = util.TraceLine({
			 start  = client:GetShootPos(),
			 endpos = client:GetShootPos() + client:GetAimVector() * 84,
			 filter = client,
			 mask   = MASK_SHOT
			})
			if tr.Hit and IsValid(tr.Entity) and IsValid(tr.Entity.player) then
				if (client:KeyDown(IN_WALK)) then
					client:ConCommand("say /charsearch")
					return
				end
				local entity = tr.Entity
				entity.nutBeingGetUp = true
				entity.player:setAction("Вас поднимают на ноги...", 5)

				client:setAction("Вы помогаете встать ".. entity.player:getChar():getName(), 5)
				client:doStaredAction(entity, function()
					entity.nutBeingGetUp = false
					RevivePlayer(entity.player)
					entity.player:SetHealth(5)
				end, 5, function()
					if (IsValid(entity)) then
						entity.nutBeingGetUp = false
						entity.player:setAction()
					end

					if (IsValid(client)) then
						client:setAction()
					end
				end)				
			end
		end
	end
end