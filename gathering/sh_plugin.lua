PLUGIN.name = "Gathering System"
PLUGIN.author = "DrodA & AleXXX_007"
PLUGIN.desc = "New brand gathering system"

function PLUGIN:OnSeedCreated(seed, item, load)
	seed:PhysicsInit(SOLID_VPHYSICS)
	seed:SetMoveType(MOVETYPE_VPHYSICS)
	seed:SetUseType(SIMPLE_USE)

	local physicsObject = seed:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Sleep()
			physicsObject:EnableMotion(false)
		end
end