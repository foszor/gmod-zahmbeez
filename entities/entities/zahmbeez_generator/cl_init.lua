
// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// get entity angles
	local angles = self.Entity:GetAngles();
	
	// move to the exhaust opening
	self.Offset = ( angles:Up() * 74 ) + ( angles:Forward() * 10 );
	
	// create emitter
	self.Emitter = ParticleEmitter( self.Entity:GetPos() + self.Offset );
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// default puff
	self.LastPuff = self.LastPuff or CurTime();
	
	// puff puff give
	if ( ( CurTime() - self.LastPuff > 1 || math.random( 1, 5 ) == 1 ) && self.Entity:GetOn() ) then
	
		// create the particle
		local particle = self.Emitter:Add( "particles/smokey", self.Entity:GetPos() + self.Offset );
		particle:SetVelocity( Vector( math.random( -5, 5 ) * 0.001, math.random( -5, 5 ) * 0.001, 5 ) );
		particle:SetDieTime( math.random( 1, 3 ) )
		particle:SetStartAlpha( math.random( 100, 140 ) );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( 2 );
		particle:SetEndSize( 10 + math.random( 1, 8 ) );
		particle:SetRoll( math.random( 0, 1 ) );
		particle:SetRollDelta( math.random( -2, 2 ) );
		
		// set color
		local c = math.random( 130, 180 );
		particle:SetColor( c, c, c );
		
		// movement stuff
		particle:SetAirResistance( 0 );
		particle:SetGravity( Vector( 0, 0, math.random( 10, 20 ) ) );
		particle:SetCollide( false );
		particle:SetBounce( 0 );
		
		// set puff
		self.LastPuff = CurTime();
	
	end
	
	// think fast
	self.Entity:NextThink( CurTime() + 0.7 );
	return true;
	
end


/*------------------------------------
	HUDPaint
------------------------------------*/
function ENT:HUDPaint( LP, xscale, yscale )

end


/*------------------------------------
	RadarPaint
------------------------------------*/
function ENT:RadarPaint( LP )

	// get position
	local pos = self:GetPos():ToScreen();
	
	// draw text
	draw.SimpleTextOutlined(
		("Fuel: %d"):format( self.Entity:GetFuel() ), // text
		"ZahmbeezTarget", // font
		pos.x, // x position
		pos.y, // y position
		Color( 200, 200, 200, 255 ), // font color
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
		2, // border size
		Color( 0, 0, 0, 60 ) // border color
	);

end
