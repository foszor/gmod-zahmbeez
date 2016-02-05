
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
	self.Entity:DrawShadow( false );
	self.Entity:SetModel( self.Model );
	self.Entity:SetMoveType( MOVETYPE_NOCLIP );
	self.Entity:SetSolid( SOLID_NONE );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	
end


/*------------------------------------
	SetPlayer
------------------------------------*/
function ENT:SetPlayer( pl )

	// update position
	self.Entity:SetPos( pl:GetShootPos() );
	
	// store player
	self.Player = pl;
	
	// own it
	self.Entity:SetParent( pl );
	self.Entity:SetOwner( pl );
	pl:SetAimController( self );
	
end


/*------------------------------------
	UpdateTransmitState
------------------------------------*/
function ENT:UpdateTransmitState( )

	// force
	return TRANSMIT_ALWAYS;
	
end
