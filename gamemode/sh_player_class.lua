
// get metatable
local meta = FindMetaTable( "Player" );
if ( !meta ) then return; end

// accessors
AccessorFuncNW( meta, "heldentity", "HeldEntity", NULL );
AccessorFuncNW( meta, "viewmode", "ViewMode", VIEWMODE_TOPDOWN, FORCE_NUMBER );
AccessorFuncNW( meta, "booty", "Booty", 0, FORCE_NUMBER );
AccessorFuncNW( meta, "gameclass", "GameClass", 0, FORCE_NUMBER );
AccessorFuncNW( meta, "sanity", "Sanity", 100, FORCE_NUMBER );
AccessorFuncNW( meta, "alertedtime", "AlertedTime", 0, FORCE_NUMBER );
AccessorFuncNW( meta, "aimcontroller", "AimController", NULL );
AccessorFuncNW( meta, "viewcontroller", "ViewController", NULL );


/*------------------------------------
	IsSpectating
------------------------------------*/
function meta:IsSpectating( )
	
	// eval
	return ( self:GetNWBool( "Spectating" ) == true );
	
end


/*------------------------------------
	IsHolding
------------------------------------*/
function meta:IsHolding( )

	// eval
	return ( ValidEntity( self:GetHeldEntity() ) );
	
end


/*------------------------------------
	IsAlerted
------------------------------------*/
function meta:IsAlerted( )

	// get alerted time
	local alerted = self:GetAlertedTime();
	
	// eval
	return ( CurTime() - alerted < 3 );

end


/*------------------------------------
	IsSprinting
------------------------------------*/
function meta:IsSprinting( )

	// get speed
	local speed = self:GetVelocity():Length();

	// eval
	return ( self:KeyDown( IN_SPEED ) && speed >= 100 );

end
