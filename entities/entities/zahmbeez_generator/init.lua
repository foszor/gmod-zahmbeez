
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
	
	// defaults
	self:SetFuel( 0 );
	self:SetOn( false );
	
end


/*------------------------------------
	OnRoundRestart
------------------------------------*/
function ENT:OnRoundRestart( )

	// give fuel
	self:Refuel();
	
end


/*------------------------------------
	Refuel
------------------------------------*/
function ENT:Refuel( )

	// give fuel
	self:SetFuel( self:GetMaxFuel() );
	
	// think now
	self.Entity:NextThink( CurTime() );
	
end


/*------------------------------------
	ConsumeFuel
------------------------------------*/
function ENT:ConsumeFuel( amt )

	// reduce fuel
	local fuel = math.Clamp( self:GetFuel() - amt, 0, 100 );
	
	// update
	self:SetFuel( fuel );
	
	// return
	return fuel;

end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// default gulp
	self.LastGulp = self.LastGulp or 0;
	
	// check for gulp time
	if ( CurTime() - self.LastGulp > 1 ) then
		
		// consume fuel
		local fuel = self:ConsumeFuel( 1 );
		
		// ran out of fuel but is on
		if ( fuel <= 0 && self:GetOn() ) then
		
			// turn off
			self:Enabled( false );
			
		// has fuel but is off
		elseif ( fuel > 0 && !self:GetOn() ) then
		
			// enable
			self:Enabled( true );
			
		end
		
		// set gulp
		self.LastGulp = CurTime();
		
		// handle sound
		if ( fuel > 0 ) then
		
			// calculate warning level
			local warning_level = self:GetMaxFuel() * ( self.WarningLevel * 0.01 );

			// play it?
			if ( !self.WarningSound && fuel <= warning_level ) then
		
				// flag
				self.WarningSound = true;
				
				// sound
				self:EmitSound( self.SoundWarning, 140, 100 );
				
			// unset it?
			elseif ( fuel > warning_level ) then
			
				// flag
				self.WarningSound = false;
			
			end
		
		end
		
	end

	// think fast
	self.Entity:NextThink( CurTime() + 1 );
	return true;
	
end


/*------------------------------------
	Enabled
------------------------------------*/
function ENT:Enabled( bool )

	// update flag
	self:SetOn( bool );
	
	// enabled
	if ( bool ) then
	
		// make sure sound exists
		if ( !self.Sound ) then
		
			// create it
			self.Sound = CreateSound( self.Entity, self.SoundIdle );
			
		end
		
		// play startup sound
		self.Entity:EmitSound( self.SoundStart, 100, 100 );
		
		// delay start idle sound
		timer.Simple( 1.2, function() self.Sound:Play(); end );
		
		// trigger
		self:TriggerOutput( "OnEnabled", self.Entity );
		
	else
	
		// make sure sound exits
		if ( self.Sound ) then
		
			// stop idle sound
			self.Sound:Stop();
			
		end
		
		// play shutdown sound
		self.Entity:EmitSound( self.SoundStop, 100, 100 );
		
		// trigger
		self:TriggerOutput( "OnDisabled", self.Entity );
		
	end
	
end


/*------------------------------------
	Touch
------------------------------------*/
function ENT:Touch( ent )
	
	// validate entity
	if ( !ValidEntity( ent ) || !ent:IsPlayer() || !ent:IsHolding() ) then
	
		// no go, mr gerbil
		return;
		
	end
	
	// get the entity they are holding
	local held = ent:GetHeldEntity();
	
	// validate
	if ( !ValidEntity( held ) ) then
	
		// its nothing!
		return;
		
	end
	
	// check if its fuel
	if ( held:GetClass() == "zahmbeez_fuel" ) then
		
		// drop it
		ent:DropEntity();
		
		// remove it
		held:Remove();
		
		// add fuel
		self:Refuel();
		
		// play fueled sound
		self.Entity:EmitSound( self.SoundFueled, 140, 100 );
		
		// think now
		self.Entity:NextThink( CurTime() );
		
		// trigger
		self:TriggerOutput( "OnFueled", self.Entity );
	
	end

end
