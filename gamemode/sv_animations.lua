
// animation table
local AnimationTranslation = {

	[ 'idle' ] = "idle_angry",
	[ 'idleholding' ] = "d1_t01_Luggage_Idle",
	[ 'walk' ] = "walk_all",
	[ 'walkholding' ] = "luggage_walk_all",
	[ 'run' ] = "run_all",
	[ 'runholding' ] = "luggage_walk_all",
	[ 'glide' ] = "jump_holding_glide",
	[ 'crouchglide' ] = "Crouch_Idle_RPG",
	[ 'sit' ] = "Sit_Ground",
	[ 'crouchidle' ] = "Crouch_idleD",
	[ 'crouchidleholding' ] = "Crouch_idleD",
	[ 'crouchwalk' ] = "Crouch_walk_all",
	[ 'crouchwalkholding' ] = "Crouch_walk_all",
	
	[ 'smgidle' ] = "Idle_Relaxed_SMG1_<1,9>",
	[ 'smgidlealert' ] = "Idle_SMG1_Aim_Alert",
	[ 'smgwalk' ] = "walk_all",
	[ 'smgwalkalert' ] = "walkAlertAimALL1",
	[ 'smgrun' ] = "run_all",
	[ 'smgrunalert' ] = "run_alert_aiming_all",
	[ 'smgcrouchidle' ] = "Crouch_idleD",
	[ 'smgcrouchidlealert' ] = "crouch_aim_smg1",
	[ 'smgcrouchwalk' ] = "Crouch_walk_all",
	[ 'smgcrouchwalkalert' ] = "Crouch_walk_aiming_all",
	[ 'smgcrouchrun' ] = "Crouch_walk_all",
	[ 'smgreload' ] = ACT_GESTURE_RELOAD_SMG1,
	[ 'smgfire' ] = ACT_GESTURE_RANGE_ATTACK_PISTOL,
	
	[ 'meleeidle' ] = "idle_angry",
	[ 'meleeidlealert' ] = "idle_angry_melee",
	[ 'meleewalk' ] = "walk_all",
	[ 'meleewalkalert' ] = "walk_all",
	[ 'meleerun' ] = "run_all",
	[ 'meleerunalert' ] = "run_all",
	[ 'meleecrouchidle' ] = "Crouch_idleD",
	[ 'meleecrouchidlealert' ] = "Crouch_idleD",
	[ 'meleecrouchwalk' ] = "Crouch_walk_all",
	[ 'meleecrouchwalkalert' ] = "Crouch_walk_all",
	[ 'meleecrouchrun' ] = "Crouch_walk_all",
	[ 'meleereload' ] = ACT_GESTURE_RELOAD_SMG1,
	[ 'meleefire' ] = "swing",
	
};

// activity table
local ActivityTranslation = {

	[ 0 ] = "idle",
	[ 1 ] = "run",
	[ 2 ] = "jump",
	[ 5 ] = "fire",
	[ 7 ] = "reload",

};


/*------------------------------------
	SetPlayerAnimation
------------------------------------*/
function GM:SetPlayerAnimation( pl, plact )

	// check for spectator
	if ( pl:IsSpectating() ) then
	
		// handle special bird animations
		self:SetSpectatorAnimation( pl, plact );
		return;
	
	end
	
	// always aim in OTS
	if ( pl:GetViewMode() == VIEWMODE_SHOLDER ) then
	
		// set alert
		pl:Alert();
	
	end
	
	// get weapon
	local weapon = pl:GetActiveWeapon();
	
	// get hold type
	local weapontype = ( weapon:IsValid() && weapon:IsWeapon() && weapon.GetWeaponHoldType ) && weapon:GetWeaponHoldType() || "smg";
	
	// get activity
	local activity = ActivityTranslation[ plact ] or "";
	
	// get alert status
	local alert = ( weapontype != "" && pl:IsAlerted() ) && "alert" || "";
	
	// get speed
	local speed = pl:GetVelocity():Length();
	
	// get crouched status
	local crouch = ( pl:Crouching() ) && "crouch" || "";
	
	// default activity
	local speedact = "idle";
	
	// movment animation
	if ( speed > 150 && !pl:Crouching() ) then
	
		// running animation
		speedact = "run";
		
		// no aiming while sprinting
		if ( pl:IsSprinting() ) then
		
			// clear it
			alert = "";
		
		end
		
	elseif ( speed > 0 ) then
	
		// walking animation
		speedact = "walk";
		
	end
	
	// check for holding
	if ( pl:IsHolding() ) then
	
		// find gesture
		local sequence = AnimationTranslation[ ("%sholding"):format( speedact ) ];
		
		// validate
		if ( !sequence ) then
		
			print( "sequence not found! ", ("%sholding"):format( speedact ) );
			return;
		
		end
		
		// set sequence
		self:SetPlayerSequence( pl, sequence );
	
	// check for weapon gestures
	elseif ( activity == "fire" || activity == "reload" ) then
	
		// reloading?
		if ( activity == "reload" && self:GetRoundState() == ROUND_ACTIVE ) then
		
			// play event
			self:PlayerSoundEvent( pl, SE_RELOAD );
		
		end
	
		// set alert
		pl:Alert();
		
		// find gesture
		local gesture = AnimationTranslation[ ("%s%s"):format( weapontype, activity ) ];
		
		// validate
		if ( !gesture ) then
		
			print( "gesture not found! ", ("%s%s"):format( weapontype, activity ) );
			return;
			
		elseif ( type( guesture ) == "string" ) then
		
			// set sequence
			self:SetPlayerSequence( pl, guesture );
			return;
		
		end
		
		// animate player
		pl:RestartGesture( gesture );
		
		// check for avatar
		if ( ValidEntity( pl.Avatar.Avatar ) ) then
		
			// animate avatar
			pl.Avatar.Avatar:RestartGesture( gesture );
			
		end
	
	// check for movement
	elseif ( activity == "run" || activity == "idle" ) then
		
		// find sequence
		local sequence = AnimationTranslation[ ("%s%s%s%s"):format( weapontype, crouch, speedact, alert ) ];
		
		// validate
		if ( !sequence ) then
		
			print( "sequence not found! ", ("%s%s%s%s"):format( weapontype, crouch, speedact, alert ) );
			return;
			
		end
		
		// randomize
		sequence = self:RandomizeSequence( pl, activity, sequence );
		
		//print( "sequence ", sequence, " ----- ", ("%s%s%s%s"):format( weapontype, crouch, speedact, alert ) );
		
		// set sequence
		self:SetPlayerSequence( pl, sequence );
	
	end
	
	// check for jumping
	if ( !pl:OnGround() ) then
	
		// get crouched status
		local crouch = ( pl:Crouching() ) && "crouch" || "";
		
		// find sequence
		local sequence = AnimationTranslation[ ("%sglide"):format( crouch ) ];
		
		// set sequence
		self:SetPlayerSequence( pl, sequence );
		
	end

end


/*------------------------------------
	RandomizeSequence
------------------------------------*/
function GM:RandomizeSequence( pl, activity, sequence )

	// default activity timeout
	pl.LastActivityTimeout = pl.LastActivityTimeout or 0;
	
	// hasn't expired yet
	if ( activity == pl.LastActivity && CurTime() < pl.LastActivityTimeout ) then
	
		return pl.LastActivitySequence;
		
	end
	
	// check for table
	if ( type( sequence ) == "table" ) then
	
		// find random	
		sequence = sequence[ math.random( 1, #sequence ) ];
	
	end
	
	// get randomize area
	local startpos = sequence:find( "<" );
	local endpos = sequence:find( ">" );
	
	// not there
	if ( !startpos || !endpos ) then
	
		return sequence;
	
	end
	
	// break string apart
	local string1 = sequence:sub( 1, startpos - 1 );
	local rangestr = sequence:sub( startpos + 1, endpos - 1 );
	local string2 = sequence:sub( endpos + 1 );
	
	// get high and low number
	local low, high = unpack( string.Explode( ",", rangestr ) );
	
	// random number
	local num = math.Rand( low, high );
	
	// create new sequence
	local newsequence = ("%s%d%s"):format( string1, num, string2 );
	
	// store
	pl.LastActivity = activity;
	pl.LastActivityTimeout = CurTime() + math.Rand( 5, 10 );
	pl.LastActivitySequence = newsequence;
	
	// return
	return newsequence;

end


/*------------------------------------
	SetPlayerSequence
------------------------------------*/
function GM:SetPlayerSequence( pl, sequence )

	// lookup
	sequence = pl:LookupSequence( sequence );

	// dont use same sequence
	if ( pl:GetSequence() == sequence ) then
	
		return;
		
	end
	
	// animate player
	pl:SetPlaybackRate( 1 );
	pl:ResetSequence( sequence );
	pl:SetCycle( 0 );
	
	// check for avatar
	if ( pl.Avatar && ValidEntity( pl.Avatar.Avatar ) ) then
	
		// animate avatar
		pl.Avatar.Avatar:SetPlaybackRate( 1 );
		pl.Avatar.Avatar:ResetSequence( sequence );
		pl.Avatar.Avatar:SetCycle( 0 );
		
	end

end


/*------------------------------------
	SetSpectatorAnimation
------------------------------------*/
function GM:SetSpectatorAnimation( pl, plact )

	// default sequence
	local sequence = "Idle01";
	
	// player speed
	local speed = pl:GetVelocity():Length();
	
	// moving
	if ( speed > 0 ) then
	
		// moving on ground
		if ( pl:OnGround() ) then
		
			// check speed
			if ( speed > 10 ) then
			
				// running
				sequence = "Run";
				
			else
			
				// walking
				sequence = "Walk";
				
			end
		
		else
			
			// check for jump key
			if ( pl:KeyDown( IN_JUMP ) ) then
			
				// flying
				sequence = "Fly01";
				
			else
			
				// soaring
				sequence = "Soar";
			
			end
			
		end
		
	else
	
		// secondary attack lets them eat at ground
		if ( pl:KeyDown( IN_ATTACK2 ) ) then
		
			// eating
			sequence = "Eat_A";
			
		end
		
	end
	
	// lookup the sequence
	sequence = pl:LookupSequence( sequence );

	// dont use same sequence
	if ( pl:GetSequence() == sequence ) then return; end
	
	// animate player
	pl:SetPlaybackRate( 1 );
	pl:ResetSequence( sequence );
	pl:SetCycle( 0 );
	
end

