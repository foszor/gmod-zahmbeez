
// shared file
include( 'shared.lua' );


/*------------------------------------
	Init
------------------------------------*/
function ENT:Initialize( )
	
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )

	local LP = LocalPlayer();

	// are we alive?
	if ( !LP:Alive() ) then
	
		// dead men draw no avatars, YARR!!
		return;
	
	elseif ( LP != self.Player ) then
	
		// only draw on local client
		return;
		
	end
	
	// draw
	self:DrawModel();
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// get player
	local pl = self.Entity:GetOwner();
	
	// store player
	self.Player = pl;
	
	// validate
	if ( !ValidEntity( pl ) || !pl:IsPlayer() ) then
	
		// leave
		return;
		
	end
	
	// get LocalPlayer
	local LP = LocalPlayer();
	
	// update
	pl.Avatar = self.Entity;
	
	// get avatar
	local avatar = self.Entity:GetNWEntity( "Avatar" );
	
	// local player?
	if ( pl == LP ) then
		
		// validate avatar
		if ( ValidEntity( avatar ) ) then
		
			// alive only
			if ( LP:Alive() ) then
			
				// grab weapon
				local weap = self.Entity:GetNWEntity( "Weapon" );
				
				// validate
				if ( ValidEntity( weap ) && weap:GetParent() != avatar ) then
				
					// change to avatar
					weap:SetParent( avatar );
				
				end
				
				// check material
				if ( LP:GetMaterial() == "" ) then
				
					// make invisible
					LP:SetRenderMode( RENDERMODE_TRANSALPHA );
					LP:SetColor( 0, 0, 0, 0 );
					LP:SetNoDraw( true );
					LP:SetMaterial( "Models/effects/vol_light001" );
					avatar:SetNoDraw( false );
					
				end
				
			end
			
			// update
			avatar:SetPos( LP:GetPos() );
			avatar:SetAngles( LP:GetAngles() );
		
		end
		
	else
	
		// check material
		if ( ValidEntity( avatar ) && avatar:GetMaterial() == "" ) then
		
			// make invisible
			avatar:SetRenderMode( RENDERMODE_TRANSALPHA );
			avatar:SetColor( 0, 0, 0, 0 );
			avatar:SetNoDraw( true );
			avatar:SetMaterial( "Models/effects/vol_light001" );
		
		end
		
	end
		
	// think fast
	self.Entity:NextThink( CurTime() );
	return true;
	
end
