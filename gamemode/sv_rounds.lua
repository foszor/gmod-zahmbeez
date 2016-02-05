
// convars
local WaitTime = CreateConVar( "sv_zahmbeez_waittime", "15", FCVAR_ARCHIVE | FCVAR_NOTIFY );
local IntroTime = CreateConVar( "sv_zahmbeez_introtime", "5", FCVAR_ARCHIVE | FCVAR_NOTIFY );
local RoundTime = CreateConVar( "sv_zahmbeez_roundtime", "480", FCVAR_ARCHIVE | FCVAR_NOTIFY );
local OutroTime = CreateConVar( "sv_zahmbeez_outrotime", "5", FCVAR_ARCHIVE | FCVAR_NOTIFY );
local DisableZombies = CreateConVar( "sv_zahmbeez_disable_zahmode", "0", FCVAR_ARCHIVE | FCVAR_NOTIFY );

// round information storage
GM.RoundState = ROUND_WAITING;
GM.RoundStateTimeout = 0;


/*------------------------------------
	PreloadZahmodes
------------------------------------*/
function GM:PreloadZahmodes( )

	// base path
	local base = "zahmbeez/gamemode/zahmodes/";
	
	// ignored folders
	local ignored = { '.', '..', '.svn' };
	
	// load all objective folders
	local dirlist = file.FindInLua( ("%s*"):format( base ) );
	for _, dirname in pairs( dirlist ) do
	
		// build string
		local path = ("%s%s/"):format( base, dirname );
	
		// valid directory?
		if ( !table.HasValue( ignored, dirname ) ) then
		
			// gather list of files
			local files = file.FindInLua( ("%s*.lua"):format( path ) );
	
			// shared.lua
			if ( table.HasValue( files, "shared.lua" ) ) then
			
				// build file
				local f = ("%sshared.lua"):format( path );
			
				// send to client
				AddCSLuaFile( f );
				
			end
			
			// cl_init.lua
			if ( table.HasValue( files, "cl_init.lua" ) ) then
			
				// build file
				local f = ("%scl_init.lua"):format( path );
			
				// send to client
				AddCSLuaFile( f );
			
			end
			
		end
	
	end

end


/*------------------------------------
	RoundThink
------------------------------------*/
function GM:RoundThink( )

	// get all players
	local players = player.GetAll();
	
	// check for no players
	if ( #players == 0 ) then
	
		// reset round if needed
		if ( self.RoundState != ROUND_WAITING ) then
		
			// cleanup
			ZCallHook( "OnRoundCleanup" );
		
		end
		
		// set waiting state
		self:SetRoundState( ROUND_WAITING, nil, true );
	
	end
	
	// done waiting for players, intro
	if ( self.RoundState == ROUND_WAITING && CurTime() >= self.RoundStateTimeout ) then
	
		// set new state
		self:SetRoundState( ROUND_INTRO );
		
		// call reset event
		ZCallHook( "OnResetRound" );
			
	// intro done, round active
	elseif ( self.RoundState == ROUND_INTRO && CurTime() >= self.RoundStateTimeout ) then
	
		// set new state
		self:SetRoundState( ROUND_ACTIVE );
		
	// round over, outro
	elseif ( self.RoundState == ROUND_ACTIVE && CurTime() >= self.RoundStateTimeout ) then
	
		// set new state
		self:SetRoundState( ROUND_OUTRO );
		
	// outro over, wait for players
	elseif ( self.RoundState == ROUND_OUTRO && CurTime() >= self.RoundStateTimeout ) then
	
		// set new state
		self:SetRoundState( ROUND_WAITING );
		
		// cleanup
		ZCallHook( "OnRoundCleanup" );
		
	end
	
	if ( DisableZombies:GetInt() == 0 ) then
	
		// let ze zahmode think!
		hook.Call( "Think", GAMEMODE.CurrentZahmodeTable or {} );
		
	end
	
end


/*------------------------------------
	GetRoundState
------------------------------------*/
function GM:GetRoundState( )

	return self.RoundState;

end

/*------------------------------------
	SetRoundState
------------------------------------*/
function GM:SetRoundState( state, timeout, local_only )

	// call events
	if ( state == ROUND_WAITING ) then
	
		timeout = timeout or WaitTime:GetInt();
		ZCallHook( "OnRoundWait" );
		
		self:SendMotionText( "Waiting!" );
		
	elseif ( state == ROUND_INTRO ) then
	
		timeout = timeout or IntroTime:GetInt();
		ZCallHook( "OnRoundIntro" );
		
		self:SendMotionText( "Get Ready!" );
		
	elseif ( state == ROUND_ACTIVE ) then
	
		timeout = timeout or RoundTime:GetInt();
		ZCallHook( "OnRoundStart" );
		
		self:SendMotionText( "Fight!" );
		
	elseif ( state == ROUND_OUTRO ) then
	
		timeout = timeout or OutroTime:GetInt();
		ZCallHook( "OnRoundOutro" );
		
		self:SendMotionText( "Round Over!" );
	
	end

	// store information
	self.RoundState = state;
	self.RoundStateTimeout = CurTime() + timeout;
	
	// check local
	if ( !local_only ) then
	
		// update for clients
		self:UpdateRoundState();
		
	end
	
end


/*------------------------------------
	UpdateRoundState
------------------------------------*/
function GM:UpdateRoundState( pl )
	
	// send the umsg
	umsg.Start( "ZahmbeezRoundInfo", pl );
		umsg.String( self.CurrentZahmode );
		umsg.Long( self.RoundState );
		umsg.Long( self.RoundStateTimeout );
	umsg.End();

end


/*------------------------------------
	ShouldPlayersSpawn
------------------------------------*/
function GM:ShouldPlayersSpawn( )

	// check round state
	if ( self.RoundState == ROUND_INTRO || self.RoundState == ROUND_ACTIVE ) then
	
		return true;
	
	end
	
	return false;
	
end


/*------------------------------------
	OnResetRound
------------------------------------*/
function GM:OnResetRound( )

	// get all entities
	local entlist = ents.GetAll();
	
	// loop entities
	for _, ent in pairs( entlist ) do
	
		// validate
		if ( ValidEntity( ent ) ) then
		
			// check for restart function
			if ( ent.OnRoundRestart ) then
			
				// call it
				ent:OnRoundRestart();
			
			end
		
		end
	
	end
	
end


/*------------------------------------
	OnCleanupRound
------------------------------------*/
function GM:OnRoundCleanup( )

	// zombie classes
	local classes = {
	
		"npc_zombie",
		"npc_zombie_torso",
		"npc_fastzombie",
		"npc_fastzombie_torso",
		"npc_headcrab",
		"npc_headcrab_black",
		"npc_headcrab_fast",
		"npc_poisonzombie"
	
	};
	
	// find 'em all
	local npcs = ents.FindByClass( "npc_*" );
	
	// loop npcs
	for _, npc in pairs( npcs ) do
	
		// validate
		if ( ValidEntity( npc ) && npc:IsNPC() ) then
		
			// classname
			local class = npc:GetClass();
			
			// should we delete?
			if ( table.HasValue( classes, class ) ) then
			
				// kill
				npc:Fire( "break", 0 );
			
			end
		
		end
	
	end
	
	// force everyone to spectator
	self:QueueAll();

end


/*------------------------------------
	OnRoundIntro
------------------------------------*/
function GM:OnRoundIntro( )

	// small delay
	timer.Simple( 2, function()
	
		// call event
		self:GlobalSoundEvent( SE_MOVEOUT, 0.6 );
		
	end );

end


/*------------------------------------
	OnRoundStart
------------------------------------*/
function GM:OnRoundStart( )

end
