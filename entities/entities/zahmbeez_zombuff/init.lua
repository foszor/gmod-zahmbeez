
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
	self.Entity:SetMoveType( MOVETYPE_NONE );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	
end
