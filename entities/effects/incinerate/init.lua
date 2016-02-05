

// thanks Chad!


// materials
local mats = {
	"effects/fleck_cement1",
	"effects/fleck_cement2",
	"particles/smokey"

};


/*------------------------------------
	Init
------------------------------------*/
function EFFECT:Init( data )

	// read data
	local entity = data:GetEntity();
	if( !ValidEntity( entity ) ) then return; end
	
	local mins, maxs = entity:WorldSpaceAABB();
	local pos = entity:OBBCenter();
	local size = entity:BoundingRadius() * 0.9;
	local ashes = entity:BoundingRadius() * 10;
	local ash_size = math.Clamp( ashes * 0.001, 3, 32 );
	local vel = data:GetStart();
	
	// sound
	WorldSound( "weapons/flashbang/flashbang_explode2.wav", pos, 100, 100 );
	WorldSound( "player/pl_burnpain1.wav", pos, 100, 100 );
	
	// light!
	local dynlight = DynamicLight( 0 );
		dynlight.Pos = data:GetOrigin();
		dynlight.Size = 512;
		dynlight.Decay = 100;
		dynlight.R = 255;
		dynlight.G = 160;
		dynlight.B = 50;
		dynlight.DieTime = CurTime() + 0.25;
	
	
	local emitter = ParticleEmitter( pos );
	
	// flames
	for i = 1, 32 do
	
		// create a random offset
		local offset = Vector(
			math.random( mins.x, maxs.x ),
			math.random( mins.y, maxs.y ),
			math.random( mins.z, maxs.z )
		);
	
		// create a particle
		local particle = emitter:Add( "effects/fire_cloud1", offset );
			particle:SetVelocity( VectorRand() * math.random( 1, 100 ) + vel );
			particle:SetDieTime( math.Rand( 0.34, 0.55 ) );
			particle:SetColor(
				255, 200, 190
			);
			particle:SetStartSize( math.random( size * 0.5, size ) );
			particle:SetEndSize( size * 1.5 );
			particle:SetStartAlpha( 255 );
			particle:SetEndAlpha( 0 );
			particle:SetRoll( math.random( 0, 360 ) );
			particle:SetRollDelta( math.Rand( -8, 8 ) );
			particle:SetAirResistance( 500 );
	
	end
	
	
	// smoke
	for i = 1, 16 do
	
		// create a random offset
		local offset = Vector(
			math.random( mins.x, maxs.x ),
			math.random( mins.y, maxs.y ),
			math.random( mins.z, maxs.z )
		);
	
		// create a particle
		local particle = emitter:Add( "particles/smokey", offset );
			particle:SetVelocity( VectorRand() * math.random( 1, 50 ) + vel );
			particle:SetDieTime( math.Rand( 1.25, 1.75 ) );
			particle:SetColor(
				128, 128, 128
			);
			particle:SetStartSize( size * 1.5 );
			particle:SetEndSize( size * 1.5 );
			particle:SetStartAlpha( 96 );
			particle:SetEndAlpha( 0 );
			particle:SetRoll( math.random( 0, 360 ) );
			particle:SetRollDelta( math.Rand( -8, 8 ) );
			particle:SetAirResistance( 100 );
	
	end
	
	
	
	// ashes
	for i = 1, ashes do
	
		// create a random offset
		local offset = Vector(
			math.random( mins.x, maxs.x ),
			math.random( mins.y, maxs.y ),
			math.random( mins.z, maxs.z )
		);
		
		//
		local size = math.Rand( 1, ash_size );
	
		// create a particle
		local particle = emitter:Add( mats[ math.random( 3 ) ], offset );
			particle:SetVelocity( VectorRand() * math.random( 1, 25 ) + vel );
			particle:SetDieTime( math.Rand( 2.25, 3.75 ) );
			particle:SetColor(
				40, 40, 40
			);
			particle:SetStartSize( size );
			particle:SetEndSize( size );
			particle:SetStartAlpha( 255 );
			particle:SetEndAlpha( 0 );
			particle:SetRoll( math.random( 0, 360 ) );
			particle:SetRollDelta( math.Rand( -8, 8 ) );
			particle:SetGravity( Vector( 0, 0, -math.random( 100, 500 ) ) );
			particle:SetCollide( true );
			particle:SetAirResistance( 5 );
			particle:SetBounce( 0.1 );
	
	end
	
	emitter:Finish();
	

end



/*------------------------------------
	Think
------------------------------------*/
function EFFECT:Think( )

	return false;

end

/*------------------------------------
	Render
------------------------------------*/
function EFFECT:Render( )

end
