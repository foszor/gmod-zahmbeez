
// basic setup
ENT.Type 					= "point";
ENT.Base 					= "base_point";
ENT.PrintName				= "";
ENT.Author					= "";
ENT.Contact					= "";
ENT.Purpose					= "";
ENT.Instructions			= "";
ENT.Spawnable				= false;
ENT.AdminSpawnable			= false;


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	//
	
end


/*------------------------------------
	KeyValue
------------------------------------*/
function ENT:KeyValue( key, value )
	
	// check for event
	if ( key:sub( 1, 2 ) == "On" ) then
	
		// save
		self:StoreOutput( key, value );
	
	else
	
		// lowercase
		key = key:lower();
		
		// check generator fuel
		if ( key == "generatorfuel" ) then
		
			// change the convar
			game.ConsoleCommand( ("sv_zahm_generatorfuel %d\n"):format( value ) );
			
		// check zahmode
		elseif ( key == "zahmode" ) then
		
			// store it
			GAMEMODE.CurrentZahmode = value:lower();
		
		end
	
	end

end
