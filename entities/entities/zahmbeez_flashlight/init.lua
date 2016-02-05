
// send to client
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// include shared
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

	// store player
	self.Entity:SetOwner( pl );
	
	// save it
	pl.FlashLight = self.Entity;
	
	// forward angle
	local forward = self.Entity:GetAngles() + Angle( 90, 0, 0 );
	
	// create flashlight entity
	self.flashlight = ents.Create( "env_projectedtexture" );
	self.flashlight:SetParent( self.Entity );
	
	// position
	self.flashlight:SetLocalPos( Vector( 0, 0, 0 ) );
	self.flashlight:SetLocalAngles( Angle( 90, 90, 90 ) );
		
	// setup
	self.flashlight:SetKeyValue( "enableshadows", 1 );
	self.flashlight:SetKeyValue( "farz", 512 );
	self.flashlight:SetKeyValue( "nearz", 8 );
	self.flashlight:SetKeyValue( "lightfov", 75 );
	self.flashlight:SetKeyValue( "lightcolor", "255 255 255" );
	
	// spawn
	self.flashlight:Spawn();
	
	// set texture
	self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" );
	
	// start off
	self.flashlight:Input( "TurnOff" );
	self:SetOn( false );
	
end


/*------------------------------------
	Toggle
------------------------------------*/
function ENT:Toggle( )

	if ( self:GetOn() ) then
	
		self:SetOn( false );
		self.flashlight:Input( "TurnOff" );
		
	else
	
		self:SetOn( true );
		self.flashlight:Input( "TurnOn" );
	
	end
	
end


/*------------------------------------
	UpdateTransmitState
------------------------------------*/
function ENT:UpdateTransmitState( )

	// force
	return TRANSMIT_ALWAYS;
	
end


/*------------------------------------
	ToggleFlashlight
------------------------------------*/
local function ToggleFlashlight( pl, cmd, args )

	if ( !ValidEntity( pl ) || !pl:IsPlayer() ) then
	
		return;
		
	end
	
	// dead, spectating and disabled should be ignored
	if ( !pl:Alive() || pl:IsSpectating() ) then
	
		// bai
		return;
		
	end
	
	// validate
	if ( ValidEntity( pl.FlashLight ) ) then
	
		// toggle
		pl.FlashLight:Toggle();
	
	end
	
end

// command
concommand.Add( "zahmbeez_flashlight", ToggleFlashlight );
