
// get metatable.
local meta = FindMetaTable( "Player" );
if ( !meta ) then return; end

// accessors
AccessorFunc( meta, "canattack", "CanAttack", FORCE_BOOL );


/*------------------------------------
	SetSpectate
------------------------------------*/
function meta:SetSpectate( bool )

	// compare old & new
	if ( self.Spectating == bool ) then
	
		// dont do it twice
		return;
		
	end
	
	// change teams
	if ( bool ) then
	
		// raven team
		self:SetTeam( TEAM_RAVENS );
		
	else
	
		// player team
		self:SetTeam( TEAM_PLAYERS );
		self:SetNWInt( "QueuePosition", 0 );
	
	end
	
	// update to client
	self:SetNWBool( "Spectating", bool );
	
end


/*------------------------------------
	SetViewMode
------------------------------------*/
function meta:SetViewMode( mode, silent )

	// ensure mode is either 0 or 1
	mode = math.Clamp( tonumber( mode ), 1, 2 );	
	
	// store
	self:SetViewMode( mode );

end


/*------------------------------------
	ToggleViewMode
------------------------------------*/
function meta:ToggleViewMode( )

	// toggle mode value
	local mode = ( self:GetViewMode() == 2 ) && 1 || 2;
	
	// set it
	self:SetViewMode( mode );

end


/*------------------------------------
	Alert
------------------------------------*/
function meta:Alert( )

	// update time
	self:SetAlertedTime( CurTime() );
	
end


/*------------------------------------
	Think
------------------------------------*/
function meta:Think( )

	// update speeds
	self:SetSpeeds();
	
	// check for player
	if ( !self:IsSpectating() ) then
	
		// check alive
		if ( self:Alive() ) then
		
			// get phys
			local phys = self:GetPhysicsObject();
			
			// validate
			if ( ValidEntity( phys ) ) then
			
				// are we stuck?
				if ( phys:IsPenetrating() && self:GetCollisionGroup() != COLLISION_GROUP_DEBRIS_TRIGGER ) then
			
					// help em get unstuck
					self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
					
				// not stuck
				elseif ( self:GetCollisionGroup() != COLLISION_GROUP_PLAYER ) then
				
					// make em solid
					self:SetCollisionGroup( COLLISION_GROUP_PLAYER );
				
				end
				
			end
			
			// get weapon
			local weap = self:GetActiveWeapon();
			
			// update for client
			self:SetNWEntity( "ActiveWeapon", weap );
			
			// validate
			if ( ValidEntity( weap ) ) then
		
				// attacking is disabled
				if ( !self:GetCanAttack() || self:IsSprinting() ) then
				
					// set attack 1/2 second from now
					weap:SetNextPrimaryFire( CurTime() + 0.5 );
					weap:SetNextSecondaryFire( CurTime() + 0.5 );
					
				end
				
			end
			
			// poisoned?
			if ( self:GetPoisonTime() > CurTime() ) then
			
				// time to hurt?
				if ( CurTime() > ( self.NextPoisonTime or 0 ) ) then
				
					// calculate new health
					local health = self:Health() - 1;
					
					// did we die?
					if ( health <= 0 ) then
					
						// DEAD!
						self:Kill();
						
					else
					
						// update
						self:SetHealth( health );
					
					end
					
					// delay
					self.NextPoisonTime = CurTime() + 1;
				
				end
			
			end
			
			// check for active round
			if ( GAMEMODE:GetRoundState() == ROUND_ACTIVE ) then
			
				// zombie sound event think
				GAMEMODE:PlayerSoundEventThink( self, SET_ZOMBIES );
				
			end
		
		end
	
	end

end


/*------------------------------------
	SetSpeeds
------------------------------------*/
function meta:SetSpeeds( )

	// check for spectator
	if ( self:IsSpectating() ) then
	
		// bird speeds
		GAMEMODE:SetPlayerSpeed( self, 30, 80 );
		return;
		
	end
	
	// defaults
	local walk, run, crouch = 0, 0, 0.5;
	
	// check holding
	if ( self:IsHolding() ) then
		
		// pretty slow
		walk, run, crouch = 100, 100, 0;
	
	elseif ( self:GetViewMode() == VIEWMODE_TOPDOWN ) then
	
		// normal
		walk, run = 180, 250;
		
	else
	
		// slower
		walk, run = 100, 160;
	
	end
	
	// frozen?
	if ( self:GetFrozenTime() > CurTime() ) then
	
		// slow the fuck down
		walk = 70;
		run = 70;
		crouch = 0;
	
	end
	
	// set speeds
	self:SetCrouchedWalkSpeed( crouch );
	GAMEMODE:SetPlayerSpeed( self, walk, run );

end


/*------------------------------------
	HoldEntity
------------------------------------*/
function meta:HoldEntity( ent )

	// validate
	if ( !ValidEntity( ent ) ) then
	
		// nope
		return;
		
	end
	
	// get entity to bind to
	local bind = ( self.Avatar && ValidEntity( self.Avatar.Avatar ) ) && self.Avatar.Avatar || self;
	
	// own it and hold it
	ent:SetParent( bind );
	
	// save it
	self:SetHeldEntity( ent );
	
	// stop attacking
	self:SetCanAttack( false );
	
	// damage counts
	self.HitsWhileHolding = 0;
	
	// get weapon
	local weap = self:GetActiveWeapon();

	// valid weapon
	if ( ValidEntity( weap ) ) then
	
		// dont draw
		weap:SetNoDraw( true );
		
		// held weapon
		self.HeldEntitySelectedWeapon = weap:GetClass();
		
	else
	
		// no weapon
		self.HeldEntitySelectedWeapon = nil;
		
	end
	
end


/*------------------------------------
	DropEntity
------------------------------------*/
function meta:DropEntity( )

	// grab entity
	local ent = self:GetHeldEntity();
	
	// validate
	if ( ValidEntity( ent ) ) then
	
		// own itself
		ent:SetParent( ent );

		// get position & angle
		local pos = self:GetPos();
		local ang = self:GetAngles();
		
		// move up and out
		pos = pos + ang:Right() * 18;
		pos = pos + ang:Forward() * 5;
		pos = pos + ang:Up() * 30;
		
		// rotate
		ang:RotateAroundAxis( ang:Up(), 90 );
		
		// update position
		ent:SetPos( pos );
		ent:SetAngles( ang );
		
		// think now
		ent:NextThink( CurTime() );
		
	end
	
	// clear held entity
	self:SetHeldEntity( NULL );
	
	// enable attack
	self:SetCanAttack( true );
	
	// get weapon
	local weap = self:GetActiveWeapon();

	// validate
	if ( ValidEntity( weap ) ) then
	
		// draw again
		weap:SetNoDraw( false );
		
	end
	
end


/*------------------------------------
	SetWingSound
------------------------------------*/
function meta:SetWingSound( bool )

	// verify sound
	if ( !self.WingSound ) then
	
		// create sound
		self.WingSound = CreateSound( self, "NPC_Crow.Flap" );
	
	end
	
	// needs to be on, but is stopped
	if ( bool && !self.WingSoundOn ) then
	
		// play sound & flag
		self.WingSound:Play();
		self.WingSoundOn = true;
		
	// needs to be off, but is playing
	elseif ( !bool && self.WingSoundOn ) then
	
		// stop sound & flag
		self.WingSound:Stop();
		self.WingSoundOn = false;
	
	end

end


/*------------------------------------
	PlaySquawk
------------------------------------*/
function meta:PlaySquawk( )

	// sound table
	local sounds = {
		"alert2", "alert3",
		"pain1", "pain2"
	};
		
	// delay squawk
	if ( CurTime() - ( self.LastSquawk or 0 ) > math.random( 1, 2 ) ) then
	
		// flag time
		self.LastSquawk = CurTime();
		
		// get a random sound
		local sound = Sound( ("npc/crow/%s.wav"):format( sounds[ math.random( 1, #sounds ) ] ) );
		
		// play the sound
		self:EmitSound( sound, math.random( 95, 125 ), math.random( 95, 105 ) );
	
	end

end


/*------------------------------------
	AmmoUp
------------------------------------*/
function meta:AmmoUp( )

	// too soon?
	if ( CurTime() > ( self.NextAmmoUp or 0 ) ) then
	
		// set next delay
		self.NextAmmoUp = CurTime() + 2;
		
		// get list of weapons
		local weaps = self:GetWeapons();
		
		// cycle weapons
		for _, weap in pairs( weaps ) do
		
			// check for function
			if ( weap.AmmoUp ) then
			
				// call
				weap:AmmoUp();
			
			end
		
		end
		
		// noises
		self:EmitSound( Sound( "items/ammo_pickup.wav" ), 160, 100 );
		
		// this was a triumph!
		return true;
		
	end
	
	// flail!
	return false;
	
end
