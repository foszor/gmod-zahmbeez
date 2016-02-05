
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
	self.Entity:SetNoDraw( true );
	self.Entity:SetMoveType( MOVETYPE_NOCLIP );
	self.Entity:SetSolid( SOLID_NONE );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	
end


/*------------------------------------
	SetPlayer
------------------------------------*/
function ENT:SetPlayer( pl )

	// store player
	self.Entity:SetOwner( pl );
	self.Player = pl;
	
	// set model
	self.Model = Model( pl:GetModel() );
	
	// think fast
	self.Entity:NextThink( CurTime() );
	
	// get position & angle
	local pos = pl:GetPos();
	local ang = pl:GetAngles();
	
	// create avatar (for the avatar? lol)
	local avatar = ents.Create( "generic_actor" );
	avatar:SetModel( self.Model );
	
	// set position & angles
	avatar:SetPos( pos );
	avatar:SetAngles( ang );
	
	// spawn & save
	avatar:Spawn();
	self.Avatar = avatar;
	
	// make sure we kill it too
	self:DeleteOnRemove( self.Avatar );
	
	// setup
	avatar:SetSolid( SOLID_NONE );
	
	// kill the AI
	timer.Simple( 1, function()
	
		avatar:SetSchedule( SCHED_NPC_FREEZE );
		avatar:SetNPCState( NPC_STATE_SCRIPT );
		avatar:Fire( "disableshadows", true );
		avatar:Fire( "disablereceiveshadows", true );
		
	end );
	
	// own it
	self.Avatar:SetOwner( pl );
	self.Avatar:SetParent( pl );
	
	// set position & angles
	self.Entity:SetPos( pos );
	self.Entity:SetAngles( ang );
	
	// own it
	self.Entity:SetOwner( pl );
	self.Entity:SetParent( pl );
	
	// save it
	self.Entity:SetNWEntity( "Avatar", self.Avatar );
	pl.Avatar = self.Entity;
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// get player
	local pl = self.Entity:GetOwner();
	
	// validate
	if ( !ValidEntity( pl ) || !pl:IsPlayer() ) then
	
		// die
		self.Entity:Remove();
		return;
		
	end
	
	self.Entity:SetNWEntity( "Weapon", pl:GetActiveWeapon() );
	
	// think fast
	self.Entity:NextThink( CurTime() );
	return true;
	
end
