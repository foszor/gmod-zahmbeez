
/*------------------------------------
	SelectClass
------------------------------------*/
local function SelectClass( pl, cmd, args )

	// validate
	if ( !args[ 1 ] ) then
	
		return;
		
	end
	
	// get class and verify
	local class = math.Clamp( tonumber( args[ 1 ] ), 0, 3 );
	
	// set it
	pl:SetGameClass( class );

end

// hook
concommand.Add( "selectclass", SelectClass );


/*------------------------------------
	ShowTeam
------------------------------------*/
function GM:ShowTeam( pl )

	// clientside
	pl:ConCommand( "changeclass" );

end


/*------------------------------------
	ClassModel
------------------------------------*/
function GM:ClassModel( pl )

	// get class
	local class = pl:GetGameClass();
	
	if ( class == CLASS_LEATHERNECK ) then
	
		// blue guy
		return "models/Humans/Group03/male_02.mdl";
		
	elseif ( class == CLASS_MACGYVER ) then
	
		// green shirt gloves
		return "models/Humans/Group03/male_09.mdl";
		
	elseif ( class == CLASS_ERRANDBOY ) then
	
		// white guy medic
		return "models/Humans/Group03m/male_09.mdl";
	
	end
	
	// default?
	return "models/Humans/Group02/Male_04.mdl";

end


/*------------------------------------
	ClassLoadout
------------------------------------*/
function GM:ClassLoadout( pl )

	// get class
	local class = pl:GetGameClass();
	
	if ( class == CLASS_LEATHERNECK ) then
	
		pl:Give( "zahmbeez_weapon_smg" );
		
	elseif ( class == CLASS_MACGYVER ) then
	
		pl:Give( "zahmbeez_weapon_barricader" );
		
	elseif ( class == CLASS_ERRANDBOY ) then
	
	end
	
	// give ammo
	pl:AmmoUp();

end
