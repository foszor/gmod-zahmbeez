

//---------- Info
SWEP.PrintName			= "Zahmbeez Base Weapon";
SWEP.Slot				= 3;
SWEP.SlotPos			= 6;
SWEP.Spawnable			= false;
SWEP.AdminSpawnable		= false;
SWEP.Secondary			= nil;
SWEP.Primary			= nil;

/*------------------------------------
	Precache
------------------------------------*/
function SWEP:Precache( )
end

/*------------------------------------
	Initialize
------------------------------------*/
function SWEP:Initialize( )

	// set some server stuff
	if( SERVER ) then
	
		// holdtype
		self:SetWeaponHoldType( "smg" );
		
		// set default primary ammo
		if( self.Primary && self.Primary.Ammo && self.Primary.DefaultClip != -1 ) then
		
			self:SetAmmo( self.Primary.Ammo, self.Primary.DefaultClip );
		
		end
		
		// set default secondary ammo
		if( self.Secondary && self.Secondary.Ammo && self.Secondary.DefaultClip != -1 ) then
		
			self:SetAmmo( self.Secondary.Ammo, self.Secondary.DefaultClip );
		
		end
	
	end
	
	// last reload
	self.LastReload = CurTime();

end

/*------------------------------------
	Think
------------------------------------*/
function SWEP:Think( )

end

/*------------------------------------
	SetAmmo
------------------------------------*/
function SWEP:SetAmmo( ammo, amt )

	self.Weapon:SetNetworkedInt( "ammo_" .. ammo, amt );

end

/*------------------------------------
	GetAmmo
------------------------------------*/
function SWEP:GetAmmo( ammo )

	return self.Weapon:GetNetworkedInt( "ammo_" .. ammo );

end

/*------------------------------------
	OnRemove
------------------------------------*/
function SWEP:OnRemove( )
end

/*------------------------------------
	OwnerChanged
------------------------------------*/
function SWEP:OwnerChanged( )
end

/*------------------------------------
	OnRestore
------------------------------------*/
function SWEP:OnRestore( )
end

/*------------------------------------
	PrimaryAttack
------------------------------------*/
function SWEP:PrimaryAttack( )
end

/*------------------------------------
	SecondaryAttack
------------------------------------*/
function SWEP:SecondaryAttack( )
end

/*------------------------------------
	Reload
------------------------------------*/
function SWEP:Reload( )

	local reloaded = false;

	// should reload?
	if( self.LastReload > CurTime() ) then return reloaded; end
	self.LastReload = CurTime() + ( self.Primary.ReloadTime or 0 );
	
	// reload primary
	if( self.Primary && self.Primary.Ammo && self.Primary.ClipSize != -1 ) then
	
		local available = self.Owner:GetCustomAmmo( self.Primary.Ammo );
		local ammo = self:GetAmmo( self.Primary.Ammo );
	
		// do we have any ammo available to put into this?
		if( ammo < self.Primary.ClipSize && available > 0 ) then
		
			// how much ammo do we need
			local needs = math.min( self.Primary.ClipSize - ammo, available );
			local add = math.max( 0, needs );
			
			// remove the ammo from the players bag.
			self.Owner:AddCustomAmmo( self.Primary.Ammo, -add );
			
			// add the ammo to our clip
			self:SetAmmo( self.Primary.Ammo, self:GetAmmo( self.Primary.Ammo ) + add );
			
			// flag
			reloaded = true;
			
			if ( self.Primary.ReloadTime ) then
			
				// don't fire
				self:SetNextPrimaryFire( CurTime() + ( self.Primary.ReloadTime or 0 ) );
				
				// animation
				self.Weapon:SendWeaponAnim( ACT_VM_RELOAD );
				self.Owner:SetAnimation( PLAYER_RELOAD );
				
			end
		
		end
	
	end
	
	// reload secondary
	if( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize != -1 ) then
	
		local available = self.Owner:GetCustomAmmo( self.Secondary.Ammo );
		local ammo = self:GetAmmo( self.Secondary.Ammo );
	
		// do we have any ammo available to put into this?
		if( ammo < self.Secondary.ClipSize && available > 0 ) then
		
			// figure out how much ammo to add
			local needs = math.min( self.Secondary.ClipSize - ammo, available );
			local add = math.max( 0, needs );
			
			// remove the ammo from the players bag.
			self.Owner:AddCustomAmmo( self.Secondary.Ammo, -add );
			
			// add the ammo to our clip
			self:SetAmmo( self.Secondary.Ammo, self:GetAmmo( self.Secondary.Ammo ) + add );
			
			if ( self.Secondary.ReloadTime ) then
			
				// don't fire
				self:SetNextSecondaryFire( CurTime() + ( self.Secondary.ReloadTime or 0 ) );
				
			end
			
			// flag
			reloaded = true;
		
		end
	
	end

	return reloaded;

end

/*------------------------------------
	Holster
------------------------------------*/
function SWEP:Holster( wep )

	return true;

end

/*------------------------------------
	AdjustMouseSensitivity
------------------------------------*/
function SWEP:AdjustMouseSensitivity( )

	return -1;

end

/*------------------------------------
	Deploy
------------------------------------*/
function SWEP:Deploy( )
	
	// have primary fire?
	if( self.Primary ) then
	
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay || 0.25 );
	
	end
	
	// have secondary fire?
	if( self.Secondary ) then
	
		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay || 0.25 );
	
	end
	
	return true;

end

/*------------------------------------
	CanPrimaryAttack
------------------------------------*/
function SWEP:CanPrimaryAttack( amt )

	amt = amt || 1;

	// have enough ammo?
	if( self.Primary && self.Primary.Ammo && self.Primary.ClipSize != -1 ) then
	
		// enough ammo?
		if( self:GetAmmo( self.Primary.Ammo ) >= amt ) then
		
			return true;
		
		end
		
		// delay firing
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay || 0.2 );
		
	// have direct ammo?
	elseif( self.Primary && self.Primary.Ammo && self.Primary.ClipSize == -1 ) then
	
		// enough ammo?
		if( self.Owner:GetCustomAmmo( self.Primary.Ammo ) >= amt ) then
		
			return true;
		
		end
		
		// delay firing
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay || 0.2 );
		
	// doesn't use ammo
	else
	
		return true;
	
	end
	
	return false;

end

/*------------------------------------
	CanSecondaryAttack
------------------------------------*/
function SWEP:CanSecondaryAttack( amt )

	amt = amt || 1;

	// have enough ammo?
	if( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize != -1 ) then
	
		// enough ammo?
		if( self:GetAmmo( self.Secondary.Ammo ) >= amt ) then
		
			return true;
		
		end
		
		// delay firing
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay || 0.2 );
		
	// have direct ammo?
	elseif( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize == -1 ) then
	
		// enough ammo?
		if( self.Owner:GetCustomAmmo( self.Secondary.Ammo ) >= amt ) then
		
			return true;
		
		end
		
		// delay firing
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay || 0.2 );
	
	// doesn't use ammo
	else
	
		return true;
		
	end
	
	return false;

end

/*------------------------------------
	Ammo1
------------------------------------*/
function SWEP:Ammo1( )

	return self.Owner:GetCustomAmmo( self.Primary.Ammo );

end

/*------------------------------------
	Ammo2
------------------------------------*/
function SWEP:Ammo2( )

	return self.Owner:GetCustomAmmo( self.Secondary.Ammo );

end

/*------------------------------------
	GetAmmo1
------------------------------------*/
function SWEP:GetAmmo1( )

	return self:Ammo1();

end

/*------------------------------------
	GetAmmo2
------------------------------------*/
function SWEP:GetAmmo2( )

	return self:Ammo2();

end

/*------------------------------------
	GetAmmoClip1
------------------------------------*/
function SWEP:GetAmmoClip1( )

	if( self.Primary && self.Primary.Ammo && self.Primary.ClipSize != -1 ) then

		return self:GetAmmo( self.Primary.Ammo );
		
	end
	
	return -1;

end


/*------------------------------------
	GetAmmoClip2
------------------------------------*/
function SWEP:GetAmmoClip2( )

	if( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize != -1 ) then

		return self:GetAmmo( self.Secondary.Ammo );
		
	end
	
	return -1;

end

/*------------------------------------
	TakePrimaryAmmo
------------------------------------*/
function SWEP:TakePrimaryAmmo( amt )

	// take primary ammo
	if( self.Primary && self.Primary.Ammo && self.Primary.ClipSize != -1 ) then
	
		// take
		self:SetAmmo( self.Primary.Ammo, self:GetAmmo( self.Primary.Ammo ) - amt );
		
	// take direct ammo
	elseif( self.Primary && self.Primary.Ammo && self.Primary.ClipSize == -1 ) then
	
		// take
		self.Owner:AddCustomAmmo( self.Primary.Ammo, -amt );
	
	end

end

/*------------------------------------
	TakeSecondaryAmmo
------------------------------------*/
function SWEP:TakeSecondaryAmmo( amt )

	// take secondary ammo
	if( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize != -1 ) then
	
		// take
		self:SetAmmo( self.Secondary.Ammo, self:GetAmmo( self.Secondary.Ammo ) - amt );
		
	// take direct ammo
	elseif( self.Secondary && self.Secondary.Ammo && self.Secondary.ClipSize == -1 ) then
	
		// take
		self.Owner:AddCustomAmmo( self.Secondary.Ammo, -amt );
	
	end

end

/*------------------------------------
	ContextScreenClick
------------------------------------*/
function SWEP:ContextScreenClick( dir, mousecode, pressed, pl )

end

