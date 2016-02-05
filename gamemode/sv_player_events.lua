
/*------------------------------------
	PlayerInitialSpawn
------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	// base class
	self.BaseClass:PlayerInitialSpawn( pl );
	
	// starting view
	pl:SetViewMode( VIEWMODE_TOPDOWN, true );
	
	// start as spectator
	pl:SetSpectate( true );
	
	// add to queue
	self:AddToQueue( pl );
	
end


/*------------------------------------
	PlayerInitialSetup
------------------------------------*/
function GM:PlayerInitialSetup( pl )

	// create aim controller
	local ac = ents.Create( "aim_controller" );
	ac:Spawn();
	ac:SetPlayer( pl );
	
	// create view controller
	local vc = ents.Create( "view_controller" );
	vc:Spawn();
	vc:SetPlayer( pl );

	// send fading brushes
	timer.Simple( 5, function()
	
		// start message
		umsg.Start( "ZahmbeezFadeBrushes", pl );
		
			// add count
			umsg.Short( #self.FadeBrushes );
			
			// loop brushes
			for _, ent in pairs( self.FadeBrushes ) do
			
				// add
				umsg.Entity( ent );
			
			end
			
		umsg.End();
	
	end );
	
	// defaults
	pl.AlertedTime = pl.AlertedTime or 0;
	
	// send round info
	self:UpdateRoundState( pl );
	
	// flag complete
	pl.SetupDone = true;
		
end


/*------------------------------------
	DoPlayerRespawn
------------------------------------*/
function GM:DoPlayerRespawn( pl )

	// blargh
	pl:Spawn();
	
	
end


/*------------------------------------
	PlayerSpawn
------------------------------------*/
function GM:PlayerSpawn( pl )

	// base class
	self.BaseClass:PlayerSpawn( pl );
	
	// check if sent
	if ( !pl.SetupDone ) then
	
		// call event
		self:PlayerInitialSetup( pl );
	
	end
	
	// check for spectator
	if ( pl:IsSpectating() ) then
	
		// call event
		self:SpectatorSpawn( pl );
		return;
		
	end
	
	// give flashlight
//	local flashlight = ents.Create( "zahmbeez_flashlight" );
//	flashlight:Spawn();
//	flashlight:SetPlayer( pl );
	
	// create avatar
	local avatar = ents.Create( "zahmbeez_avatar" );
	avatar:Spawn();
	avatar:SetPlayer( pl );
	
	// setup
	pl:SetViewMode( VIEWMODE_TOPDOWN, true );
	pl:SetCanAttack( true );
	pl:ShouldDropWeapon( false );
	pl:SetRadarType( RADAR_FRIENDLY );
	pl:SetPoisonTime( 0 );
	pl:SetFrozenTime( 0 );
	pl:Extinguish();
	pl.NextSoundEvent = {};
	pl.NextSoundEventThink = {};
	pl.NextSoundEventData = {};
	
end


/*------------------------------------
	SpectatorSpawn
------------------------------------*/
function GM:SpectatorSpawn( pl )

	// setup crow
	pl:SetHealth( 5 );
	pl:SetFOV( 120 );
	pl:SetNoTarget( true );
	pl:SetSolid( SOLID_VPHYSICS );
	pl:SetMoveType( MOVETYPE_WALK );
	pl:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	pl:SetRadarType( RADAR_NONE );

end


/*------------------------------------
	PlayerSelectSpawn
------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	// check for zahmode override
	local spawn = ZCallHook( "OnPlayerSelectSpawn", pl );
	
	// validate spawn point
	if ( ValidEntity( spawn ) ) then
		
		// trigger
		spawn:TriggerOutput( "OnSpawn", spawn );
		
		// let the zahmode override
		return spawn;
		
	end
	
	// find player starts
	local spawns = ents.FindByClass( "info_player_start" );
	
	// return random
	return spawns[ math.random( 1, #spawns ) ];

end


/*------------------------------------
	PlayerSetModel
------------------------------------*/
function GM:PlayerSetModel( pl )

	// check for spectator
	if ( pl:IsSpectating() ) then
	
		// call event
		self:SpectatorSetModel( pl );
		return;
		
	end
	
	// default model
	local model = Model( self:ClassModel( pl ) );
	
	// set it
	pl:SetModel( model );
	
	// check avatar
	if ( ValidEntity( pl.Avatar ) ) then
	
		// update model
		pl.Avatar:SetModel( model );
		
	end
	
end


/*------------------------------------
	SpectatorSetModel
------------------------------------*/
function GM:SpectatorSetModel( pl )
	
	// crow model
	local model = Model( "models/Crow.mdl" );
	
	// set it
	pl:SetModel( model );
	
	// settings
	pl:SetRenderMode( RENDERMODE_NORMAL );
	pl:SetColor( 255, 255, 255, 255 );
	pl:SetNoDraw( false );
	pl:SetMaterial( "" );
	
end


/*------------------------------------
	PlayerLoadout
------------------------------------*/
function GM:PlayerLoadout( pl )

	// check for spectator
	if ( pl:IsSpectating() ) then
	
		return;
		
	end
	
	// class based
	self:ClassLoadout( pl );
	
end


/*------------------------------------
	PlayerShouldTakeDamage
------------------------------------*/
function GM:PlayerShouldTakeDamage( victim, attacker )

	// check for spectator
	if ( victim:IsSpectating() ) then
	
		// always hurt
		return true;
		
	end
	
	// check for player damage
	if ( ValidEntity( attacker ) && attacker:IsPlayer() ) then
	
		// nope
		return false;
	
	end
	
	// check for carrier
	if ( victim:IsHolding() ) then
		
		// increment hit count
		victim.HitsWhileHolding = ( victim.HitsWhileHolding or 0 ) + 1;
				
		// max?
		if ( victim.HitsWhileHolding >= 2 ) then
				
			// drop
			victim:DropEntity();
		
		end
	
	end
	
	// yup
	return true;

end


/*------------------------------------
	PlayerDeath
------------------------------------*/
function GM:PlayerDeath( victim, weapon, killer )

	// silent death
	if ( victim.SilentDeath || victim:IsSpectating() ) then
	
		// reset
		victim.SilentDeath = nil;
		
		// dont notify
		return;
		
	end
	
	// play event
	self:PlayerSoundEvent( victim, SE_DIED );
	
	// spectate
	victim:SetSpectate( true );
	
	// add to queue
	self:AddToQueue( victim );

	// base class
	self.BaseClass:PlayerDeath( victim, weapon, killer );
	
end


/*------------------------------------
	DoPlayerDeath
------------------------------------*/
function GM:DoPlayerDeath( pl, attacker, dmginfo )
	
	// set last death time
	pl.LastDeath = CurTime();
	
	// check flashlight
	if ( ValidEntity( pl.FlashLight ) ) then
	
		// remove flashlight
		pl.FlashLight:Remove();
	
	end
	
	// check avatar
	if ( ValidEntity( pl.Avatar ) ) then
	
		// remove flashlight
		pl.Avatar:Remove();
	
	end
	
	// create ragdoll
	pl:CreateRagdoll();
	
end


/*------------------------------------
	PlayerDeathThink
------------------------------------*/
function GM:PlayerDeathThink( pl )

	// havent been dead long enough
	if ( CurTime() - pl.LastDeath < 3.3 ) then
	
		// skip
		return;
		
	end
	
	// respawn
	pl:Spawn();

end


/*------------------------------------
	PlayerDeathSound
------------------------------------*/
function GM:PlayerDeathSound( )

	// override
	return true;
	
end
