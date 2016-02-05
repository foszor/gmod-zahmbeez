
// includes
include( "shared.lua" );

//---------- Info
SWEP.DrawAmmo			= true;
SWEP.DrawCrosshair		= false;
SWEP.ViewModelFOV		= 62;
SWEP.ViewModelFlip		= false;
SWEP.SwayScale			= 1.0;
SWEP.BobScale			= 1.0;

//---------- Materials
local star = Material( "gui/silkicons/star" );

/*------------------------------------
	CustomAmmoDisplay
------------------------------------*/
function SWEP:CustomAmmoDisplay()

	// setup ammo display table
	self.AmmoDisplay = self.AmmoDisplay or {};
	self.AmmoDisplay.Draw = self.DrawAmmo;
	self.AmmoDisplay.PrimaryClip = -1;
	self.AmmoDisplay.PrimaryAmmo = -1;
	self.AmmoDisplay.SecondaryAmmo = -1;
	
	// have primary clip?
	if( self.Primary && self.Primary.Ammo != "" && self.Primary.ClipSize != -1 ) then
	
		self.AmmoDisplay.PrimaryClip = self:GetAmmo( self.Primary.Ammo );
		self.AmmoDisplay.PrimaryAmmo = LocalPlayer():GetCustomAmmo( self.Primary.Ammo );
		
	// have primary ammo?
	elseif( self.Primary && self.Primary.Ammo != "" && self.Primary.ClipSize == -1 ) then
	
		self.AmmoDisplay.PrimaryClip = LocalPlayer():GetCustomAmmo( self.Primary.Ammo );
		self.AmmoDisplay.PrimaryAmmo = -1;
	
	end
	
	// have secondary clip?
	if( self.Secondary && self.Secondary.Ammo != "" && self.Secondary.ClipSize != -1 ) then
	
		self.AmmoDisplay.SecondaryAmmo = self:GetAmmo( self.Secondary.Ammo );
		
	// have secondary ammo?
	elseif( self.Secondary && self.Secondary.Ammo != "" && self.Secondary.ClipSize == -1 ) then
	
		self.AmmoDisplay.SecondaryAmmo = LocalPlayer():GetCustomAmmo( self.Secondary.Ammo );
	
	end
	
	return self.AmmoDisplay;

end


/*------------------------------------
	FreezeMovement
------------------------------------*/
function SWEP:FreezeMovement( )

	return false;

end

/*------------------------------------
	ViewModelDrawn
------------------------------------*/
function SWEP:ViewModelDrawn( )
end

/*------------------------------------
	DrawHUD
------------------------------------*/
function SWEP:DrawHUD()
end

/*------------------------------------
	DrawWeaponSelection
------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	// calculate center
	local cx = x + wide * 0.5 - 32;
	local cy = y + tall * 0.5 - 32;

	// draw icon
	surface.SetMaterial( star );
	surface.SetDrawColor( 255, 255, 255, alpha );
	surface.DrawTexturedRect(
		cx, cy,
		64, 64
	
	);

end

/*------------------------------------
	PrintWeaponInfo
------------------------------------*/
function SWEP:PrintWeaponInfo( x, y, alpha )
end

/*------------------------------------
	HUDShouldDraw
------------------------------------*/
function SWEP:HUDShouldDraw( element )

	return true;

end

/*------------------------------------
	GetViewModelPosition
------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	return pos, ang;

end

