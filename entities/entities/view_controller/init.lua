
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Init
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

	// store player
	self.Entity:SetOwner( pl );
	self.Player = pl;
	
	// think fast
	self.Entity:NextThink( CurTime() );
	
	// update position
	self.Entity:SetPos( pl:GetPos() );
	
	// set players view entity
	pl:SetViewEntity( self.Entity );
	
	// save it
	pl:SetViewController( self.Entity );
	
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
	
	// think fast
	self.Entity:NextThink( CurTime() + 0.5 );
	return true;
	
end


/*------------------------------------
	UpdateTransmitState
------------------------------------*/
function ENT:UpdateTransmitState( )

	// force
	return TRANSMIT_ALWAYS;
	
end


/*------------------------------------
	ChangeViewMode
------------------------------------*/
local function ChangeViewMode( pl, cmd, args )
	
	// dead, spectating and disabled should be ignored
	if ( !pl:Alive() || pl:IsSpectating() ) then
	
		// bai
		return;
		
	end
	
	// default
	pl.NextViewChange = pl.NextViewChange or 0;
	
	// stop continous switching view
	if ( CurTime() < pl.NextViewChange ) then
	
		// bai again
		return;
		
	end
	
	// set next view
	pl.NextViewChange = CurTime() + 0.6;
	
	// toggle
	pl:ToggleViewMode();
	
end

// command
concommand.Add( "zahmbeez_viewmode", ChangeViewMode );
