
// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )
	
end

local matGlow = Material( "Models/effects/comball_sphere" );

/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )
	
	// draw normal
	self:DrawModel();
	
	// setup light & color
	render.SuppressEngineLighting( true );
	render.SetAmbientLight( 1, 1, 1 );
	render.SetColorModulation( 1, 1, 1 );
	
	
	self:SetModelScale( Vector() * 1.01 );
	SetMaterialOverride( matGlow );
	self:DrawModel();
	
	// reset
	SetMaterialOverride( nil );
	self:SetModelScale( Vector() );
	render.SuppressEngineLighting( false );
	local r, g, b = self:GetColor();
	render.SetColorModulation( r / 255, g / 255, b / 255 );

end
