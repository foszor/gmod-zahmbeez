
// includes
include( "shared.lua" );

//---------- Info
SWEP.DrawAmmo			= true;
SWEP.DrawCrosshair		= true;
SWEP.ViewModelFOV		= 62;
SWEP.ViewModelFlip		= false;
SWEP.RenderGroup 		= RENDERGROUP_OPAQUE;


/*------------------------------------
	Think
------------------------------------*/
function SWEP:Think( )

	// update ghost
	self:UpdateGhost();

end


/*------------------------------------
	CreateGhost
------------------------------------*/
function SWEP:CreateGhost( )

	// create ghost
	local ghost = ents.Create( "prop_physics" );
	ghost:SetPos( self.Owner:GetPos() );
	ghost:DrawShadow( false );
	ghost:Spawn();
	
	// save
	self.Ghost = ghost;
	
	// set model
	self:UpdateGhostModel();

end


/*------------------------------------
	UpdateGhost
------------------------------------*/
function SWEP:UpdateGhost( )

	// get function and args
	local func = self[ self.Barricades[ self.BarricadeIndex ][ 'Trace' ] ];
	local args = self.Barricades[ self.BarricadeIndex ][ 'TraceArgs' ];
	
	// get position and angles
	local pos, ang = func( self, unpack( args ) );
	
	// validate
	if ( pos && ang ) then
	
		// update position and angles
		self.Ghost:SetPos( pos );
		self.Ghost:SetAngles( ang );
		self.Ghost:SetNoDraw( false );
		
	else
	
		// hide
		self.Ghost:SetPos( self.Owner:GetPos() );
		self.Ghost:SetNoDraw( true );
	
	end
	
end


/*------------------------------------
	UpdateGhostModel
------------------------------------*/
function SWEP:UpdateGhostModel( )

	// validate ghost
	if ( ValidEntity( self.Ghost ) ) then
	
		// update model
		self.Ghost:SetModel( self.Barricades[ self.BarricadeIndex ][ 'Model' ] );
		self.Ghost:SetMaterial( "models/wireframe" );
	
	end
	
end


/*------------------------------------
	RemoveGhost
------------------------------------*/
function SWEP:RemoveGhost( )

	// validate ghost
	if ( ValidEntity( self.Ghost ) ) then
	
		// remove
		SafeRemoveEntity( self.Ghost );
	
	end

end
