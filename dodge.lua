PLUGIN.name = "Dodge"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Allows players to dodge."
if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		client:getChar():setData("canDodge", true)
	end
	hook.Add("KeyPress","DashBackward",function(ply,key)
		if key != IN_WALK then return end
		if (ply:OnGround() and ply:KeyDown(IN_BACK) and ply:getLocalVar("Dodge") == false and ply:getChar():getData("canDodge") == true) then
			local skill = ply:getChar():getAttrib("stm")
			if skill == nil then
				skill = 0
			end
			local value = ply:getLocalVar("stm", 0) - 10 + skill/10
			if (value <= 0) then
				return
			end
			local power = 500 + skill*5
			ply:leaveSequence()
			ply:setLocalVar("stm", value)
			ply:setLocalVar("Dodge", true)
			ply:getChar():updateAttrib("stm", 0.01)
			ply:ViewPunch(Angle(-5, 0, 0));
			ply:SetLocalVelocity((ply:GetForward() * -1) * power);
			ply:EmitSound("physics/flesh/flesh_impact_hard".. math.random(1, 6) ..".wav", 75)
		end
		if not ply:OnGround() then
			return
		end
		timer.Simple(0.75, function()
			ply:setLocalVar("Dodge", false)
		end)
	end)
	
	hook.Add("KeyPress","DashForward",function(ply,key)
		if key != IN_WALK then return end
		if ply:OnGround() and ply:KeyDown(IN_FORWARD) and ply:getLocalVar("Dodge") == false and ply:getChar():getData("canDodge") == true then
			local skill = ply:getChar():getAttrib("stm")
			if skill == nil then
				skill = 0
			end
			local value = ply:getLocalVar("stm", 0) - 10 + skill/10
			if (value <= 0) then
				return
			end
			local power = 500 + skill*5
			ply:leaveSequence()
			ply:setLocalVar("stm", value)
			ply:setLocalVar("Dodge", true)
			ply:getChar():updateAttrib("stm", 0.01)
			ply:ViewPunch(Angle(5, 0, 0));
			ply:SetLocalVelocity((ply:GetForward() * 1) * power);
			ply:EmitSound("physics/flesh/flesh_impact_hard".. math.random(1, 6) ..".wav", 75)
		end
		if not ply:OnGround() then
			return
		end
		timer.Simple(0.75, function()
			ply:setLocalVar("Dodge", false)
		end)
	end)
	
	hook.Add("KeyPress","DashRight",function(ply,key)
		if key != IN_WALK then return end
		if ply:OnGround() and ply:KeyDown(IN_MOVERIGHT) and ply:getLocalVar("Dodge") == false and ply:getChar():getData("canDodge") == true then
			local skill = ply:getChar():getAttrib("stm")
			if skill == nil then
				skill = 0
			end
			local value = ply:getLocalVar("stm", 0) - 10 + skill/10
			if (value <= 0) then
				return
			end
			local power = 500 + skill*5
			ply:leaveSequence()
			ply:setLocalVar("stm", value)
			ply:setLocalVar("Dodge", true)
			ply:getChar():updateAttrib("stm", 0.01)
			ply:ViewPunch(Angle(0, 0, 10));
			ply:SetLocalVelocity((ply:GetRight() * 1) * power);
			ply:EmitSound("physics/flesh/flesh_impact_hard".. math.random(1, 6) ..".wav", 75)
		end
		if not ply:OnGround() then
			return
		end
		timer.Simple(0.75, function()
			ply:setLocalVar("Dodge", false)
		end)
	end)
	
	hook.Add("KeyPress","DashLeft",function(ply,key)
		if key != IN_WALK then return end
		if ply:OnGround() and ply:KeyDown(IN_MOVELEFT) and ply:getLocalVar("Dodge") == false and ply:getChar():getData("canDodge") == true then
			local skill = ply:getChar():getAttrib("stm")
			if skill == nil then
				skill = 0
			end
			local value = ply:getLocalVar("stm", 0) - 10 + skill/10
			if (value <= 0) then
				return
			end
			local power = 500 + skill*5
			ply:leaveSequence()
			ply:setLocalVar("stm", value)
			ply:setLocalVar("Dodge", true)
			ply:getChar():updateAttrib("stm", 0.01)
			ply:ViewPunch(Angle(0, 0, -10));
			ply:SetLocalVelocity((ply:GetRight() * -1) * power);
			ply:EmitSound("physics/flesh/flesh_impact_hard".. math.random(1, 6) ..".wav", 75)
		end
		if not ply:OnGround() then
			return
		end
		timer.Simple(0.75, function()
			ply:setLocalVar("Dodge", false)
		end)
	end)	
end