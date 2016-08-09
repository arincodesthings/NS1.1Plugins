PLUGIN.name = "Alcohol"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds alcohol with effects."

function PLUGIN:Drunk(client)
	local skill = client:getChar():getAttrib("end")
	if skill == nil then
		skill = 0
	end
	client:setLocalVar("drunk", client:getLocalVar("drunk") + client:getChar():getData("drunk"))
	if client:getLocalVar("drunk") > 100 then
		local unctime = (client:getLocalVar("drunk") - 100) * 7.5
		client:ConCommand("say /fallover ".. unctime .."")
	end
		timer.Create("drunk", 5, 0, function()
			client:setLocalVar("drunk", client:getLocalVar("drunk") - 1)
			client:getChar():setData("drunk", client:getLocalVar("drunk"))
			if client:getChar():getData("drunk") == 0 then
				timer.Remove("drunk")
			end
		end)
end
if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		client:setLocalVar("drunk", 0)
		client:getChar():setData("drunk", 0)
	end
	function PLUGIN:PlayerDeath(client)
		client:setLocalVar("drunk", 0)
		client:getChar():setData("drunk", 0)
	end
end
if (CLIENT) then
	function PLUGIN:RenderScreenspaceEffects()
	local default = {}
	default["$pp_colour_addr"] = 0
	default["$pp_colour_addg"] = 0
	default["$pp_colour_addb"] = 0
	default["$pp_colour_brightness"] = 0
	default["$pp_colour_contrast"] = 1
	default["$pp_colour_colour"] = 0.90
	default["$pp_colour_mulr"] = 0
	default["$pp_colour_mulg"] = 0
	default["$pp_colour_mulb"] = 0

		local a = LocalPlayer():getLocalVar("drunk")
		if a == nil then
			a = 0
		end
		if (a > 20) then
			local value = (LocalPlayer():getLocalVar("drunk"))*0.01
			DrawMotionBlur( 0.2, value, 0.05 )
		else
			DrawColorModify(default)
		end
	end
end