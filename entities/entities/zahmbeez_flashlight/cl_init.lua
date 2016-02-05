
// shared file
include( 'shared.lua' );

// materials
local matLight = Material( "sprites/light_ignorez" );
local matBeam = Material( "effects/lamp_beam" );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// create handle
	self.PixelVisiblity = util.GetPixelVisibleHandle();
	
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )
	
//	self:DrawModel();

end


/*------------------------------------
	DrawTranslucent
------------------------------------*/
function ENT:DrawTranslucent( think_only )

	// check if off
	if ( !self:GetOn() ) then
	
		return;
		
	end
	
	// get player
	local pl = self.Entity:GetOwner();
	
	// validate
	if ( !ValidEntity( pl ) ) then
	
		return;
		
	end
	
	// get hand
	local hand = pl:GetAttachment( pl:LookupAttachment( "anim_attachment_LH" ) );
	
	// get angle
	local ang = pl:GetAimVector():Angle();
	
	// rotate forward
	ang:RotateAroundAxis( ang:Right(), 90 );
	
	// update
	self.Entity:SetPos( hand.Pos );
	self.Entity:SetAngles( ang );
	
	if ( think_only ) then
	
		return;
		
	end
	
	// get normals
	local lightnormal = self.Entity:GetAngles():Up();
	local viewnormal = self.Entity:GetPos() - EyePos();
	
	// distance
	local dist = viewnormal:Length();
	
	// dot
	viewnormal:Normalize();
	local viewdot = viewnormal:Dot( lightnormal );
	
	// position
	local lightpos = hand.Pos + lightnormal * -6;
	
	// glow sprite
	if ( viewdot >= 0 ) then
	
		// set material
		render.SetMaterial( matLight );
		local vis = util.PixelVisible( lightpos, 16, self.PixelVisiblity );
		
		// make sure its visible
		if ( !vis ) then
		
			return;
			
		end
		
		// calculate size
		local size = math.Clamp( dist * vis * viewdot * 2, 32, 64 );
		
		// clamp distance
		dist = math.Clamp( dist, 32, 800 );
		
		// calculate color alpha
		local alpha = math.Clamp( ( 1000 - dist ) * vis * viewdot, 0, 100 );
		local color = Color( 255, 255, 255, alpha );
		
		// draw sprites
		render.DrawSprite( lightpos, size, size, color, vis * viewdot );
		render.DrawSprite( lightpos, size * 0.4, size * 0.4, color, vis * viewdot );
		
	end
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	timer.Simple( 0, function()
	
		self:DrawTranslucent( think_only );
		
	end );
	
	// keep thinking
	self.Entity:NextThink( CurTime() );
	return true;
	
end


/*------------------------------------
	PlayerBindPress
------------------------------------*/
local function PlayerBindPress( pl, bind, pressed )

	// check for flashlight button
	if ( bind:find( "impulse 100" ) && pressed ) then
		
		// run command
		RunConsoleCommand( "zahmbeez_flashlight" );
		
		// override	
		return true;
		
	end

end

// hook
hook.Add( "PlayerBindPress2", "Flashlight_PlayerBindPress", PlayerBindPress );
