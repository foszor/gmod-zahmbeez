
//---------- Info
SWEP.Base				= "zahmbeez_base_weapon";
SWEP.ViewModel			= "models/weapons/v_smg1.mdl";
SWEP.WorldModel			= "models/weapons/w_smg1.mdl";
SWEP.Category			= "Zahmbeez";
SWEP.PrintName			= "SMG";
SWEP.Slot				= 0;
SWEP.SlotPos			= 0;
SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= false;


//---------- Primary
SWEP.Primary = {
	ClipSize	= 45,
	DefaultClip	= 45,
	Automatic	= true,
	Ammo		= "smground",
	MaxAmmo		= 200,
	Delay		= 0.1,
	ReloadTime	= 2.5,

};

//---------- Secondary
SWEP.Secondary = {
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false,
	Ammo		= "",
	Delay		= 0,
	ReloadTime	= 0,

};


/*------------------------------------
	Precache
------------------------------------*/
function SWEP:Precache( )

	util.PrecacheSound( "Weapon_SMG.Single" );

end

/*------------------------------------
	Initialize
------------------------------------*/
function SWEP:Initialize( )

	// base
	self.BaseClass.Initialize( self );

	// server
	if( SERVER ) then
	
		// holdtype
		self:SetWeaponHoldType( "smg" );
		
	end

end

/*------------------------------------
	PrimaryAttack
------------------------------------*/
function SWEP:PrimaryAttack( )

	// next attack
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );

	// enough ammo?
	if( !self:CanPrimaryAttack() ) then
	
		return;
	
	end
	
	// take ammo
	if( SERVER ) then
		
		// take ammo
		self:TakePrimaryAmmo( 1 );

	end
	
	// fire a bullet
	local bullet = {
		Num		= 1,
		Src		= self.Owner:GetShootPos(),
		Dir		= self.Owner:GetAimVector(),
		Spread		= Vector( 0.035, 0.035, 0 ),
		Tracer		= 5,
		Force		= 17,
		Damage		= 25,
		HullSize	= HULL_TINY_CENTERED,
		AmmoType	= "Pistol",
		TracerName	= "ZahmSMGTracer",
		Attacker	= self.Owner,

	};
	self.Weapon:FireBullets( bullet );
	
	// sound
	self.Weapon:EmitSound( "Weapon_SMG.Single" );
	
	// animation
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Owner:MuzzleFlash();
	
end
