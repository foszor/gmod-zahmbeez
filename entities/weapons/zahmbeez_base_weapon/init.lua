
// client files
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

// includes
include( "shared.lua" );

//---------- Info
SWEP.Weight			= 1;
SWEP.AutoSwitchTo		= true;
SWEP.AutoSwitchFrom		= true;

/*------------------------------------
	SetWeaponHoldType
------------------------------------*/
function SWEP:SetWeaponHoldType( hold_type )
	
	// store
	self.HoldType = hold_type;

end


/*------------------------------------
	GetWeaponHoldType
------------------------------------*/
function SWEP:GetWeaponHoldType( )

	// return
	return self.HoldType;

end


/*------------------------------------
	TranslateActivity
------------------------------------*/
function SWEP:TranslateActivity( activity )
	
	// no activity
	return -1;

end

/*------------------------------------
	OnDrop
------------------------------------*/
function SWEP:OnDrop( )

end

/*------------------------------------
	Equip
------------------------------------*/
function SWEP:Equip( pl )

end

/*------------------------------------
	EquipAmmo
------------------------------------*/
function SWEP:EquipAmmo( pl )

end

/*------------------------------------
	AcceptInput
------------------------------------*/
function SWEP:AcceptInput( name, activator, caller, data )

	return true;

end

/*------------------------------------
	KeyValue
------------------------------------*/
function SWEP:KeyValue( key, value )
end

/*------------------------------------
	AmmoUp
------------------------------------*/
function SWEP:AmmoUp( )

	// set default primary ammo
	if( self.Primary && self.Primary.Ammo && self.Primary.DefaultClip != -1 ) then
	
		self:SetAmmo( self.Primary.Ammo, self.Primary.DefaultClip );
		self.Owner:SetCustomAmmo( self.Primary.Ammo, self.Primary.MaxAmmo );
	
	end
	
	// set default secondary ammo
	if( self.Secondary && self.Secondary.Ammo && self.Secondary.DefaultClip != -1 ) then
	
		self:SetAmmo( self.Secondary.Ammo, self.Secondary.DefaultClip );
		self.Owner:SetCustomAmmo( self.Secondary.Ammo, self.Secondary.MaxAmmo );
	
	end
		
end
