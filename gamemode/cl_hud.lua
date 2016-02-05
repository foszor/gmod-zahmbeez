
// fonts
surface.CreateFont( "Evil Of Frankenstein", ScreenScale( 16 ), 700, true, false, "ZahmbeezHUD" );
surface.CreateFont( "Evil Of Frankenstein", ScreenScale( 10 ), 400, true, false, "ZahmbeezHUDSmall" );
surface.CreateFont( "Evil Of Frankenstein", ScreenScale( 22 ), 700, true, false, "ZahmbeezMotionText" );
surface.CreateFont( "Blackjack", ScreenScale( 10 ), 700, true, false, "ZahmbeezTarget" );

// materials
local matBooty = Material( "zahmbeez/hud/booty" );
local matBG1 = Material( "zahmbeez/hud/bg1" );
local matHeart = Material( "zahmbeez/hud/heart" );
local matBrain = Material( "zahmbeez/hud/brain" );
local matBG2 = Material( "zahmbeez/hud/bg2" );
local matAmmo = Material( "zahmbeez/hud/ammo" );

local matEnemy = CreateMaterial(
	"ZahmEnemy", // name
	"UnlitGeneric", // type
	// flags
	{
		[ '$basetexture' ] = "zahmbeez/hud/enemy",
		[ '$additive' ] = 1,
		[ '$ignorez' ] = 1,
		[ '$alpha' ] = 0.4,
	}
);

local matFriendly = CreateMaterial(
	"ZahmFriendly", // name
	"UnlitGeneric", // type
	// flags
	{
		[ '$basetexture' ] = "zahmbeez/hud/friendly",
		[ '$additive' ] = 1,
		[ '$ignorez' ] = 1,
		[ '$alpha' ] = 0.4,
	}
);

local matTarget = CreateMaterial(
	"ZahmTarget", // name
	"UnlitGeneric", // type
	// flags
	{
		[ '$basetexture' ] = "zahmbeez/hud/target",
		[ '$additive' ] = 1,
		[ '$ignorez' ] = 1,
		[ '$alpha' ] = 0.4,
	}
);


// storage
local MotionText = {};
local RadarEntities = nil;
local NextRadarRefresh = 0;
local RadarMaterials = {

	[ RADAR_ENEMY ] = matEnemy,
	[ RADAR_FRIENDLY ] = matFriendly,
	[ RADAR_OBJECTIVE ] = matTarget

};


/*------------------------------------
	HUDDrawTargetID
------------------------------------*/
function GM:HUDDrawTargetID( )

	// none
	
end


/*------------------------------------
	HUDDrawPickupHistory
------------------------------------*/
function GM:HUDDrawPickupHistory( )

	// none

end


/*------------------------------------
	HUDShouldDraw
------------------------------------*/
function GM:HUDShouldDraw( name )

	// list of disabled elements
	local disabled = {
		"CHudHealth",
		"CHudBattery",
		"CHudAmmo",
		"CHudSecondaryAmmo",
//		"CHudWeaponSelection",
		""
	};
	
	// check if disabled
	if ( table.HasValue( disabled, name ) ) then
	
		// dont draw
		return false;
		
	end
	
	// draw
	return true;

end


/*------------------------------------
	HUDPaint
------------------------------------*/
function GM:HUDPaint( )

	// get LocalPlayer
	local LP = LocalPlayer();
	
	// calculate screen scale
	local xscale = ScrW() / 1024;
	local yscale = ScrH() / 768;
	
	// validate
	if ( LP:Alive() && !LP:IsSpectating() ) then
	
		// get aim controller
		local aim = LP:GetAimController();
	
		// validate aim controller
		if ( ValidEntity( aim ) ) then
		
			// let it draw
			aim:HUDPaint( LP, xscale, yscale );
			
		end
		
	end
	
	// base
	self.BaseClass:HUDPaint();
	
	// default alpha
	LP.DeathFadeAlpha = LP.DeathFadeAlpha or 0;
	
	// calculate delta & alpha
	local delta = ( !LP:Alive() ) && ( FrameTime() * 100 ) || ( FrameTime() * -130 );
	LP.DeathFadeAlpha = math.Clamp( LP.DeathFadeAlpha + delta, 0, 255 );
	
	// check for any alpha
	if ( LP.DeathFadeAlpha > 0 ) then
	
		// fade the screen
		draw.RoundedBox(
			0, // border
			0, 0, // top left
			ScrW(), ScrH(), // bottom right
			Color( 0, 0, 0, LP.DeathFadeAlpha )
		);
		
	end
	
	// round related stuff
	self:HUDPaintRound( xscale, yscale );
	
	// health
	self:DrawBooty( LP, xscale, yscale );
	
	// check for player
	if ( !LP:IsSpectating() ) then
	
		// alive
		if ( LP:Alive() ) then
		
			// health
			self:DrawVitals( LP, xscale, yscale );
		
			// loadout
			self:DrawLoadout( LP, xscale, yscale );
			
			if ( LP:GetViewMode() == VIEWMODE_TOPDOWN ) then
			
				// radar
				self:DrawRadar( LP );
				
			end
			
		end
		
	else
	
		if ( LP:GetGameClass() == CLASS_CIVILIAN ) then
		
			// draw text
			draw.SimpleTextOutlined(
				"Press F2 to select class", // text
				"ZahmbeezHUD", // font
				ScrW() * 0.5, // x position
				ScrH() * 0.9, // y position
				Color( 200, 200, 200, 200 ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
				3, // border size
				Color( 0, 0, 0, 60 ) // border color
			);
			
		end
		
	end
	
	// motion text
	self:DrawMotionText();
	
end


/*------------------------------------
	DrawMotionText
------------------------------------*/
function GM:DrawMotionText( )

	// loop through motion text
	for index, mt in pairs( MotionText ) do
	
		// text is alive
		if ( mt.DieTime == -1 || mt.DieTime > CurTime() ) then
		
			// animate
			mt.SpreadX = math.Clamp( mt.SpreadX - ( 5 * ( FrameTime() * 450 ) ), 0, 99999 );
			
			// we've hit center, time to die
			if ( mt.SpreadX == 0 && mt.DieTime == -1 ) then
			
				// live for specified time
				mt.DieTime = CurTime() + mt.Life;
				
			end
			
			// adjust modifier depending on what side
			local modifier = ( mt.IsLeft ) && -1 || 1;
			
			// calculate x position
			local xpos = ( ScrW() * 0.5 ) + ( modifier * mt.SpreadX );
			
			// draw shadow
			draw.SimpleText(
				mt.Text, // text
				"ZahmbeezMotionText", // font
				xpos + 2, // x position
				( ScrH() * 0.3 ) + 2, // y position
				Color( 0, 0, 0, mt.Alpha * 0.3 ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER // alignment
			);
			
			// draw shadow
			draw.SimpleText(
				mt.Text, // text
				"ZahmbeezMotionText", // font
				xpos - 2, // x position
				( ScrH() * 0.3 ) + 2, // y position
				Color( 0, 0, 0, mt.Alpha * 0.3 ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER // alignment
			);
			
			// generate color
			local c = 200 + math.cos( CurTime() * 10 ) * 30;
			
			// draw text
			draw.SimpleText(
				mt.Text, // text
				"ZahmbeezMotionText", // font
				xpos, // x position
				ScrH() * 0.3, // y position
				Color( c, c, c, mt.Alpha ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER // alignment
			);
			
		else
		
			// delete it
			MotionText[ index ] = nil;
		
		end
	
	end

end


/*------------------------------------
	AddMotionText
------------------------------------*/
function GM:AddMotionText( text )

	// clear any text
	MotionText = {};

	// create a new motion text
	local function SingleMotionText( text, left, x, alpha, life )
	
		// build table
		return {
		
			[ 'Text' ] = text,
			[ 'IsLeft' ] = left,
			[ 'SpreadX' ] = x,
			[ 'DieTime' ] = -1,
			[ 'Alpha' ] = alpha,
			[ 'Life' ] = life
		
		};
	
	end
	
	// starting x offset
	local xoffset = ScrW() * 0.5;
	
	// FIXED! This has to be done backwards. The lightest faded part first
	// then all the way up to the primary text last
	
	// slow fade out
	for i = 40, 160, 20 do
	
		// adjust offset
		xoffset = xoffset + 30;
		
		// add additional text
		MotionText[ #MotionText + 1 ] = SingleMotionText( text, true, xoffset, i, 0 );
		MotionText[ #MotionText + 1 ] = SingleMotionText( text, false, xoffset, i, 0 );
	
	end
	
	// add primary text
	MotionText[ #MotionText + 1 ] = SingleMotionText( text, true, xoffset, 200, 3 );
	MotionText[ #MotionText + 1 ] = SingleMotionText( text, false, xoffset, 200, 3 );
	
end


/*------------------------------------
	GetZahmbeezMotionText
------------------------------------*/
local function GetZahmbeezMotionText( um )

	// get text string
	local text = um:ReadString();
	
	// add it
	GAMEMODE:AddMotionText( text );

end

// hook
usermessage.Hook( "ZahmbeezMotionText", GetZahmbeezMotionText );


/*------------------------------------
	DrawBooty
------------------------------------*/
function GM:DrawBooty( LP, xscale, yscale )

	// set draw color
	surface.SetDrawColor(  255, 255, 255, 150 );
	
	// set material
	surface.SetMaterial( matBooty );
	
	// scale
	local width = 40 * xscale;
	local height = 40 * yscale;
	
	// draw material
	surface.DrawTexturedRect( 10, 10, width, height );
	
	// draw text
	draw.SimpleTextOutlined(
		"$" .. LP:GetBooty(), // text
		"ZahmbeezHUD", // font
		10 + ( 45 * xscale ), // x position
		10 + ( 20 * yscale ), // y position
		Color( 200, 200, 200, 200 ), // font color
		TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, // alignment
		3, // border size
		Color( 0, 0, 0, 60 ) // border color
	);
	
end


/*------------------------------------
	DrawVitals
------------------------------------*/
function GM:DrawVitals( LP, xscale, yscale )

	// set draw color
	surface.SetDrawColor( 255, 255, 255, 150 );
	
	// set material
	surface.SetMaterial( matBG1 );
	
	// scale
	local width = 195 * xscale;
	local height = 100 * yscale;
	
	// draw material
	surface.DrawTexturedRect( 10, ScrH() - 5 - ( height ), width, height );

	// set draw color
	surface.SetDrawColor( 255, 255, 255, 160 );
	
	// set material
	surface.SetMaterial( matHeart );
	
	// scale
	width = 55 * xscale;
	height = 80 * yscale;
	
	// draw material
	surface.DrawTexturedRect( 10 + ( 10 * xscale ), ScrH() - ( 5 + 10 * yscale ) - ( height ), width, height );
	
	// determine color
	local fcolor = ( LP:Health() > 25 ) && Color( 200, 200, 200, 200 ) || Color( 200 + math.cos( CurTime() * 5 ) * 20, 50, 50, 200 );
	
	// poisoned?
	if ( LP:GetPoisonTime() > CurTime() ) then
	
		// set font color
		fcolor = Color( 20, 200 + math.cos( CurTime() * 5 ) * 20, 20, 200 );
	
	end
	
	// draw text
	draw.SimpleTextOutlined(
		LP:Health() .. "hp", // text
		"ZahmbeezHUD", // font
		10 + ( 35 * xscale ), // x position
		ScrH() - ( 50 * yscale ), // y position
		fcolor, // font color
		TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, // alignment
		3, // border size
		Color( 0, 0, 0, 60 ) // border color
	);
	
	// set draw color
	surface.SetDrawColor( 255, 255, 255, 130 );
	
	// set material
	surface.SetMaterial( matBrain );
	
	// scale
	width = 90 * xscale;
	height = 65 * yscale;
	
	// draw material
	surface.DrawTexturedRect( 10 + ( 90 * xscale ), ScrH() - ( 5 + 20 * yscale ) - ( height ), width, height );
	
	// determine color
	fcolor = ( LP:GetSanity() > 25 ) && Color( 200, 200, 200, 200 ) || Color( 200 + math.cos( CurTime() * 5 ) * 20, 50, 50, 200 );
	
	// frozen?
	if ( LP:GetFrozenTime() > CurTime() ) then
	
		// set font color
		fcolor = Color( 100, 100, 200 + math.cos( CurTime() * 5 ) * 20, 200 );
	
	end
	
	// draw text
	draw.SimpleTextOutlined(
		LP:GetSanity() .. "%", // text
		"ZahmbeezHUD", // font
		10 + ( 135 * xscale ), // x position
		ScrH() - ( 50 * yscale ), // y position
		fcolor, // font color
		TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, // alignment
		3, // border size
		Color( 0, 0, 0, 60 ) // border color
	);
		
end


/*------------------------------------
	DrawLoadout
------------------------------------*/
function GM:DrawLoadout( LP, xscale, yscale )

	// set draw color
	surface.SetDrawColor( 255, 255, 255, 150 );
	
	// set material
	surface.SetMaterial( matBG2 );
	
	// scale
	local width = 195 * xscale;
	local height = 100 * yscale;
	
	// draw material
	surface.DrawTexturedRect( ScrW() - 10 - width, ScrH() - 5 - ( height ), width, height );
	
	// set draw color
	surface.SetDrawColor( 255, 255, 255, 160 );
	
	// set material
	surface.SetMaterial( matAmmo );
	
	// scale
	width = 50 * xscale;
	height = 95 * yscale;
	
	// draw material
	surface.DrawTexturedRect( ScrW() - 10 - ( 175 * xscale ), ScrH() - ( 10 * yscale ) - ( height ), width, height );
	
	// get weapon
	local weapon = LP:GetActiveWeapon();
	
	// validate weapon
	if ( ValidEntity( weapon ) && weapon:IsWeapon() ) then
		
		local weaptext = weapon.PrintName or weapon:GetPrintName();
	
		// draw text
		draw.SimpleTextOutlined(
			weaptext, // text
			"ZahmbeezHUDSmall", // font
			ScrW() - 10 - ( 100 * xscale ), // x position
			ScrH() - ( 113 * yscale ), // y position
			Color( 200, 200, 200, 200 ), // font color
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
			2, // border size
			Color( 0, 0, 0, 60 ) // border color
		);
			
		// vertical position
		local ypos = ScrH() - ( 70 * yscale );
	
		// get primary clip count
		local clip1 = weapon:GetAmmoClip1();
		
		// validate
		if ( clip1 > -1 ) then
		
			// get primary ammo count
			local clip1max = weapon:GetAmmo1();
		
			// draw text
			draw.SimpleTextOutlined(
				clip1 .. "/" .. clip1max, // text
				"ZahmbeezHUD", // font
				ScrW() - 10 - ( 120 * xscale ), // x position
				ypos, // y position
				Color( 200, 200, 200, 200 ), // font color
				TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, // alignment
				3, // border size
				Color( 0, 0, 0, 60 ) // border color
			);
			
			// move the vertical position
			ypos = ScrH() - ( 35 * yscale );
			
		end
		
		// get secondary clip count
		local clip2 = weapon:GetAmmoClip2();
		
		// validate secondary ammo
		if ( clip2 > -1 ) then
		
			// draw text
			draw.SimpleTextOutlined(
				clip2, // text
				"ZahmbeezHUD", // font
				ScrW() - 10 - ( 85 * xscale ), // x position
				ypos, // y position
				Color( 200, 200, 200, 200 ), // font color
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
				3, // border size
				Color( 0, 0, 0, 60 ) // border color
			);
			
		end
	
	end
		
end


/*------------------------------------
	DrawLoadout
------------------------------------*/
function GM:DrawLoadout2( LP, xscale, yscale )

	// set draw color
	surface.SetDrawColor( 255, 255, 255, 150 );
	
	// set material
	surface.SetMaterial( matBG2 );
	
	// scale
	local width = 195 * xscale;
	local height = 100 * yscale;
	
	// draw material
	surface.DrawTexturedRect( ScrW() - 10 - width, ScrH() - 5 - ( height ), width, height );
	
	// set draw color
	surface.SetDrawColor( 255, 255, 255, 160 );
	
	// set material
	surface.SetMaterial( matAmmo );
	
	// scale
	width = 50 * xscale;
	height = 95 * yscale;
	
	// draw material
	surface.DrawTexturedRect( ScrW() - 10 - ( 175 * xscale ), ScrH() - ( 10 * yscale ) - ( height ), width, height );
	
	// get weapon
	local weapon = LP:GetActiveWeapon();
	
	// validate weapon
	if ( ValidEntity( weapon ) && weapon:IsWeapon() ) then
	
		// get name
		local weaptext = weapon.PrintName or weapon:GetPrintName();
	
		// draw text
		draw.SimpleTextOutlined(
			weaptext, // text
			"ZahmbeezHUDSmall", // font
			ScrW() - 10 - ( 100 * xscale ), // x position
			ScrH() - ( 113 * yscale ), // y position
			Color( 200, 200, 200, 200 ), // font color
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
			2, // border size
			Color( 0, 0, 0, 60 ) // border color
		);
			
		// vertical position
		local ypos = ScrH() - ( 70 * yscale );
	
		// get primary clip count
		local clip1 = weapon:Clip1();
		
		// validate
		if ( clip1 > -1 ) then
		
			// get primary ammo count
			local clip1max = LP:GetAmmoCount( weapon:GetPrimaryAmmoType() );
		
			// draw text
			draw.SimpleTextOutlined(
				clip1 .. "/" .. clip1max, // text
				"ZahmbeezHUD", // font
				ScrW() - 10 - ( 120 * xscale ), // x position
				ypos, // y position
				Color( 200, 200, 200, 200 ), // font color
				TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, // alignment
				3, // border size
				Color( 0, 0, 0, 60 ) // border color
			);
			
			// move the vertical position
			ypos = ScrH() - ( 35 * yscale );
			
		end
		
	end
		
end


/*------------------------------------
	DrawRadar
------------------------------------*/
function GM:DrawRadar( LP )

	// check for update
	if ( !RadarEntities || CurTime() > NextRadarRefresh ) then
	
		// clear
		RadarEntities = {};
		
		// delay
		NextRadarRefresh = CurTime() + 1;
	
		// get all entities
		local entlist = ents.GetAll();
		
		// loop list
		for _, ent in pairs( entlist ) do
		
			// get class and radar type
			local class = ent:GetClass();
			local radartype = ent:GetRadarType();
			
			// validate
			if ( radartype > RADAR_NONE || table.HasValue( ZombieClasses, class ) ) then
			
				// default to enemy
				if ( radartype == RADAR_NONE ) then
				
					// store
					ent:SetRadarType( RADAR_ENEMY );
					
				end
				
				// add to list
				RadarEntities[ #RadarEntities + 1 ] = ent;
			
			end
		
		end
	
	end
	
	// loop ents
	for _, ent in pairs( RadarEntities ) do
	
		// validate
		if ( ValidEntity( ent ) && ent != LP ) then
		
			// get aiming direction
			local dir = LP:GetAimVector();
			
			// dot product
			local dot = ( LP:GetPos() - ent:GetPos() ):Normalize():DotProduct( dir );
			
			if ( dot <= 0 ) then
			
				// get radar type
				local radartype = ent:GetRadarType();
		
				// get position
				local pos = ent:GetPos():ToScreen();
				
				// calculate size
				local size = ( ent:BoundingRadius() * 1.3 ) + ( math.sin( CurTime() * 8 ) * 3 );
				
				// set material and color		
				surface.SetMaterial( RadarMaterials[ radartype ] );
				surface.SetDrawColor( 255, 255, 255, 150 );
				
				// draw the icon
				surface.DrawTexturedRectRotated( pos.x, pos.y, size, size, ent:GetAngles().y );
				
				// vars
				local textpos, text;
				
				// check friendly
				if ( radartype == RADAR_FRIENDLY ) then
				
					// show name
					textpos = ( ent:GetPos() + Vector( 0, 0, ent:BoundingRadius() ) ):ToScreen();
					text = ( ent.Name ) && ent:Name() || "Citizen";
					
				// check objective
				elseif ( radartype == RADAR_OBJECTIVE ) then
				
					// show type
					textpos = ( ent:GetPos() + Vector( 0, 0, ent:BoundingRadius() ) ):ToScreen();
					text = ent.PrintName;
				
				end
				
				// confirm
				if ( text && textpos ) then
				
					// draw text
					draw.SimpleTextOutlined(
						text, // text
						"ZahmbeezTarget", // font
						textpos.x, // x position
						textpos.y, // y position
						Color( 200, 200, 200, 200 ), // font color
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, // alignment
						2, // border size
						Color( 0, 0, 0, 60 ) // border color
					);
					
				end
				
				// check for radar paint
				if ( ent.RadarPaint ) then
				
					// call it
					ent:RadarPaint( LP );
				
				end
				
			end
		
		end
		
	end

end
