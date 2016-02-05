
/*------------------------------------
	StartZahmode
------------------------------------*/
function GM:StartZahmode( dir )

	// msg
	zprint( "STARTING ZAHMODE", dir );
	
	// build path
	local path = "zahmbeez/gamemode/zahmodes/";
	
	// get all the files
	local files = file.FindInLua( ("%s%s/*.lua"):format( path, dir ) );
	
	// create ZMODE object table
	_G[ 'ZMODE' ] = {};
	
	// shared.lua
	if ( table.HasValue( files, "shared.lua" ) ) then
	
		// build file
		local f = ("%s%s/shared.lua"):format( path, dir );
		
		// include
		include( f );
		
	end
	
	// cl_init.lua
	if ( CLIENT && table.HasValue( files, "cl_init.lua" ) ) then
	
		// build file
		local f = ("%s%s/cl_init.lua"):format( path, dir );
		
		// include
		include( f );
	
	end
	
	// init.lua
	if ( SERVER && table.HasValue( files, "init.lua" ) ) then
	
		// build file
		local f = ("%s%s/init.lua"):format( path, dir );
		
		// include
		include( f );
	
	end
	
	// store it
	self.CurrentZahmode = dir;
	self.CurrentZahmodeTable = table.Copy( _G[ 'ZMODE' ] );
	
	// initialize
	hook.Call( "Initialize", GAMEMODE.CurrentZahmodeTable or {} );
	
	// clear ZMODE object table
	_G[ 'ZMODE' ] = nil;
	
end


/*------------------------------------
	ZCallHook
------------------------------------*/
function ZCallHook( name, ... )

	// check the zahmode first
	local result = hook.Call( name, GAMEMODE.CurrentZahmodeTable or {}, unpack( arg ) );
	
	// see if it overrides anything
	if ( result != nil ) then
	
		// bam! done.
		return result;
		
	end
	
	// call default :(
	return hook.Call( name, GAMEMODE, unpack( arg ) );

end
