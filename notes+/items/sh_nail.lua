ITEM.name = "Кнопка"
ITEM.desc = "Кнопка, с помощью которой можно прикрепить что-нибудь к чему-нибудь."
ITEM.model = "models/props_c17/TrapPropeller_Lever.mdl"
ITEM.Width = 1
ITEM.Height = 1
ITEM.price = 5
ITEM.permit = "mat"

ITEM.functions.Nail = {
	name = "Зафиксировать",
	icon = "icon16/anchor.png",
	onRun = function(item)
	
	local function MakeNail( Ent1, Ent2, Bone1, Bone2, forcelimit, Pos, Ang )

	local constraint = constraint.Weld( Ent1, Ent2, Bone1, Bone2, forcelimit, false )
	
	constraint.Type = "Nail"
	constraint.Pos = Pos
	constraint.Ang = Ang

	Pos = Ent1:LocalToWorld( Pos )
	Ent1:GetPhysicsObject():EnableMotion(false);

	local nail = ents.Create( "gmod_nail" )
		nail:SetPos( Pos )
		nail:SetAngles( Ang )
		nail:SetParentPhysNum( Bone1 )
		nail:SetParent( Ent1 )

	nail:Spawn()
	nail:Activate()

	constraint:DeleteOnRemove( nail )

	return constraint, nail
	end
	local player = item.player
	local trace = player:GetEyeTrace()
	// Bail if we hit world or a player
	if (  !trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local tr = {}
		tr.start = trace.HitPos
		tr.endpos = trace.HitPos + (player:GetAimVector() * 16.0)
		tr.filter = { player, trace.Entity }
	local trTwo = util.TraceLine( tr )
	
	if ( trTwo.Hit && !trTwo.Entity:IsPlayer() ) then

		// Get client's CVars
		local forcelimit = "100"

		// Client can bail now
		if ( CLIENT ) then return true end

		local vOrigin = trace.HitPos - (player:GetAimVector() * 8.0)
		local vDirection = player:GetAimVector():Angle()

		vOrigin = trace.Entity:WorldToLocal( vOrigin )
		
		// Weld them!
		local constraint, nail = MakeNail( trace.Entity, trTwo.Entity, trace.PhysicsBone, trTwo.PhysicsBone, forcelimit, vOrigin, vDirection )
		if !constraint:IsValid() then return end

		return true
	end
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}