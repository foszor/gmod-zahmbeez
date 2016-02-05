
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// setup SENT
	self.Entity:DrawShadow( true );
	self.Entity:SetModel( self.Model );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_NONE );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PLAYER );
	
	// get phys
	local phys = self.Entity:GetPhysicsObject();
	
	// validate
	if ( ValidEntity( phys ) ) then
	
		// freeze it
		phys:EnableMotion( false );
		
	end
	
end


/*------------------------------------
	KeyValue
------------------------------------*/
function ENT:KeyValue( key, value )

	// defaults
	self.KeyValues = self.KeyValues or {};
	
	// check for event
	if ( key:sub( 1, 2 ) == "On" ) then
	
		// save
		self:StoreOutput( key, value );
	
	else
	
		// lowercase
		key = string.lower( key );
		
		// store
		self.KeyValues[ key ] = value;
	
	end

end


/*------------------------------------
	OnRoundRestart
------------------------------------*/
function ENT:OnRoundRestart( )
	
end

  
/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )
	
end


/*------------------------------------
	Use
------------------------------------*/
function ENT:Use( activator, caller )
	
end


/*------------------------------------
	OnTakeDamage
------------------------------------*/
function ENT:OnTakeDamage( dmg )

end
