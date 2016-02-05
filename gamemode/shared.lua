
// basic gamemode information
GM.Name 	= "Zahmbeez!";
GM.Author 	= "Modulus Software";
GM.Email 	= "";
GM.Website 	= "";


// teams
team.SetUp( TEAM_PLAYERS, "Players", Color( 255, 255, 180, 255 ) );
team.SetUp( TEAM_RAVENS, "Ravens", Color( 200, 200, 200, 255 ) );

// zombie classes
ZombieClasses = {

	"npc_zombie",
	"npc_zombie_torso",
	"npc_fastzombie",
	"npc_fastzombie_torso",
	"npc_headcrab",
	"npc_headcrab_black",
	"npc_headcrab_fast",
	"npc_poisonzombie"

};


/*------------------------------------
	zprint
------------------------------------*/
function zprint( ... )

	// show which side its on
	local prefix = ( SERVER ) && "SERVER" || "CLIENT";
	
	// empty text
	local text = "";
	
	// cycle arguments
	for i = 1, #arg do
	
		// grab value
		local t = arg[ i ];
		
		// glue them together
		text = text .. " " .. t;
	
	end
	
	// shit it all to the console
	print( "\n\n**********************************************" );
	print( prefix .. ": " .. text );
	print( "**********************************************\n" );

end


/*------------------------------------
	Move
------------------------------------*/
function GM:Move( pl, mdata )

	// only modify spectator movement
	if ( !pl:IsSpectating() || !pl:Alive() ) then
			
		// bye
		return;
		
	end
	
	// cant strafe
	mdata:SetSideSpeed( 0 );

	// get current velocity & angle
	local vel = mdata:GetVelocity();
	local ang = mdata:GetMoveAngles();
			
	// flying	
	if ( !pl:OnGround() ) then
	
		// flying up
		if ( pl:KeyDown( IN_JUMP ) ) then
		
			// server only
			if ( SERVER ) then
			
				// update sound
				pl:SetWingSound( true );
				
			end
			
			// calculate multiplier
			local mul = ( vel.z > 40 ) && 9 || 13; // 9 - 13
			
			if ( isDedicatedServer() ) then
			
				mul = mul * 2;
			
			end
			
			// give upward speed
			vel = vel + ( ang:Up() * mul );
			
		else
		
			// server only
			if ( SERVER ) then
			
				// update sound
				pl:SetWingSound( false );
				
			end
			
			// set multiplier
			local mul = 8;
			
			if ( isDedicatedServer() ) then
			
				mul = mul * 2;
			
			end
		
			// float down
			vel = vel + ( ang:Up() * 8 );
			
		end
		
	else
	
		// server only
		if ( SERVER ) then
		
			// update sound
			pl:SetWingSound( false );
			
		end
		
	end
	
	// clamp their speed
	vel = ( vel:GetNormal() * math.min( vel:Length(), 180 ) );
	
	// update velocity
	mdata:SetVelocity( vel );
	
	// run the animation function
	if ( SERVER && pl:Alive() ) then
	
		// attack key
		if ( pl:KeyDown( IN_ATTACK ) ) then
		
			// BAWK!
			pl:PlaySquawk();
		
		end
	
		// this helps update to the proper animation
		self:SetPlayerAnimation( pl, 1 );
	
	end

end
