
// get metatable.
local meta = FindMetaTable( "Player" );
if ( !meta ) then return; end


/*------------------------------------
	Think
------------------------------------*/
function meta:Think( )

	// check for player
	if ( !self:IsSpectating() ) then
	
		// check alive
		if ( self:Alive() ) then
		
			// get weapon
			local weapon = self:GetActiveWeapon();
			
			// validate
			if ( ( ValidEntity( weapon ) && weapon:IsWeapon() ) ) then
			
				// check for world entity
				if ( !ValidEntity( weapon.WorldEntity ) ) then
				
					// find matching weapons
					local weaps = ents.FindByClass( weapon:GetClass() );
					
					// cycle weapons
					for _, weap in pairs( weaps ) do
					
						// check for ownership
						if ( weap:GetOwner() == LocalPlayer() ) then
						
							// save
							weapon.WorldEntity = weap;
						
						end
					
					end
					
				else
				
					// get attachment
					local attachment = weapon:GetAttachment( weapon:LookupAttachment( "muzzle" ) );
				
					// save position
					weapon.MuzzlePosition = ( attachment ) && attachment.Pos || self:GetShootPos();
					
				end
				
			end
		
		end
		
	end

end
