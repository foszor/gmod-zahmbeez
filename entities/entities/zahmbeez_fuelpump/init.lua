
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// base class
	self.BaseClass.Initialize( self );
	
	// radar
	self.Entity:SetRadarType( RADAR_OBJECTIVE );
	
end


/*------------------------------------
	Use
------------------------------------*/
function ENT:Use( activator, caller )

	// default use time
	self.LastUse = self.LastUse or 0;
	
	// check last use
	if ( CurTime() - self.LastUse < 2 ) then
	
		// dont let them use it too often
		return;
		
	elseif ( !ValidEntity( activator ) || !activator:IsPlayer() ) then
	
		// only players
		return;
		
	elseif ( activator:IsHolding() ) then
	
		// carry only one thing at a time
		return;
		
	elseif ( activator:IsSpectating() ) then
	
		// spectators cant use
		return;
		
	end
	
	// flag last used
	self.LastUse = CurTime();
	
	// create fuel
	local fuel = ents.Create( "zahmbeez_fuel" );
	fuel:Spawn();
	fuel:SetPos( activator:GetPos() );
	
	// own
	fuel:SetCourrier( activator );
	
	// validate
	if ( ValidEntity( activator.Avatar ) ) then
	
		// own
		fuel:SetCourrierAvatar( activator.Avatar.Avatar );
		
	end
	
	// give to player
	activator:HoldEntity( fuel );
	
	// trigger
	self:TriggerOutput( "OnFuelTaken", self.Entity );
	
end
