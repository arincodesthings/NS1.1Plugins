PLUGIN.name = "Realistic effect"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds viewbobbing."

PLUGIN.currAng = PLUGIN.currAng or Angle( 0, 0, 0 )
PLUGIN.currPos = PLUGIN.currPos or Vector( 0, 0, 0 )
PLUGIN.targetAng = PLUGIN.targetAng or Angle( 0, 0, 0 )
PLUGIN.targetPos = PLUGIN.targetPos or Vector( 0, 0, 0 )
PLUGIN.resultAng = PLUGIN.resultAng or Angle( 0, 0, 0 )

local velo = FindMetaTable( "Entity" ).GetVelocity
local twoD = FindMetaTable( "Vector" ).Length2D
local math_Clamp = math.Clamp

function PLUGIN:CalcView( pl, pos, ang, fov )
	if !IsValid(LocalPlayer()) or (IsValid(nut.gui.char)) then return end
	if ( pl:CanOverrideView( ) or pl:GetViewEntity( ) != pl ) then return end
	local wep = pl:GetActiveWeapon( )
	
	local mouseSmoothingScale = 0

	mouseSmoothingScale = 12
	
	local realTime = RealTime( )
	local frameTime = FrameTime( )
	local vel = math.floor( twoD( velo( pl ) ) )
	
	if ( pl:OnGround( ) ) then
		local walkSpeed = pl:GetWalkSpeed( )
		
		if ( vel > walkSpeed + 5 ) then
			local runSpeed = pl:GetRunSpeed( )
			
			local perc = math_Clamp( vel / runSpeed * 100, 0.5, 5 )
			self.targetAng = Angle( math.abs( math.cos( realTime * ( runSpeed / 33 ) ) * 0.4 * perc ), math.sin( realTime * ( runSpeed / 29 ) ) * 0.5 * perc, 0 )
			self.targetPos = Vector( 0, 0, math.sin( realTime * ( runSpeed / 30 ) ) * 0.4 * perc )
		else
			local perc = math_Clamp( ( vel / walkSpeed * 100 ) / 30, 0, 4 )
			self.targetAng = Angle( math.cos( realTime * ( walkSpeed / 8 ) ) * 0.2 * perc, 0, 0 )
			self.targetPos = Vector( 0, 0, ( math.sin( realTime * ( walkSpeed / 8 ) ) * 0.5 ) * perc )
		end
	else
		if (!pl:OnGround( ) ) then
			self.targetPos = Vector( 0, 0, 0 )
			self.targetAng = Angle( 0, 0, 0 )
		else
			if ( pl:WaterLevel( ) >= 2 ) then
				self.targetPos = Vector( 0, 0, 0 )
				self.targetAng = Angle( 0, 0, 0 )
			else
				vel = math.abs( pl:GetVelocity( ).z )
				local af = 0
				local perc = math_Clamp( vel / 200, 0.1, 8 )
				
				if ( perc > 1 ) then
					af = perc
				end
				
				self.targetAng = Angle( math.cos( realTime * 15 ) * 2 * perc + math.Rand( -af * 2, af * 2 ), math.sin( realTime * 15 ) * 2 * perc + math.Rand( -af * 2, af * 2 ) ,math.Rand( -af * 5, af * 5 ) )
				self.targetPos = Vector( math.cos( realTime * 15 ) * 0.5 * perc, math.sin( realTime * 15 ) * 0.5 * perc, 0 )
			end
		end
	end
	
	if ( mouseSmoothingScale != 0 ) then
		self.resultAng = LerpAngle( math_Clamp( math_Clamp( frameTime, 1 / 120, 1 ) * mouseSmoothingScale, 0, 5 ), self.resultAng, ang )
	else
		self.resultAng = ang
	end
	
	self.currAng = LerpAngle( frameTime * 10, self.currAng, self.targetAng )
	self.currPos = LerpVector( frameTime * 10, self.currPos, self.targetPos )
	
	return {
		origin = pos + self.currPos,
		angles = self.resultAng + self.currAng,
		fov = fov
	}
end