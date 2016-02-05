
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// setup
	self.Entity:DrawShadow( true );
	self.Entity:SetModel( self.Model );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_NONE );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// check if dead
	if ( self.IsDead || !ValidEntity( self.Entity ) ) then
	
		// dead, dont think
		return;
		
	end

	// get parent
	local parent = self.Entity:GetParent();
	
	// fuel is being carried
	if ( ValidEntity( parent ) ) then
	
		// update 
		self.LastHeld = CurTime();
		
	else
	
		// clear
		self.Entity:SetCourrier( NULL );
		self.Entity:SetCourrierAvatar( NULL );
		
	end
	
	// delay expired
	if ( CurTime() - ( self.LastHeld or 0 ) > 1 ) then
	
		// start effect
		local effectdata = EffectData();
		
		// setup effect
		effectdata:SetStart( Vector( 0, 0, 0 ) );
		effectdata:SetOrigin( self.Entity:GetPos() );
		effectdata:SetEntity( self.Entity );
		
		// dispatch
		util.Effect( "incinerate", effectdata, true, true );
		
		// make invisible
		self.Entity:SetColor( 0, 0, 0, 0 );
		
		// flag as dead
		self.IsDead = true;
		
		// remove
		SafeRemoveEntityDelayed( self.Entity, 0.2 );
		
		// bai
		return true;
		
	end
	
	// think fast
	self.Entity:NextThink( CurTime() + 0.2 );
	return true;
	
end


/*------------------------------------
	UpdateTransmitState
------------------------------------*/
function ENT:UpdateTransmitState( )

	// force
	return TRANSMIT_ALWAYS;
	
end
