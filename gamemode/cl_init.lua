
// manifest
include( 'manifest.lua' );

// storage
local ChangeClass = nil;


/*------------------------------------
	Initialize
------------------------------------*/
function GM:Initialize( )

	// base class
	self.BaseClass:Initialize();
	
end


/*------------------------------------
	Think
------------------------------------*/
function GM:Think( )

	// round thinkage
	self:RoundThink();
	
	// get all players
	local players = player.GetAll();
	
	// cycle players
	for _, pl in pairs( players ) do
	
		// validate
		if ( ValidEntity( pl ) && pl:IsPlayer() ) then
		
			// think
			pl:Think();
		
		end
	
	end
	
end


/*------------------------------------
	PostProcessPermitted
------------------------------------*/
function GM:PostProcessPermitted( name )

	// none
	return false;
	
end


/*------------------------------------
	RenderScreenspaceEffects
------------------------------------*/
function GM:RenderScreenspaceEffects( )

	// get LocalPlayer
	local LP = LocalPlayer();

	// crow vision
	if ( LP:IsSpectating() && LP:Alive() ) then

		// modify color
		DrawColorModify( {
			[ '$pp_colour_addr' ] = 0,
			[ '$pp_colour_addg' ] = 0,
			[ '$pp_colour_addb' ] = 0,
			[ '$pp_colour_brightness' ] = 0.08,
			[ '$pp_colour_contrast' ] = 1.7,
			[ '$pp_colour_colour' ] = 1,
			[ '$pp_colour_mulr' ] = 0,
			[ '$pp_colour_mulg' ] = 1,
			[ '$pp_colour_mulb' ] = 1,
		} );
		
	elseif ( !LP:IsSpectating() && LP:GetViewMode() == VIEWMODE_SHOLDER ) then
	
		// modify color
		DrawColorModify( {
			[ '$pp_colour_addr' ] = 0,
			[ '$pp_colour_addg' ] = 0,
			[ '$pp_colour_addb' ] = 0,
			[ '$pp_colour_brightness' ] = -0.025,
			[ '$pp_colour_contrast' ] = 1.4,
			[ '$pp_colour_colour' ] = 0.2,
			[ '$pp_colour_mulr' ] = 2,
			[ '$pp_colour_mulg' ] = 1,
			[ '$pp_colour_mulb' ] = 1,
		} );
		
	end
	
end


/*------------------------------------
	CalcView
------------------------------------*/
function GM:CalcView( pl, origin, angles, fov )

	// check for ragdoll
	local ragdoll = pl:GetRagdollEntity();
	
	// if there is a ragdoll, do death view
	if( ValidEntity( ragdoll ) ) then
	
		// find the eyes
		local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
		
		// no eyes
		if ( !eyes || eyes == 0 ) then
		
			// find bone
			local bone = ragdoll:GetPhysicsObjectNum( 2 );
			
			// validate
			if ( bone && bone:IsValid() ) then
			
				// setup our view
				local view = {
					origin = bone:GetPos(),
					angles = bone:GetAngles(),
					fov = 90
				};
				
				// override view
				return view;
			
			// throw me a freakin bone man!
			else
			
				// no override
				return;
				
			end
			
		end
		
		// setup our view
		local view = {
			origin = eyes.Pos,
			angles = eyes.Ang,
			fov = 90,
			
		};
		
		// override view
		return view;
		
	end
	
	// basic view
	return self.BaseClass:CalcView( pl, origin, angles, fov );
	
end


/*------------------------------------
	ShowChangeClass
------------------------------------*/
local function ShowChangeClass( pl, cmd, args )

	// validate
	if ( !ChangeClass || !ChangeClass:IsValid() ) then
	
		// create
		ChangeClass = vgui.Create( "ZahmbeezChangeClass" );
		ChangeClass:Center();
		ChangeClass:MakePopup();
	
	end

end

// hook
concommand.Add( "changeclass", ShowChangeClass );
