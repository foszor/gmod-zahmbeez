
// server stuff
if ( SERVER ) then

	// client downloads
	AddCSLuaFile( 'cl_hud.lua' );
	AddCSLuaFile( 'cl_init.lua' );
	AddCSLuaFile( 'cl_player_class.lua' );
	AddCSLuaFile( 'cl_rounds.lua' );
	AddCSLuaFile( 'manifest.lua' );
	AddCSLuaFile( 'shared.lua' );
	AddCSLuaFile( 'sh_animations.lua' );
	AddCSLuaFile( 'sh_entity_class.lua' );
	AddCSLuaFile( 'sh_enums.lua' );
	AddCSLuaFile( 'sh_npc_class.lua' );
	AddCSLuaFile( 'sh_player_class.lua' );
	AddCSLuaFile( 'sh_rounds.lua' );
	AddCSLuaFile( 'cl_weapon_effects.lua' );
	
	// server files
	include( 'sv_animations.lua' );
	include( 'sv_classes.lua' );
	include( 'sv_player_class.lua' );
	include( 'sv_player_events.lua' );
	include( 'sv_queue.lua' );
	include( 'sv_resources.lua' );
	include( 'sv_rounds.lua' );
	include( 'sv_sounds.lua' );

end


// shared files
include( 'sh_animations.lua' );
include( 'sh_entity_class.lua' );
include( 'sh_enums.lua' );
include( 'sh_npc_class.lua' );
include( 'sh_player_class.lua' );
include( 'sh_rounds.lua' );
include( 'shared.lua' );


// client stuff
if ( CLIENT ) then

	// client files
	include( 'cl_hud.lua' );
	include( 'cl_player_class.lua' );
	include( 'cl_rounds.lua' );
	include( 'cl_weapon_effects.lua' );

end


// load the VGUI stuff

// paths
local base = "zahmbeez/gamemode/";
local dir = "vgui/";

// find all vgui
local filelist = file.FindInLua( ("%s%s*.lua"):format( base, dir ) );
for _, f in pairs( filelist ) do

	// server only
	if ( SERVER ) then
	
		// download to clients
		AddCSLuaFile( ("%s%s%s"):format( base, dir, f ) );
		
	else
	
		// include
		include( ("%s%s%s"):format( base, dir, f ) );
		
	end

end
