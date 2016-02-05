
// basic setup
ENT.Type 			= "anim";
ENT.PrintName		= "";
ENT.Author			= "";
ENT.Contact			= "";
ENT.Purpose			= "";
ENT.Instructions	= "";
ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;
ENT.Model			= Model( "models/Items/flare.mdl" );
ENT.RenderGroup 	= RENDERGROUP_BOTH;


/*------------------------------------
	SetOn
------------------------------------*/
function ENT:SetOn( bool )

	// update
	self:SetNetworkedBool( "Enabled", bool );
	
end


/*------------------------------------
	GetOn
------------------------------------*/
function ENT:GetOn()

	// return value
	return self:GetNetworkedVar( "Enabled" );
	
end
