
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


// accessor
AccessorFunc( ENT, "isactive", "Active", FORCE_BOOL );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// setup
	self:SetActive( false );
	
end


/*------------------------------------
	OnRoundRestart
------------------------------------*/
function ENT:OnRoundRestart( )

	// no generator specified?
	if ( !self.KeyValues[ 'GeneratorName' ] ) then
	
		// not a valid spawn
		return;
		
	end
	
	// generator hasnt been located yet
	if ( !self.Generator ) then

		// find by name
		local gen = ents.FindByName( self.KeyValues[ 'GeneratorName' ] )[ 1 ];
		
		// validate
		if ( ValidEntity( gen ) && gen:GetClass() == "zahmbeez_generator" ) then
		
			// save
			self.Generator = gen; 
		
		end
		
		// active spawn
		self:SetActive( true );
		
	end
		
end


/*------------------------------------
	CanSpawn
------------------------------------*/
function ENT:CanSpawn( )

	// not an active spawn
	if ( !self:GetActive() ) then
	
		// can spawn here
		return false;
		
	end
	
	// check generator
	if ( ValidEntity( self.Generator ) && self.Generator:GetOn() ) then
	
		// FREEDOOOMMM!
		return true;
		
	end
	
	// hell naw
	return false;

end


/*------------------------------------
	KeyValue
------------------------------------*/
function ENT:KeyValue( key, value )

	// defaults
	self.KeyValues = self.KeyValues or {};
	
	// check for event
	if ( key:sub( 1, 2 ) == "On" ) then
	
		// save
		self:StoreOutput( key, value );
	
	else
	
		// lowercase
		key = string.lower( key );
		
		// store
		self.KeyValues[ key ] = value;
	
	end

end
