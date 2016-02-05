
// create the materials
local glow = Material( "zahmbeez/lightglow" );
local beam = Material( "zahmbeez/lightpillar" );


/*------------------------------------
	Init
------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetOrigin();
	self.Normal = data:GetNormal();
	
	// timers
	self.HeightTime = CurTime() + 0.25;
	self.WidthTime = CurTime() + 2.5;

	// fade away yet?
	self.FadeTime = CurTime() + 3;
	self.FadeAway = false;
	
	// store a dlight. ( BLEH random sucks ) but EntIndex on effects seems to be the same T_T
	self.Light = math.random( 1, 2048 );
	
	// emitter
	self.Emitter = ParticleEmitter( self.Position );
	
end

/*------------------------------------
	Think
------------------------------------*/
function EFFECT:Think( )
	
	local i;

	// 1 per frame was not dense enough
	for i = 1, 4 do
	
		// calculate a direction
		local dir = self.Normal:Angle():Right():Angle();	// HOLY BAT SHIT that's not obfusticated in the least now is it.
		dir:RotateAroundAxis( self.Normal, math.Rand( 0, 360 ) );
		dir = dir:Forward();
	
		// ring particle
		local particle = self.Emitter:Add( "zahmbeez/lightglow", self.Position );
			particle:SetDieTime( math.Rand( 0.25, 0.75 ) );
			particle:SetLifeTime( 0 );
			particle:SetStartSize( 16 );
			particle:SetEndSize( 1 );
			particle:SetColor( 255, math.Rand( 200, 255 ), math.Rand( 150, 255 ) );
			particle:SetStartAlpha( 128 );
			particle:SetEndAlpha( 0 );
			particle:SetRollDelta( math.Rand( -2, 2 ) );
			particle:SetAirResistance( 100 );
			particle:SetStartLength( 32 );
			particle:SetEndLength( 32 );
			particle:SetGravity( Vector( 0, 0, 300 ) );
			particle:SetVelocity( dir * math.Rand( 100, 300 ) );
			
		// beam particle
		/*
		local particle = self.Emitter:Add( "jintopack/glow", self.Position + dir * math.Rand( 0, 24 ) );
			particle:SetDieTime( math.Rand( 1.5, 1.75 ) );
			particle:SetLifeTime( 0 );
			particle:SetStartSize( 1 );
			particle:SetEndSize( 1 );
			particle:SetColor( 255, math.Rand( 200, 255 ), math.Rand( 150, 255 ) );
			particle:SetStartAlpha( 128 );
			particle:SetEndAlpha( 0 );
			particle:SetRollDelta( math.Rand( -2, 2 ) );
			particle:SetVelocity( self.Normal * 75 );
		*/
			
	end
	
	// time to fade away
	if( !self.FadeAway && self.FadeTime <= CurTime() ) then
	
		self.FadeAway = true;
		self.FadeTime = CurTime() + 2;
		
	// pop	
	elseif( self.FadeAway && self.FadeTime <= CurTime() ) then
	
		// 1 per frame was not dense enough
		for i = 1, 256 do
		
			// calculate a direction
			local dir = self.Normal:Angle():Right():Angle();	// HOLY BAT SHIT that's not obfusticated in the least now is it.
			dir:RotateAroundAxis( self.Normal, math.Rand( 0, 360 ) );
			dir = dir:Forward();
		
			// ring particle
			local particle = self.Emitter:Add( "zahmbeez/lightglow", self.Position + self.Normal * 8 );
				particle:SetDieTime( math.Rand( 0.25, 0.75 ) );
				particle:SetLifeTime( 0 );
				particle:SetStartSize( math.Rand( 4, 32 ) );
				particle:SetEndSize( math.Rand( 4, 32 ) );
				particle:SetColor( 255, math.Rand( 200, 255 ), math.Rand( 150, 255 ) );
				particle:SetStartAlpha( 60 );
				particle:SetEndAlpha( 0 );
				particle:SetRollDelta( math.Rand( -2, 2 ) );
				particle:SetAirResistance( 20 );
				particle:SetGravity( Vector( 0, 0, -100 ) );
				particle:SetBounce( 0.3 );
				particle:SetCollide( true );
				particle:SetVelocity( dir * math.Rand( 100, 300 ) );
				
		end
	
	end

	// die
	return self.FadeTime > CurTime();

end

/*------------------------------------
	Render
------------------------------------*/
function EFFECT:Render( )

	local curtime = CurTime();
	local heightpercent = 1 - math.Clamp( ( self.HeightTime - curtime ) / 0.25, 0, 1 );
	local widthpercent = 1 - math.Clamp( ( self.WidthTime - curtime ) / 2.5, 0, 1 );
	local alphapercent =  math.Clamp( ( self.FadeTime - curtime ) / 2, 0, 1 );
	local alpha = self.FadeAway && ( 255 * alphapercent ) || 255;
	
	// dynamic lights ftw
	local light = DynamicLight( self.Light );
		light.Pos = self.Position + self.Normal * 16;
		light.Size = 384 + math.Rand( -8, 8 );
		light.Decay = 384;
		light.DieTime = CurTime() + 4;
		light.R = 255;
		light.G = 200;
		light.B = 150;
		light.Brightness = ( 4 * heightpercent );
		
	// draw sprite
	render.SetMaterial( glow );
	render.DrawSprite(
		self.Position,
		128, 128,
		Color( 255, 200, 150, alpha * heightpercent )
	
	);
	
	// draw the beam
	render.SetMaterial( beam );
	render.DrawBeam(
		self.Position,
		self.Position + self.Normal * 216 * heightpercent,
		8 + ( 64 * widthpercent ),
		1, 0.01,
		Color( 255, 200, 150, alpha * heightpercent )
	
	);
	
end

