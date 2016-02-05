
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
	
	// setup
	self.NextSpawn = CurTime() + 10;
	
end


/*------------------------------------
	SpawnZombie
------------------------------------*/
function ENT:SpawnZombie( yaw )

	// get position & angles
	local pos = self:GetPos();
	local ang = self:GetAngles();
	
	// build direction
	local dir = Angle( 0, yaw, 0 ):Forward();
	
	// calculate position
	pos = pos + ( dir * 48 );

	// start effect
	local effectdata = EffectData();
	
	// setup effect
	effectdata:SetOrigin( pos );
	effectdata:SetNormal( Vector( 0, 0, 1 ) );
	
	// dispatch
	util.Effect( "pillaroflight", effectdata, true, true );
	
	// delay spawn
	timer.Simple( 1, function()
	
		// round over?
		if ( GAMEMODE:GetRoundState() != ROUND_ACTIVE ) then
		
			// *cry*
			return;
		
		end
	
		// random class
		local class = ( math.random( 1, 100 ) <= 80 ) && "npc_zombie" || "npc_fastzombie";
	
		// create zombie
		local npc = ents.Create( class );
		
		// set position & angles
		npc:SetPos( pos );
		npc:SetAngles( ang );
		
		// setup
		npc:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY );
		npc:SetKeyValue( "spawnflags", "1280" );
	//	npc:SetKeyValue( "squadname", "zombie" );
		
		// bam!
		npc:Spawn();
		
		// call event
		ZCallHook( "OnZombieSpawned", npc );
		
		// validate ourself
		if ( ValidEntity( self ) ) then
		
			// output
			self:TriggerOutput( "OnSpawn", self );
			
		end
		
	end );
	
end


/*------------------------------------
	SpawnZombies
------------------------------------*/
function ENT:SpawnZombies( count )

	// starting yaw
	local yaw = math.random( -180, 180 );
	
	// do count
	for i = 1, count do
	
		// spawn
		self:SpawnZombie( yaw );
		
		// rotate
		yaw = yaw + 90;
	
	end

end
