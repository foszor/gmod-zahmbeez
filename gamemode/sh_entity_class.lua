
// get metatable
local meta = FindMetaTable( "Entity" );
if ( !meta ) then return; end

// accessors
AccessorFuncNW( meta, "radartype", "RadarType", 0, FORCE_NUMBER );
AccessorFuncNW( meta, "poisontime", "PoisonTime", 0, FORCE_NUMBER );
AccessorFuncNW( meta, "frozentime", "FrozenTime", 0, FORCE_NUMBER );


/*------------------------------------
	GetCustomAmmo
------------------------------------*/
function meta:GetCustomAmmo( name )

	return self:GetNetworkedInt( "ammo_" .. name );
	
end


/*------------------------------------
	SetCustomAmmo
------------------------------------*/
function meta:SetCustomAmmo( name, num )

	self:SetNetworkedInt( "ammo_" .. name, num );
	
end


/*------------------------------------
	AddCustomAmmo
------------------------------------*/
function meta:AddCustomAmmo( name, num )

	self:SetCustomAmmo( name, self:GetCustomAmmo( name ) + num );
	
end
