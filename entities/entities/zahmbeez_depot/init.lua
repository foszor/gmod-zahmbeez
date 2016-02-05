
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

// accessors
AccessorFunc( ENT, "isopen", "Open", FORCE_BOOL );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// base class
	self.BaseClass.Initialize( self );
	
	// radar
	self.Entity:SetRadarType( RADAR_OBJECTIVE );
	
	// defaults
	self:SetOpen( false );
	self.NextLockSound = 0;
	
end


/*------------------------------------
	OnRoundRestart
------------------------------------*/
function ENT:OnRoundRestart( )
	
	// generator hasnt been located yet
	if ( self.KeyValues[ 'generator' ] && !self.Generator ) then

		// find by name
		local gen = ents.FindByName( self.KeyValues[ 'generator' ] )[ 1 ];
		
		// validate
		if ( gen && ValidEntity( gen ) && gen:GetClass() == "zahmbeez_generator" ) then
		
			// save
			self.Generator = gen; 
		
		end
		
	end
	
	// think now
	self.Entity:NextThink( CurTime() );
	
end


/*------------------------------------
	DoOpen
------------------------------------*/
function ENT:DoOpen( )

	// lookup sequence
	local seq = self:LookupSequence( "Open" );
	
	// play it
	self:SetPlaybackRate( 1.0 );
	self:ResetSequence( seq );
	self:SetCycle( 1 );
	self:SetOpen( true );
	
	// sound
	self:EmitSound( self.OpenSound, 140, 100 );
	
end


/*------------------------------------
	DoClose
------------------------------------*/
function ENT:DoClose( )

	// lookup sequence
	local seq = self:LookupSequence( "Close" );
	
	// play it
	self:SetPlaybackRate( 1.0 );
	self:ResetSequence( seq );
	self:SetCycle( 1 );
	self:SetOpen( false );
	
	// sound
	self:EmitSound( self.CloseSound, 140, 100 );
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// default to no one
	local found = false;

	// only check if we're lit up	
	if ( self:HasLight() ) then
	
		// get list of players
		local players = player.GetAll();
		
		// loop thru list
		for _, pl in pairs ( players ) do
		
			// validate player
			if ( ValidEntity( pl ) && pl:IsPlayer() && !pl:IsSpectating() ) then
			
				// check distance
				if ( pl:GetPos():Distance( self.Entity:GetPos() ) < 70 ) then
				
					// yup! they are close enough
					found = true;
					break;
				
				end
			
			end
			
		end
		
	end
	
	// close player, not open
	if ( found && !self:GetOpen() ) then
	
		// open it
		self:DoOpen();
		
	// no players, still open
	elseif ( !found && self:GetOpen() ) then
	
		// close it
		self:DoClose();
		
	end
	
	// think fast
	self.Entity:NextThink( CurTime() + 1 );
	return true;
	
end


/*------------------------------------
	HasLight
------------------------------------*/
function ENT:HasLight( )

	// validate first
	if ( !ValidEntity( self.Generator ) ) then
	
		// doesnt have light
		return false;
		
	end
	
	// let um know
	return ( self.Generator:GetOn() );

end


/*------------------------------------
	Touch
------------------------------------*/
function ENT:Touch( ent )

	// disabled?
	if ( !self:HasLight() ) then
	
		// not too soon?
		if ( CurTime() > self.NextLockSound ) then
		
			// delay
			self.NextLockSound = CurTime() + math.random( 2, 4 );
		
			// sound
			self:EmitSound( self.LockedSound, 140, 100 );
			
		end
			
		// sucker.
		return;
	
	end
	
	// validate entity
	if ( !ValidEntity( ent ) || !ent:IsPlayer() || ent:IsSpectating() ) then
	
		// nooo
		return;
		
	end
	
	// AMMO! YAY!
	ent:AmmoUp();

end
