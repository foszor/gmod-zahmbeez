
// client files
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

// includes
include( "shared.lua" );

//---------- Info
SWEP.Weight				= 1;
SWEP.AutoSwitchTo		= false;
SWEP.AutoSwitchFrom		= false;


/*------------------------------------
	StoreBarricade
------------------------------------*/
function SWEP:StoreBarricade( ent )

	// refresh & count
	local count = self:RefreshBarricades();

	// check limit
	if ( count + 1 > self.MaxBarricades ) then
	
		// kill
		self.CurrentBarricades[ 1 ]:Fire( "Break", "", 0 );
	
	end
	
	// store
	self.CurrentBarricades[ #self.CurrentBarricades + 1 ] = ent;

end


/*------------------------------------
	RefreshBarricades
------------------------------------*/
function SWEP:RefreshBarricades( )

	// empty
	local new = {};
	
	// cycle barricades
	for _, ent in pairs( self.CurrentBarricades ) do
	
		// validate
		if ( ValidEntity( ent ) ) then
		
			// save
			new[ #new + 1 ] = ent;
		
		end
	
	end
	
	// update
	self.CurrentBarricades = new;
	
	// return count
	return #new;

end


/*------------------------------------
	ConstructGeneric
------------------------------------*/
function SWEP:ConstructGeneric( )

	// get function and args
	local func = self[ self.Barricades[ self.BarricadeIndex ][ 'Trace' ] ];
	local args = self.Barricades[ self.BarricadeIndex ][ 'TraceArgs' ];
	
	// get position and angles
	local pos, ang = func( self, unpack( args ) );
	
	// validate	
	if ( pos && ang ) then
		
		// create barricade & set model
		local barricade = ents.Create( "prop_physics_multiplayer" );
		barricade:SetModel( self.Barricades[ self.BarricadeIndex ][ 'Model' ] );
		barricade:SetMoveType( MOVETYPE_NONE );
		barricade:SetGravity( 0 );
		
		// angle
		barricade:SetAngles( ang );
		
		// position
		barricade:SetPos( pos );
		
		// spawn
		barricade:Spawn();
		
		// create bullseye
		local bullseye = ents.Create( "npc_bullseye" );
		bullseye:SetPos( pos );
		bullseye:SetParent( barricade );
		bullseye:Spawn();
		bullseye:SetSolid( SOLID_NONE );
		bullseye:Activate();
		
		// kill barricade
		bullseye:CallOnRemove( "killbarricade", function()
		
			// always validate
			if ( ValidEntity( barricade ) ) then
			
				// break
				barricade:Fire( "Break", "", 0 );
				
			end
			
		end );
		
		// kill target
		barricade:CallOnRemove( "killtarget", function()
		
			// always validate
			if ( ValidEntity( bullseye ) ) then
			
				// remove
				bullseye:Remove();
				
			end
			
		end );
		
		// delay
		timer.Simple( 0, function()
		
			// validate
			if ( ValidEntity( barricade ) ) then
			
				// set health
				barricade:Fire( "SetHealth", self.Barricades[ self.BarricadeIndex ][ 'Health' ], 0 );
				
				// get physics
				local phys = barricade:GetPhysicsObject();
				
				// validate
				if ( ValidEntity( phys ) ) then
				
					// enable
					phys:Wake();
					phys:EnableCollisions( true );
					phys:EnableMotion( false );
				
					// check
					if ( phys:IsPenetrating() ) then
					
						// kill
						barricade:Fire( "Break", "", 0.5 );
					
					end
				
				end
				
			end
			
			// validate
			if ( ValidEntity( bullseye ) ) then
			
				// set health
				bullseye:Fire( "SetHealth", self.Barricades[ self.BarricadeIndex ][ 'Health' ], 0 );
				
			end
			
		end );
		
		// return
		return barricade;
	
	end
	
end
