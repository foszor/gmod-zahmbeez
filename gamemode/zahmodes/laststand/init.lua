
/*------------------------------------
	Initialize
------------------------------------*/
function ZMODE:Initialize( )

	self.MaxZombies = 15;
	
	// damage values
	game.ConsoleCommand( "sk_fastzombie_dmg_slash 10\n" );
	game.ConsoleCommand( "sk_zombie_dmg_one_slash 13\n" );
	game.ConsoleCommand( "sk_zombie_dmg_both_slash 24\n" );

end


/*------------------------------------
	AllowZombieSpawn
------------------------------------*/
function ZMODE:AllowZombieSpawn( )

	// not an active state	
	if ( GAMEMODE:GetRoundState() != ROUND_ACTIVE ) then
	
		// nope
		return false;
	
	// not time yet
	elseif ( CurTime() < self.NextZombieSpawn ) then
	
		// nope
		return false;
		
	elseif ( self.SpawnedZombieCount > self.MaxZombies ) then
	
		// delay again
		self.NextZombieSpawn = CurTime() + 8;
	
		// too many
		return false;
		
	end
	
	// go for it Charley
	return true;

end


/*------------------------------------
	GetActiveSpawns
------------------------------------*/
function ZMODE:GetActiveSpawns( )

	// empty list
	local spawnlist = {};
	
	// find player starts
	local spawns = ents.FindByClass( "zahmbeez_spawnpoint" );
	
	// cycle spawns
	for _, spawn in pairs( spawns ) do
	
		// validate
		if ( ValidEntity( spawn ) /*&& spawn:CanSpawn()*/ ) then
		
			// add to list
			spawnlist[ #spawnlist + 1 ] = spawn;
		
		end
	
	end
	
	// results
	return spawnlist;
	
end


/*------------------------------------
	GetZombieEnemy
------------------------------------*/
function ZMODE:GetZombieEnemy( npc )

	// attack citizen
	if ( !ValidEntity( self.Citizen ) || math.random( 1, 3 ) == 1 ) then
	
		// get alive players
		local players = GAMEMODE:ActivePlayers( true );
		
		// make sure we found SOMEONE
		if ( #players == 0 ) then
		
			return;
			
		end
		
		// get a player
		return players[ math.random( 1, #players ) ];
	
	end
	
	// use citizen
	return self.Citizen;

end


/*------------------------------------
	DoSpawnZombie
------------------------------------*/
function ZMODE:DoSpawnZombies( )

	// check for spawns
	if ( !self.ZombieSpawns ) then
	
		// empty list
		local spawnlist = {};
		
		// find player starts
		local spawns = ents.FindByClass( "zahmbeez_zombie" );
		
		// cycle spawns
		for _, spawn in pairs( spawns ) do
		
			// validate
			if ( ValidEntity( spawn ) ) then
			
				// add to list
				spawnlist[ #spawnlist + 1 ] = spawn;
			
			end
		
		end
		
		// check results
		if ( #spawnlist > 0 ) then
		
			// save
			self.ZombieSpawns = spawnlist;
			
		end
		
	else
	
		// randomize
		local spawn = self.ZombieSpawns[ math.random( 1, #self.ZombieSpawns ) ];
		
		// get count
		local count = math.min( 4, self.MaxZombies - self.SpawnedZombieCount );
		
		// validate
		if ( ValidEntity( spawn ) ) then
		
			// spawn
			self.NextZombieSpawn = CurTime() + 5;
			spawn:SpawnZombies( count );
			self.SpawnedZombieCount = self.SpawnedZombieCount + count;
		
		end
	
	end
	
end


/*------------------------------------
	DoSpawnCitizen
------------------------------------*/
function ZMODE:DoSpawnCitizen( )

	// check for spawns
	if ( !self.CitizenSpawns ) then
	
		// empty list
		local spawnlist = {};
		
		// find player starts
		local spawns = ents.FindByClass( "zahmbeez_citizen" );
		
		// cycle spawns
		for _, spawn in pairs( spawns ) do
		
			// validate
			if ( ValidEntity( spawn ) ) then
			
				// add to list
				spawnlist[ #spawnlist + 1 ] = spawn;
			
			end
		
		end
		
		// check results
		if ( #spawnlist > 0 ) then
		
			// save
			self.CitizenSpawns = spawnlist;
			
		end
		
	end
	
	// validate
	if ( self.CitizenSpawns ) then
	
		// randomize
		local spawn = self.CitizenSpawns[ math.random( 1, #self.CitizenSpawns ) ];
		
		// validate
		if ( ValidEntity( spawn ) ) then
		
			// spawn
			local citizen = ents.Create( "zahmbeez_npc_citizen" );
			citizen:SetPos( spawn:GetPos() );
			citizen:SetAngles( spawn:GetAngles() );
			citizen:Spawn();
			citizen:SetName( citizen:GetClass() );
			citizen:SetRadarType( RADAR_FRIENDLY );
			
			// setup
			citizen:SetHealth( 100 );
			
			// save
			self.Citizen = citizen;
			SetGlobalEntity( "Citizen", self.Citizen );
		
		end
	
	end
	
end


/*------------------------------------
	Think
------------------------------------*/
function ZMODE:Think( )

	// check for zombie spawning
	if ( self:AllowZombieSpawn() ) then
	
		// start spawning
		self:DoSpawnZombies();
	
	end

end


/*------------------------------------
	OnPlayerSelectSpawn
------------------------------------*/
function ZMODE:OnPlayerSelectSpawn( pl )

	// check for spectator
	if ( pl:IsSpectating() ) then
	
		return nil;
		
	end
	
	// get spawns
	local spawns = self:GetActiveSpawns();
	
	// validate
	if ( #spawns == 0 ) then
	
		return nil;
		
	end
	
	// return random
	return spawns[ math.random( 1, #spawns ) ];
	

end


/*------------------------------------
	OnRoundIntro
------------------------------------*/
function ZMODE:OnRoundIntro( )

	// reset
	self.NextZombieSpawn = CurTime();
	self.SpawnedZombieCount = 0;
	
	// check for existing
	if ( ValidEntity( self.Citizen ) ) then
	
		// remove it
		self.Citizen:Remove();
	
	end
	
	// create citizen
	self:DoSpawnCitizen();
	
end


/*------------------------------------
	OnZombieSpawned
------------------------------------*/
function ZMODE:OnZombieSpawned( npc )

	// attack bitches!
	npc:AddRelationship( "npc_bullseye D_HT 99" );
	npc:AddRelationship( "zahmbeez_npc_citizen D_HT 91" );
	npc:AddRelationship( "player D_HT 90" );
	npc:SetHealth( 200 );
	
	// delay
	timer.Simple( 1, function()
	
		// check for active round
		if ( GAMEMODE:GetRoundState() != ROUND_ACTIVE ) then
		
			return;
		
		end
	
		// validate
		if ( !ValidEntity( npc ) ) then
		
			// died already?
			return;
			
		end
		
		// find our enemy
		local enemy = self:GetZombieEnemy( npc );
		
		// validate
		if ( !enemy || !ValidEntity( enemy ) ) then
		
			// :(
			return;
			
		end
		
		// randomly buff
		if ( npc:GetClass() == "npc_zombie" && math.random( 1, 3 ) == 1 ) then
		
			// get random buff type
			local bufftype = math.random( 1, 3 );
		
			// create buff entity
			local buff = ents.Create( "zahmbeez_zombuff" );
			buff:SetPos( npc:GetPos() );
			buff:SetParent( npc );
			buff:SetOwner( npc );
			buff:SetType( bufftype );
			buff:Spawn();
			
			// flag npc
			npc:SetBuffType( bufftype );
			
		end
		
		// MOVE OUT!
		npc:SetLastPosition( enemy:GetPos() );
		npc:SetTarget( enemy );
		npc:SetSchedule( SCHED_TARGET_CHASE );
		
	end );
	
	// flag
	npc.SpawnedZombie = true;

end


/*------------------------------------
	OnNPCKilled
------------------------------------*/
function ZMODE:OnNPCKilled( npc, killer, weapon )

	// check for flag
	if ( npc.SpawnedZombie ) then
	
		// reduce count
		self.SpawnedZombieCount = self.SpawnedZombieCount - 1;
	
	end

end


/*------------------------------------
	OnRoundCleanup
------------------------------------*/
function ZMODE:OnRoundCleanup( )

end


/*------------------------------------
	OnRoundOutro
------------------------------------*/
function ZMODE:OnRoundOutro( )
	
	// see if citizen is around
	if ( ValidEntity( self.Citizen ) && self.Citizen:Health() > 0 ) then
	
		// make um all stoopud
		self:FreezeZombies();
	
		// call event
		GAMEMODE:GlobalSoundEvent( SE_WIN, 0.3 );
		
	else
	
		// call event
		GAMEMODE:GlobalSoundEvent( SE_LOSE, 0.3 );
		
		// get players
		local players = GAMEMODE:ActivePlayers();
		
		// cycle players
		for _, pl in pairs( players ) do
		
			// stop them from attacking
			pl:SetCanAttack( false );
		
		end
	
	end
	
end


/*------------------------------------
	FreezeZombies
------------------------------------*/
function ZMODE:FreezeZombies( )
	
	// find 'em all
	local npcs = ents.FindByClass( "npc_*" );
	
	// loop npcs
	for _, npc in pairs( npcs ) do
	
		// validate
		if ( ValidEntity( npc ) && npc:IsNPC() ) then
		
			// classname
			local class = npc:GetClass();
			
			// should we stoopify?
			if ( table.HasValue( ZombieClasses, class ) ) then
			
				npc:SetSchedule( SCHED_STANDOFF );
				npc:SetNPCState( NPC_STATE_PLAYDEAD );
			
			end
		
		end
	
	end

end


/*------------------------------------
	EntityTakeDamage
------------------------------------*/
function ZMODE:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	// validate attacker
	if ( ValidEntity( attacker ) && attacker:IsNPC() ) then
	
		// get buff
		local bufftype = attacker:GetBuffType();
		
		// fire buff
		if ( bufftype == BUFF_FIRE ) then
		
			// burn baby burn!
			ent:Ignite( 1, 0 );
			ent:SetFrozenTime( 0 );
			
		// poison buff
		elseif ( bufftype == BUFF_POISON ) then
		
			// make em sick
			ent:SetPoisonTime( CurTime() + math.random( 12, 20 ) );
			
		// ice buff
		elseif ( bufftype == BUFF_ICE ) then
		
			// freeze em!
			ent:SetFrozenTime( CurTime() + math.random( 6, 10 ) );
			
		end
	
	end

end
