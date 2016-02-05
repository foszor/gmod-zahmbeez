
// convars
local PlayerLimit = CreateConVar( "sv_zahmbeez_playerlimit", "8", { FCVAR_ARCHIVE, FCVAR_NOTIFY } );

// queue list
GM.SpawnQueue = {};


/*------------------------------------
	UpdateQueue
------------------------------------*/
function GM:UpdateQueue( )

	// newly cleaned queue
	local cleaned = {};
	
	// loop queue
	for _, pl in pairs( self.SpawnQueue ) do
	
		// validate
		if ( ValidEntity( pl ) && pl:IsPlayer() && pl:IsSpectating() ) then
		
			// store
			cleaned[ #cleaned + 1 ] = pl;
			
			// update position
			pl:SetNWInt( "QueuePosition", #cleaned );
		
		end
	
	end
	
	// store
	self.SpawnQueue = cleaned;

end


/*------------------------------------
	AddToQueue
------------------------------------*/
function GM:AddToQueue( pl )

	// force and update
	self:UpdateQueue();
	
	// loop queue
	for _, qpl in pairs( self.SpawnQueue ) do
	
		// check for dupe
		if ( qpl == pl ) then
		
			return;
			
		end
	
	end
	
	// add to table
	self.SpawnQueue[ #self.SpawnQueue + 1 ] = pl;

end


/*------------------------------------
	SpawnFromQueue
------------------------------------*/
function GM:SpawnFromQueue( )

	// force and update
	self:UpdateQueue();
	
	// get max players
	local max = PlayerLimit:GetInt();
	
	// get current players
	local current = #self:ActivePlayers();
	
	// calculate how many to spawn
	local tospawn = max - current;
	
	// loop queue
	for _, pl in pairs( self.SpawnQueue ) do
	
		// are we done?
		if ( tospawn <= 0 ) then
			
			// done!
			break;
			
		end
		
		// no civilians
		if ( pl:GetGameClass() != CLASS_CIVILIAN ) then
		
			// get current spectating state
			local oldspec = pl:IsSpectating();
			
			// stop spectating
			pl:SetSpectate( false );
			
			// store time
			pl.Unqueued = CurTime();
			
			// alive people
			if ( pl:Alive() ) then
				
				// they werent spectating
				if ( !oldspec ) then
				
					// kill them so they respawn
					pl.SilentDeath = true;
					pl:Kill();
				
				// specatating...
				else
				
					// respawn
					self:DoPlayerRespawn( pl );
				
				end
				
			end
			
			// reduce
			tospawn = tospawn - 1;
			
		end
	
	end

end


/*------------------------------------
	ActivePlayers
------------------------------------*/
function GM:ActivePlayers( alive )

	// empty table
	local active = {};
	
	// get all players
	local players = player.GetAll();
	
	// cycle players
	for _, pl in pairs( players ) do
	
		// check if they're active
		if ( ValidEntity( pl ) && !pl:IsSpectating() && pl:GetGameClass() != CLASS_CIVILIAN ) then
		
			// alive?
			if ( !alive || pl:Alive() ) then
		
				// add to table
				active[ #active + 1 ] = pl;
				
			end
		
		end
	
	end
	
	// return results
	return active;

end


/*------------------------------------
	QueueAll
------------------------------------*/
function GM:QueueAll( )

	// players to queue
	local queue = {};

	// get all players
	local players = player.GetAll();
	
	// cycle players
	for _, pl in pairs( players ) do
	
		// check if they're active
		if ( ValidEntity( pl ) && pl:IsPlayer() && !pl:IsSpectating() ) then
		
			// spectate
			pl:SetSpectate( true );
			
			// alive people
			if ( pl:Alive() ) then
				
				pl.SilentDeath = true;
				pl:Kill();
				
			end
			
			// save
			queue[ #queue + 1 ] = {
			
				Player = pl,
				QTime = pl.Unqueued or 0
				
			};
		
		end
	
	end
	
	// sort!
	table.sort( queue, function( a, b ) return a.QTime < b.QTime end );
	
	// cycle queue table
	for _, q in pairs( queue ) do
	
		// add to queue
		self:AddToQueue( q.Player );
	
	end
	
end


/*------------------------------------
	QueueQuotaMet
------------------------------------*/
function GM:QueueQuotaMet( )
	
	// get max players
	local max = PlayerLimit:GetInt();
	
	// get current players
	local current = #self:ActivePlayers();
	
	// eval
	return !( current < max );
	
end


/*------------------------------------
	QueueThink
------------------------------------*/
function GM:QueueThink( )

	// check timing
	if ( CurTime() > ( self.NextQueueThink or 0 ) ) then
	
		// delay
		self.NextQueueThink = CurTime() + 0.5;
		
		// good time?
		if ( self:ShouldPlayersSpawn() ) then
		
			// spawn!
			self:SpawnFromQueue();
			
		end
	
	end

end
