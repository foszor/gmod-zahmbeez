
// shared file
include( 'shared.lua' );


/*------------------------------------
	Init
------------------------------------*/
function ENT:Initialize( )

	// fade brushes
	self.FadeBrushes = {};
	self.GotFadeBrushes = false;
	
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )

end


/*------------------------------------
	GetZahmbeezFadeBrushes
------------------------------------*/
local function GetZahmbeezFadeBrushes( um, brushes )
	
	// check if we've read the message
	if ( !brushes ) then
	
		// empty table
		brushes = {};
	
		// read the total amount
		local amt = um:ReadShort();
		
		// loop for each brush
		for i = 1, amt do
		
			// get brush
			local ent = um:ReadEntity();
			
			// validate
			if ( ent:IsValid() ) then
			
				// get color
				local color = { ent:GetColor() };
				
				// set starting alpha
				ent:SetColor( color[ 1 ], color[ 2 ], color[ 3 ], 255 );
				
				// store it
				brushes[ ent:EntIndex() ] = {
				
					[ 'Brush' ] = ent,
					[ 'LastTouched' ] = 0
					
				};
				
			end
		
		end
		
	end
	
	// get the view controller
	local vc = LocalPlayer():GetViewController();
	
	// validate
	if ( !ValidEntity( vc ) ) then
	
		// delay and try again
		timer.Simple( 1, GetZahmbeezFadeBrushes, 0, brushes );
		return;
	
	end
	
	// save
	vc.GotFadeBrushes = true;
	vc.FadeBrushes = brushes;

end

// hook
usermessage.Hook( "ZahmbeezFadeBrushes", GetZahmbeezFadeBrushes );


/*------------------------------------
	DoFading
------------------------------------*/
function ENT:DoFading( )

	// variables
	local delay = 0.5;
	local speed = 10;
	local lowalpha = 20;
	
	// loop list
	for _ , brush in pairs( self.FadeBrushes ) do
	
		// calculate fade direction
		local modifier = ( CurTime() - brush.LastTouched < delay ) && -1 || 1;
		
		// get color
		local color = { brush.Brush:GetColor() };
		
		// calculate new alpha
		local newalpha = math.Clamp( color[ 4 ] + ( ( speed * FrameTime() * 40 ) * modifier ), lowalpha, 255 );
		
		// round alpha
		newalpha = tonumber( ( "%.0f" ):format( newalpha ) );
		
		// update alpha if needed
		if ( newalpha != color[4] ) then
		
			// change it
			brush.Brush:SetColor( color[ 1 ], color[ 2 ], color[ 3 ], newalpha );
			
		end
		
	end
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// update
	self.Player = self.Entity:GetOwner();
	
	// validate
	if ( !self.Player || !self.Player:IsValid() ) then
	
		return;
		
	end
	
	// get LocalPlayer
	local LP = LocalPlayer();
	
	// think locally only
	if ( self.Player != LP ) then
	
		return;
		
	end
	
	// fix invisible bug
	if ( LP:IsSpectating() && LP:GetMaterial() != "" ) then
	
		// make visible
		LP:SetMaterial( "" );
		LP:SetRenderMode( RENDERMODE_NORMAL );
		LP:SetColor( 255, 255, 255, 255 );
		LP:SetNoDraw( false );
	
	end
	
	// do tracking
	self:TrackPlayer( LP );
	
	if ( self.GotFadeBrushes ) then
	
		// alive?
		if ( LP:Alive() && !LP:IsSpectating() ) then
	
			// build trace
			local trace = {};
			trace.start = self.Entity:GetPos();
			trace.endpos = LP:GetPos() + Vector( 0, 0, 72 );
			trace.filter = LP;
			local tr = util.TraceLine( trace );
			
			// fading brush?
			if ( ValidEntity( tr.Entity ) && self.FadeBrushes[ tr.Entity:EntIndex() ] ) then
				
				// touch it (sounds kinky)
				self.FadeBrushes[ tr.Entity:EntIndex() ].LastTouched = CurTime();
			
			end
			
		end
		
		// fade
		self:DoFading();
		
	end
	
	// think fast
	self.Entity:NextThink( CurTime() + 0.1 );
	return true;
	
end


/*------------------------------------
	TranslatePosition
------------------------------------*/
function ENT:TranslatePosition( pl, base, offset )

	if ( !offset ) then
	
		return base;
		
	end

	// get angle and level it out
	local angles = pl:GetAimVector():Angle();
	angles.Pitch = 0;
	
	// move up
	local viewpos = base + Vector( 0, 0, offset.z );
	
	// move forward
	viewpos = viewpos + ( angles:Forward() * offset.x );
	
	// move sideways
	viewpos = viewpos + ( angles:Right() * offset.y );
	
	// return value
	return viewpos;
	
end


/*------------------------------------
	TrackPlayer
------------------------------------*/
function ENT:TrackPlayer( pl )
	
	// view offset vectors
	local ViewOffsets = {
	
		[ VIEWMODE_TOPDOWN ] = Vector( -90, 0, 280 ),
		[ VIEWMODE_SHOLDER ] = Vector( -30, 20, 10 ),
		[ 'Spectator' ] = Vector( -25, 0, -40 )
	
	};
	
	// check for spectator
	if ( pl:IsSpectating() ) then
	
		// get position
		local pos = pl:GetShootPos();
		local viewpos = self:TranslatePosition( pl, pos, ViewOffsets[ 'Spectator' ] );
		
		// set position & angle
		self.Entity:SetPos( viewpos );
		self.Entity:SetAngles( pl:GetAimVector():Angle() );
		return;
	
	end
	
	// get viewmode
	local viewmode = pl:GetViewMode();
	
	// defaults
	self.LastViewMode = self.LastViewMode or viewmode;
	self.LastChangeTime = self.LastChangeTime or 0;
	local viewoffset = Vector( 0, 0, 0 );
	local percent = 1;
	
	// check for changes
	if ( self.LastViewMode != viewmode ) then
	
		// update
		self.LastChangeTime = CurTime();
		self.LastViewMode = viewmode;
	
	end
	
	// how fast to change (in seconds)
	local speed = 0.65;
	
	// get difference in time
	local diff = CurTime() - self.LastChangeTime;
	
	// check if we should lerp
	if ( diff < speed ) then
	
		// calculate percent
		percent = diff / speed;
		
		// figure out positions
		local startpos = ( viewmode == VIEWMODE_TOPDOWN ) && ViewOffsets[ VIEWMODE_SHOLDER ] || ViewOffsets[ VIEWMODE_TOPDOWN ];
		local endpos = ( viewmode == VIEWMODE_TOPDOWN ) && ViewOffsets[ VIEWMODE_TOPDOWN ] || ViewOffsets[ VIEWMODE_SHOLDER ];
		
		// do lerping
		viewoffset = LerpVector( percent, startpos, endpos );
		
	else
	
		// straight to position
		viewoffset = ViewOffsets[ viewmode ];
	
	end
	
	// get angle and level it out
	local angles = pl:GetAimVector():Angle();
	angles.Pitch = 0;
	
	// translate
	local basepos = pl:GetShootPos();
	local viewpos = self:TranslatePosition( pl, basepos, viewoffset );
	
	// bobing scale based on speed
	local speed = pl:GetVelocity():Length();
	local scale = speed / 200;
			
	// set view angle and bobing
	/* NOTE: we have to handling view bobing separately because
	   what looks good in over-the-shoulder view looks like ass
	   in top-down view */
	if ( pl:IsSpectating() ) then
	
		if ( pl:Alive() ) then
		
			// use players aim
			viewang = pl:GetAimVector():Angle();
			
		else
		
			// face player
			viewang = ( basepos - viewpos ):Normalize();
			viewang = viewang:Angle();
		
		end
		
	else
	
		if ( pl:GetViewMode() == VIEWMODE_TOPDOWN ) then
		
			// face player
			viewang = ( basepos - viewpos ):Normalize();
			viewang = viewang:Angle();
			
			// add bobing
			if ( pl:OnGround() ) then
				
				// do bobing
				viewang.roll = viewang.roll + ( scale * 0.8 ) * math.sin( CurTime() * 10 );
				viewpos.z = viewpos.z + ( scale * 1.8 ) * math.cos( CurTime() * 20 );
				
			end
			
		else
		
			if ( percent != 1 ) then
			
				// build trace
				local trace = {};
				trace.start = basepos;
				trace.endpos = trace.start + ( pl:GetAimVector() * 1024 );
				trace.filter = self.Player;
				
				// run it
				local tr = util.TraceLine( trace );
				
				// get the position
				local diff = ( tr.HitPos - trace.start );
				local dir = diff:GetNormal();
				local dist = diff:Length();
				local pos = trace.start + ( dir * ( dist * percent ) );
				
				// face position
				viewang = ( pos - viewpos ):Normalize();
				viewang = viewang:Angle();
			
			else
		
				// use player view
				viewang = pl:GetAimVector():Angle();
				
			end
			
			// add bobing
			if ( pl:OnGround() ) then
				
				// do bobing
				viewang.pitch = viewang.pitch + ( scale * 0.8 ) * math.sin( CurTime() * 18 );
				viewang.roll = viewang.roll + ( scale * 1 ) * math.cos( CurTime() * 18 );
				
			end
			
			// avoid going through walls
			if ( percent == 1 ) then
			
				// build trace
				local trace = {};
				trace.start = basepos;
				trace.endpos = viewpos;
				trace.filter = self.Player;
				
				// run it
				local tr = util.TraceLine( trace );
				
				// update view
				viewpos = ( tr.Fraction == 1 ) && tr.HitPos || tr.HitPos - tr.Normal * 5;
				
				// clamp it
				viewang.p = ( viewang.p > 180 ) && math.max( viewang.p, 340 ) || math.min( viewang.p, 30 );
				
			end
			
		end
	
	end
	
	// set position and angle
	self.Entity:SetPos( viewpos );
	self.Entity:SetAngles( viewang );

end


/*------------------------------------
	PlayerBindPress
------------------------------------*/
local function PlayerBindPress( pl, bind, pressed )

	// players
	if ( !pl:IsSpectating() ) then
	
		// check for zoom button
		if ( bind:find( "+zoom" ) && pressed ) then
		
			// get sound
			local sound = ( pl:GetViewMode() == VIEWMODE_TOPDOWN ) && Sound( "ambient/levels/citadel/pod_close1.wav" ) || Sound( "ambient/levels/citadel/pod_open1.wav" );
			
			// play it
			surface.PlaySound( sound );
		
			// run command
			RunConsoleCommand( "zahmbeez_viewmode" );
		
			// override
			return true;
			
		end
		
	else
	
		// spectators cant duck
		if ( bind:find( "+duck" ) ) then
		
			// override	
			return true;
		
		// cant zoom
		elseif ( bind:find( "+zoom" ) ) then
		
			// override	
			return true;
	
		end
	
	end

end

// hook
hook.Add( "PlayerBindPress", "ViewController_PlayerBindPress", PlayerBindPress );
