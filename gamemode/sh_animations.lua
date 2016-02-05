
/*------------------------------------
	UpdateAnimation
------------------------------------*/
function GM:UpdateAnimation( pl )

	// update pose parameters
	if ( pl.Avatar && ( ValidEntity( pl.Avatar.Avatar ) ) && !pl:IsSpectating() ) then
	
		// check client shit
		if ( CLIENT ) then
		
			// only update locally
			if ( pl != LocalPlayer() ) then
			
				return;
				
			end
		
		end
	
		// list of paramesters
		local params = {
			"move_yaw", "aim_yaw", "aim_pitch",
			"body_yaw", "spine_yaw", "neck_trans",
			"head_yaw", "head_pitch", "head_roll",
			"gesture_height", "gesture_width"
		};
		
		// loop list
		for _, pose in pairs( params ) do
		
			// update on avatar
			pl.Avatar.Avatar:SetPoseParameter( pose, pl:GetPoseParameter( pose ) );
			
		end
		
	end
	
end
