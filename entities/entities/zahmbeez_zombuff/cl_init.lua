
// shared file
include( 'shared.lua' );

// materials
local flame = Material( "particles/fire1" );

// rendergroup
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT;

/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// create emitter
	self.Emitter = ParticleEmitter( self.Entity:GetPos() );
	
	// frame
	self.Frame = 0;
	
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )
	
end


local BuffFunctions = {

	[ BUFF_FIRE ] = function ( self, pos )
	
		// create the particle
		local particle = self.Emitter:Add( "particles/smokey", pos );
		particle:SetVelocity( Vector( math.random( -5, 5 ) * 0.001, math.random( -5, 5 ) * 0.001, 5 ) );
		particle:SetDieTime( 0.5 )
		particle:SetStartAlpha( math.random( 100, 140 ) );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( 2 );
		particle:SetEndSize( 10 + math.random( 1, 8 ) );
		particle:SetRoll( math.random( 0, 1 ) );
		particle:SetRollDelta( math.random( -2, 2 ) );
		
		// set color
		local c = math.random( 40, 120 );
		particle:SetColor( c, c, c );
		
		// movement stuff
		particle:SetAirResistance( 0 );
		particle:SetGravity( Vector( 0, 0, math.random( 10, 20 ) ) );
		particle:SetCollide( false );
		particle:SetBounce( 0 );
	
	end,
	
	[ BUFF_ICE ] = function ( self, pos )
	
		// create the particle
		local particle = self.Emitter:Add( "zahmbeez/lightglow", pos );
		particle:SetVelocity( Vector( math.random( -5, 5 ) * 0.001, math.random( -5, 5 ) * 0.001, 5 ) );
		particle:SetDieTime( 0.2 )
		particle:SetStartAlpha( math.random( 100, 140 ) );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( math.random( 8, 10 ) );
		particle:SetEndSize( math.random( 12, 14 ) );
		particle:SetRoll( math.random( 0, 1 ) );
		particle:SetRollDelta( math.random( -2, 2 ) );
		
		// set color
		particle:SetColor( 100, 100, math.random( 100, 255 ) );
		
		// movement stuff
		particle:SetAirResistance( 0 );
		particle:SetGravity( Vector( 0, 0, 0 ) );
		particle:SetCollide( false );
		particle:SetBounce( 0 );
	
	end,
	
	[ BUFF_POISON ] = function ( self, pos )
	
		// create the particle
		local particle = self.Emitter:Add( "zahmbeez/lightglow", pos );
		particle:SetVelocity( Vector( math.random( -5, 5 ) * 0.001, math.random( -5, 5 ) * 0.001, 5 ) );
		particle:SetDieTime( 1 )
		particle:SetStartAlpha( math.random( 100, 140 ) );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( 4 );
		particle:SetEndSize( 6 + math.random( 1, 8 ) );
		particle:SetRoll( math.random( 0, 1 ) );
		particle:SetRollDelta( math.random( -2, 2 ) );
		
		// set color
		particle:SetColor( 0, math.random( 80, 200 ), 0 );
		
		// movement stuff
		particle:SetAirResistance( 0 );
		particle:SetGravity( Vector( 0, 0, math.random( -80, -60 ) ) );
		particle:SetCollide( true );
		particle:SetBounce( 0.2 );
	
	end

};

local BuffFunctionsDraw = {

	[ BUFF_FIRE ] = function ( self, pos )

		// animate
		self.Frame = self.Frame + FrameTime() * 30;
		if ( self.Frame > 53 ) then
		
			self.Frame = 0;
		
		end
		
		// draw
		flame:SetMaterialFloat( "$frame", self.Frame );
		render.SetMaterial( flame );
		render.DrawBeam(
			pos, pos + Vector( 0, 0, 16 ),
			8,
			0.99, 0,
			Color( 255, 255, 255, 255 )
		
		);
	
	end,

};


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )
	
	// puff puff give
	if ( CurTime() > ( self.NextEmit or 0 ) ) then
	
		// get owner
		local npc = self.Entity:GetOwner();
		
		// validate
		if ( !ValidEntity( npc ) && npc:Health() > 0 ) then
		
			return;
			
		end
		
		// get type
		local bufftype = self.Entity:GetType();
		
		// make sure its valid
		if ( BuffFunctions[ bufftype ] ) then
	
			// left hand
			local hand = npc:GetAttachment( npc:LookupAttachment( "Blood_Left" ) );
			BuffFunctions[ bufftype ]( self, hand.Pos );
			
			// right hand
			hand = npc:GetAttachment( npc:LookupAttachment( "Blood_Right" ) );
			BuffFunctions[ bufftype ]( self, hand.Pos );
			
		end
		
		// set puff
		self.NextEmit = CurTime() + 0;
	
	end
	
	// think fast
	self.Entity:NextThink( CurTime() );
	return true;
	
end

/*------------------------------------
	Draw
------------------------------------*/
function ENT:DrawTranslucent( )
	
	// puff puff give
	//if ( CurTime() > ( self.NextEmit or 0 ) ) then
	
		// get owner
		local npc = self.Entity:GetOwner();
		
		// validate
		if ( !ValidEntity( npc ) && npc:Health() > 0 ) then
		
			return;
			
		end
		
		// get type
		local bufftype = self.Entity:GetType();
		
		// make sure its valid
		if ( BuffFunctionsDraw[ bufftype ] ) then
	
			// left hand
			local hand = npc:GetAttachment( npc:LookupAttachment( "Blood_Left" ) );
			BuffFunctionsDraw[ bufftype ]( self, hand.Pos );
			
			// right hand
			hand = npc:GetAttachment( npc:LookupAttachment( "Blood_Right" ) );
			BuffFunctionsDraw[ bufftype ]( self, hand.Pos );
			
		end
		
		// set puff
		//self.NextEmit = CurTime() + 0;
	
	//end

end
