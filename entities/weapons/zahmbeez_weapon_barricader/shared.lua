
//---------- Info
SWEP.Base				= "zahmbeez_base_weapon";
SWEP.ViewModel			= "models/weapons/v_crowbar.mdl";
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl";
SWEP.Category			= "Zahmbeez";
SWEP.PrintName			= "Barricader";
SWEP.Slot				= 0;
SWEP.SlotPos			= 0;
SWEP.Spawnable			= false;
SWEP.AdminSpawnable		= false;
SWEP.MaxBarricades 		= 8;

//---------- Primary
SWEP.Primary = {
	ClipSize	= 1,
	DefaultClip	= 1,
	Automatic	= false,
	Ammo		= "wood",
	MaxAmmo		= SWEP.MaxBarricades - 1,
	Delay		= 1,

};

//---------- Secondary
SWEP.Secondary = {
	ClipSize	= -1,
	DefaultClip	= -1,
	Automatic	= false,
	Ammo		= "",
	Delay		= 0.5,

};

// barricades
SWEP.Barricades = {

	{
	
		Trace = "TraceWall",
		TraceArgs = { 25, 30 },
		Model = Model( "models/props_debris/wood_board04a.mdl" ),
		Health = 40,
		Create = "ConstructGeneric",
		Sound = Sound( "physics/wood/wood_box_impact_bullet3.wav" )
		
	},
	
	{
	
		Trace = "TraceFloor",
		TraceArgs = { 120, 20 },
		Model = Model( "models/props_wasteland/barricade001a.mdl" ),
		Health = 40,
		Create = "ConstructGeneric",
		Sound = Sound( "physics/wood/wood_box_impact_hard1.wav" )
		
	}

};


/*------------------------------------
	Precache
------------------------------------*/
function SWEP:Precache( )

end

/*------------------------------------
	Initialize
------------------------------------*/
function SWEP:Initialize( )

	// base
	self.BaseClass.Initialize( self );
	
	// defaults
	self.BarricadeIndex = 1;

	// server
	if( SERVER ) then
	
		// storage
		self.CurrentBarricades = {};
	
		// holdtype
		self:SetWeaponHoldType( "melee" );
		
	else
		
		// create ghost
		self:CreateGhost();
		
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
		
	// jumping?
	elseif ( !self.Owner:OnGround() ) then
	
		return;
	
	end
	
	if ( SERVER ) then
	
		// take ammo
		self:TakePrimaryAmmo( 1 );
	
		// call creation function
		local barricade = self[ self.Barricades[ self.BarricadeIndex ][ 'Create' ] ]( self );
		
		// validate
		if ( ValidEntity( barricade ) ) then
		
			// play sound
			barricade:EmitSound( self.Barricades[ self.BarricadeIndex ][ 'Sound' ], 100, 100 );
			
			// save
			self:StoreBarricade( barricade );
			
			// reload
			self:Reload();
		
		end
		
	end
	
end


/*------------------------------------
	SecondaryAttack
------------------------------------*/
function SWEP:SecondaryAttack( )

	// next attack
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay );

	// increment
	self.BarricadeIndex = ( self.BarricadeIndex < #self.Barricades ) && self.BarricadeIndex + 1 || 1;
	
	if ( CLIENT ) then
	
		// update model
		self:UpdateGhostModel();
		
	end

end


/*------------------------------------
	Holster
------------------------------------*/
function SWEP:Holster( )

	if ( CLIENT ) then
	
		// destroy
		self:RemoveGhost();
		
	end
	
	// allow
	return true;

end


/*------------------------------------
	TraceWall
------------------------------------*/
function SWEP:TraceWall( distance, wide )

	// trace specifics
	local padding = 10;
	
	// get directions
	local eyes = self.Owner:EyeAngles();
	eyes.pitch = math.Clamp( eyes.pitch, -20, 10 );
	local side = eyes:Right();
	local forward = eyes:Forward();
	
	// base position
	local base = self.Owner:GetShootPos();
	
	// calculate starting positions
	local start_left = base + ( side * wide ) + ( forward * padding );
	local start_right = base + ( side * -wide ) + ( forward * padding );
	
	// build the left trace
	local left_trace = {};
	left_trace.start = start_left;
	left_trace.endpos = start_left + ( forward * distance );
	left_trace.filter = self.Owner;
	
	// trace it
	local left_tr = util.TraceLine( left_trace );
	
	// build the right trace
	local right_trace = {};
	right_trace.start = start_right;
	right_trace.endpos = start_right + ( forward * distance );
	right_trace.filter = self.Owner;
	
	// trace it
	local right_tr = util.TraceLine( right_trace );
	
	// confirm connection
	if ( left_tr.HitWorld && right_tr.HitWorld ) then
	
		// make sure its on a wall
		if( right_tr.HitNormal.z > 0.8 || left_tr.HitNormal.z > 0.8 ) then
		
			// no good
			return nil, nil;
			
		end
	
		// angle
		local normal = ( right_tr.HitNormal + left_tr.HitNormal ) * 0.5;
		local ang = normal:Angle();
		ang:RotateAroundAxis( normal, 90 );
		
		// position
		local pos = ( right_tr.HitPos + left_tr.HitPos ) * 0.5;
		pos = pos + ( normal * 1 );
		
		// center position
		local end_center = pos + ( normal * -5 );
		
		// build the center trace
		local center_trace = {};
		center_trace.start = pos;
		center_trace.endpos = end_center;
		center_trace.filter = self.Owner;
		
		// trace it
		local center_tr = util.TraceLine( center_trace );
		
		// check for empty area
		if ( center_tr.Fraction < 1 ) then
		
			// no good
			return nil, nil;
			
		end
		
		// return values
		return pos, ang;
		
	end
	
	// no good
	return nil, nil;

end


/*------------------------------------
	TraceFloor
------------------------------------*/
function SWEP:TraceFloor( distance, up )
	
	// get directions
	local eyes = self.Owner:EyeAngles();
	eyes.pitch = math.min( eyes.pitch, 40 );
	local forward = eyes:Forward();
	
	// base position
	local base = self.Owner:GetShootPos();
	
	// build the trace
	local trace = {};
	trace.start = base;
	trace.endpos = base + ( forward * distance );
	trace.filter = self.Owner;
	
	// trace it
	local tr = util.TraceLine( trace );
	
	// confirm connection
	if ( tr.HitWorld ) then
	
		// make sure its on the floor
		if( tr.HitNormal.z <= 0.8 ) then
		
			// no good
			return nil, nil;
			
		end
		
		local pos = tr.HitPos + ( tr.HitNormal * up );
		local ang = Angle( 0, eyes.yaw, 0 );
		ang:RotateAroundAxis( ang:Up(), 90 );
		
		// return position
		return pos, ang;
		
	end
	
	// no good
	return nil, nil;

end
