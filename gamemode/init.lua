
// manifest
include( 'manifest.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function GM:Initialize( )

	// base class
	self.BaseClass:Initialize();
	
end


/*------------------------------------
	InitPostEntity
------------------------------------*/
function GM:InitPostEntity( )

	// base class
	self.BaseClass:InitPostEntity();
	
	// randomize shit
	math.randomseed( os.time() * SysTime() );
	
	// storage table
	self.FadeBrushes = {};

	// find func_brushes
	local brushes = ents.FindByClass( "func_brush" ) or {};
	
	// loop list
	for _ , brush in pairs( brushes ) do
	
		// find fadebrushes
		if ( brush:GetName() == "zahmbeez_fadebrush" ) then
		
			// store for clients
			self.FadeBrushes[ #self.FadeBrushes + 1 ] = brush;
			
		end
		
	end
	
	// lower ragdolls!
	game.ConsoleCommand( "g_ragdoll_maxcount 10\n" );
	
	// setup zahmode files
	self:PreloadZahmodes();
	
	// start it
	self:StartZahmode( self.CurrentZahmode or "laststand" );
	
end


/*------------------------------------
	Think
------------------------------------*/
function GM:Think( )

	// round thinkage
	self:RoundThink();
	
	// queue thinkage
	self:QueueThink();
	
	// get all players
	local players = player.GetAll();
	
	// cycle players
	for _, pl in pairs( players ) do
	
		// validate
		if ( ValidEntity( pl ) && pl:IsPlayer() ) then
		
			// think
			pl:Think();
		
		end
	
	end
	
end


/*------------------------------------
	OnNPCKilled
------------------------------------*/
function GM:OnNPCKilled( npc, killer, weapon )

	// call event
	hook.Call( "OnNPCKilled", GAMEMODE.CurrentZahmodeTable or {}, npc, killer, weapon );
	
	// check if killed by player
	if ( ValidEntity( killer ) && killer:IsPlayer() && killer:Alive() ) then
	
		// check for active round
		if ( self:GetRoundState() == ROUND_ACTIVE ) then
		
			// call event
			self:PlayerSoundEvent( killer, SE_KILLEDZOMBIE );
			
		end
	
	end
	
end


/*------------------------------------
	SendMotionText
------------------------------------*/
function GM:SendMotionText( text, pl )

	// send some text
	umsg.Start( "ZahmbeezMotionText", pl );
	
		// add the text
		umsg.String( text or "" );
		
	// send
	umsg.End();
		
end


/*------------------------------------
	EntityTakeDamage
------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	// call event
	hook.Call( "EntityTakeDamage", GAMEMODE.CurrentZahmodeTable or {}, ent, inflictor, attacker, amount, dmginfo );
	
	// check player
	if ( ent:IsPlayer() && ent:Alive() && ( ent:Health() - amount > 0 ) ) then
	
		// figure out event
		local event = ( amount > 10 ) && SE_PAIN_STRONG || SE_PAIN_WEAK;
		
		// call event
		self:PlayerSoundEvent( ent, event );
	
	end

end
