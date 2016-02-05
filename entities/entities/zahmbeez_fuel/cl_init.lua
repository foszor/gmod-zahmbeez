
// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )
	
end


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )

	// get courrier
	local courrier = self.Entity:GetCourrier();
	
	// validate
	if( ValidEntity( courrier ) ) then
	
		// update
		self.Entity:SetPos( courrier:GetPos() );
	
	end
		
end


/*------------------------------------
	Draw
------------------------------------*/
function ENT:Draw( )
	
	// get courrier
	local courrier = self.Entity:GetCourrier();

	// validate
	if( ValidEntity( courrier ) && courrier:Alive() ) then
	
		// grab LocalPlayer
		local LP = LocalPlayer();
		
		// check if its us
		if ( courrier == LP ) then
		
			// use this as our courrier so it aligns 
			// with our hand
			courrier = self.Entity:GetCourrierAvatar();
		
		end
		
		// validate again (possibly changed... most likely)
		if ( ValidEntity( courrier ) ) then
	
			// get hand attachment.
			local hand = courrier:LookupAttachment( "anim_attachment_RH" );
		
			// get position & angle.
			local attachment = courrier:GetAttachment( hand );
			
			// no attachment?
			if ( !attachment ) then
			
				// bai?
				return;
				
			end
		
			// get angle
			local ang = attachment.Ang;
			
			// rotate 90 degrees
			ang:RotateAroundAxis( attachment.Ang:Up( ) , -90 );
		
			// update render angles
			self:SetRenderAngles( ang );
		
			// get position
			local pos = attachment.Pos;
			
			// move down and out
			pos = pos + attachment.Ang:Up() * -13;
			pos = pos + attachment.Ang:Right() * 4;
		
			// update render position
			self:SetRenderOrigin( pos );
			
		end
	
	else
	
		// use entity info
		self:SetRenderAngles( self.Entity:GetAngles() );
		self:SetRenderOrigin( self.Entity:GetPos() );
		
	end
	
	// draw
	self:DrawModel();
	
end
