
// round information storage
GM.RoundState = ROUND_WAITING;
GM.RoundStateTimeout = 0;

// materials
local matTimer = Material( "zahmbeez/hud/timer" );


/*------------------------------------
	GetZahmbeezRoundInfo
------------------------------------*/
local function GetZahmbeezRoundInfo( um )

	// read the info
	local zahmode = um:ReadString();
	GAMEMODE.RoundState = um:ReadLong();
	GAMEMODE.RoundStateTimeout = um:ReadLong();
	
	// see if we need to start the zahmode
	if ( GAMEMODE.CurrentZahmode != zahmode ) then
	
		// start
		GAMEMODE:StartZahmode( zahmode );
	
	end
	
	// start of rounds, clear decals
	if ( GAMEMODE.RoundState == ROUND_INTRO ) then
	
		// run command
		RunConsoleCommand( "r_cleardecals" );
	
	end
			
end

// hook
usermessage.Hook( "ZahmbeezRoundInfo", GetZahmbeezRoundInfo );


/*------------------------------------
	HUDPaintRound
------------------------------------*/
function GM:HUDPaintRound( xscale, yscale )
		
	// set material
	surface.SetMaterial( matTimer );
		
	// size
	width = 40 * xscale;
	height = 40 * yscale;
	
	// position
	local xpos = ScrW() * 0.5;
	local ypos = 13 + ( height * 0.5 );
	
	// background color
	local bgcolor = Color( 0, 0, 0, 170 );
	
	// set draw color
	surface.SetDrawColor( bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a );
	
	// draw material
	surface.DrawTexturedRectRotated( xpos, ypos, width * 1.1, height * 1.1 );
	
	// set draw color
	surface.SetDrawColor( 255, 255, 255, 255 );
	
	// draw material
	surface.DrawTexturedRectRotated( xpos, ypos, width, height, 0 );
	
	// calculate time
	local remaining = math.Clamp( self.RoundStateTimeout - CurTime(), 0, 999999 );
	
	// draw text
	draw.SimpleTextOutlined(
		string.ToMinutesSeconds( remaining ),
		"ZahmbeezHUD",
		xpos,
		ypos + ( height * 0.6 ),
		Color( 200, 200, 200, 200 ), 
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
		2,
		bgcolor
	);
	
end


/*------------------------------------
	RoundThink
------------------------------------*/
function GM:RoundThink( )
	
	// let ze zahmode think!
	hook.Call( "Think", GAMEMODE.CurrentZahmodeTable or {} );
	
end
