
// basic setup
ENT.Base 					= "base_ai";
ENT.Type 					= "ai";
ENT.PrintName				= "";
ENT.Author					= "";
ENT.Contact					= "";
ENT.Purpose					= "";
ENT.Instructions			= "";
ENT.RenderGroup 			= RENDERGROUP_BOTH;
ENT.Model					= Model( "models/Humans/Group02/Female_02.mdl" );
ENT.AutomaticFrameAdvance	= true;


/*------------------------------------
	OnRemove
------------------------------------*/
function ENT:OnRemove( )

end


/*------------------------------------
	PhysicsCollide
------------------------------------*/
function ENT:PhysicsCollide( data, physobj )

end


/*------------------------------------
	PhysicsUpdate
------------------------------------*/
function ENT:PhysicsUpdate( physobj )

end


/*------------------------------------
	SetAutomaticFrameAdvance
------------------------------------*/
function ENT:SetAutomaticFrameAdvance( bool )

	// set bool
	self.AutomaticFrameAdvance = bool;
	
end
