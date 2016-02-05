
// include files.
include( 'shared.lua' );

// convars
local CrosshairSmooth = CreateClientConVar( "cl_zahmbeez_crosshair_smooth", "0.5", true, false );

// materials
local matLaser = Material( "sprites/glow04_noz" );

local matCrosshair = CreateMaterial(
	"ZahmCrosshair", // name
	"UnlitGeneric", // type
	// flags
	{
		[ '$basetexture' ] = "zahmbeez/hud/crosshair",
		[ '$additive' ] = 1,
		[ '$ignorez' ] = 1,
		[ '$alpha' ] = 0.4,
	}
);


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// defaults
	self.Width = 8;
	
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )
	
	// get owner
	local pl = self.Entity:GetOwner();
	
	// get LocalPlayer
	local LP = LocalPlayer();
	
	// draw for owner only
	if ( pl != LP ) then
	
		return;
		
	end
	
	// forward
	local forward = pl:GetAimVector():Angle():Forward();
	
	// start
	local shootpos = pl:GetShootPos();
	local start = shootpos + ( forward * 20 );
	
	// end
	local endpos = start + ( forward * 1024 );
	
	// build the trace
	local trace = {};
	trace.start = shootpos;
	trace.endpos = endpos;
	trace.filter = pl;
	
	// trace it
	local tr = util.TraceLine( trace );
	
	// store info
	self.Color = Color( 255, 255, 255, 255 );
	self.EndPos = tr.HitPos;
	self.StartPos = start;
	self.TraceEnt = tr.Entity;
		
	// update render bounds
	self.Entity:SetRenderBoundsWS( self.EndPos, self.Entity:GetPos(), Vector() * 8 );
		
	// top down
	if ( LP:GetViewMode() == VIEWMODE_TOPDOWN && !LP:IsSpectating() ) then
	
		// set material
		render.SetMaterial( matLaser );
		
		// offset the texture coords so it looks like it's scrolling
		local offset = CurTime() * 3;
		
		// no positions set? wtf?
		if ( !self.EndPos || !self.StartPos ) then
		
			// ( o Y o )
			return;
			
		end
		
		// texture coords relative to distance
		local dist = self.EndPos:Distance( self.Entity:GetPos() );
		
		// set color
		local color = self.Color;
		
		// calculate alpha based on distance
		color.a = math.Clamp( ( ( self.EndPos:Distance( self.StartPos ) - 120 ) / 400 ) * 60, 0, 60 );
		
		// draw beams
		render.DrawBeam( self.EndPos, self.StartPos, self.Width, offset, offset + dist * 0.125, color );
		render.DrawBeam( self.EndPos, self.StartPos, self.Width * 0.5, offset, offset + dist * 0.125, color );
		
	end
	
end


/*------------------------------------
	PitchLimiter
------------------------------------*/
local function PitchLimiter( ucmd )

	// get LocalPlayer
	local LP = LocalPlayer();

	// spectators
	if ( LP:IsSpectating() ) then
	
		// no jumping
		ucmd:SetUpMove( 0 );
		
		return;
		
	// top down players
	elseif ( LP:GetViewMode() == VIEWMODE_TOPDOWN ) then
	
		// get the current angles.
		local view = ucmd:GetViewAngles( );
		
		// clamp their pitch.
		view.pitch = math.Clamp( view.pitch , 8 , 40 );
		
		// change the view.
		ucmd:SetViewAngles( view );
		
	end

end

// hook
hook.Add( "CreateMove", "AimController_CreateMove", PitchLimiter );


/*------------------------------------
	HUDPaint
------------------------------------*/
function ENT:HUDPaint( LP, xscale, yscale )

	// hasnt been set yet
	if ( !self.EndPos ) then
	
		// nothing to draw
		return;
		
	end
	
	// top down cursor
	if ( LP:GetViewMode() == VIEWMODE_TOPDOWN ) then
	
		// convert to screen space
		local pos = self.EndPos:ToScreen();
	
		// set color
		surface.SetDrawColor( 255, 255, 255, 100 );
		
		// set cursor material
		surface.SetMaterial( matCrosshair );
		
		// variable size
		local size = 25 + ( math.sin( CurTime() * 5 ) * 2 );
		
		// draw circle
		surface.DrawTexturedRectRotated( pos.x, pos.y, size, size, CurTime() * -100 );
		
	else
	
		// default
		self.LastPos = self.LastPos or self.EndPos;
		
		// lerped position
		local lerped = LerpVector( math.Clamp( CrosshairSmooth:GetFloat(), 0.01, 1 ), self.LastPos, self.EndPos );
		
		// save
		self.LastPos = lerped;
		
		// convert to screen space
		local pos = lerped:ToScreen();
		
		// set design
		local length = 16;
		local frac = 0.25;
		local alpha = 100;
	
		// set color
		surface.SetDrawColor( 255, 255, 180, alpha );
		
		// get center
		local cx = pos.x;
		local cy = pos.y;
		
		// left
		surface.DrawLine( cx - ( length * frac ) - length, cy, cx - ( length * frac ), cy );
		
		// top
		surface.DrawLine( cx, cy - ( length * frac ) - length, cx, cy - ( length * frac ) );
		
		// right
		surface.DrawLine( cx + ( length * frac ) + length, cy, cx + ( length * frac ), cy );
		
		// bottom
		surface.DrawLine( cx, cy + ( length * frac ) + length, cx, cy + ( length * frac ) );
		
	end
	
	// validate
	if ( ValidEntity( self.TraceEnt ) ) then
	
		// check for HUDPaint
		if ( self.TraceEnt.Entity.HUDPaint ) then
		
			// call it
			self.TraceEnt.Entity:HUDPaint( LP, xscale, yscale );
		
		end
	
		// check for player
		if ( self.TraceEnt:IsPlayer() && self.TraceEnt:Alive() && !self.TraceEnt:IsSpectating() ) then
		
			// verticle position
			local xpos = ScrW() * 0.5;
			local ypos = ScrH() * 0.9;
		
			// draw text
			draw.SimpleTextOutlined(
				self.TraceEnt:Name(), // text
				"ZahmbeezTarget", // font
				xpos, // x position
				ypos, // y position
				Color( 200, 200, 200, 255 ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, // alignment
				2, // border size
				Color( 0, 0, 0, 60 ) // border color
			);
			
			// setup size
			local wide = 160 * xscale;
			local tall = 16 * yscale;
			
			// verticle position
			ypos = ypos + draw.GetFontHeight( "ZahmbeezTarget" ) + ( 8 * yscale ) + ( tall * 0.5 );
			
			// draw background
			draw.RoundedBox(
				4,
				( xpos - wide * 0.5 ),
				( ypos - tall * 0.5 ),
				wide, tall,
				Color( 0, 0, 0, 160 )
			);
			
			// health fraction
			local frac = math.Clamp( self.TraceEnt:Health() / 100, 0, 1 );
			
			// shrink
			wide = wide - ( 6 * xscale );
			tall = tall - ( 6 * xscale );
			
			// calculate red and green
			local r = frac - ( 180 * frac );
			local g = ( 180 * frac );
			
			// draw health
			draw.RoundedBox(
				4,
				( xpos - wide * 0.5 ),
				( ypos - tall * 0.5 ),
				wide * frac, tall,
				Color( r, g, 0, 190 )
			);
	
		
		end
	
	end

end
