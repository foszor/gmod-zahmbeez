
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared files
include( 'shared.lua' );


// idle schedule
local schdIdle = ai_schedule.New( "Citizen Idle" );
	schdIdle:AddTask( "PlaySequence", { Name = "idle_angry", Speed = 1 } );
	
// cower schedule
local schdCower = ai_schedule.New( "Citizen Cower" );
	schdCower:AddTask( "PlaySequence", { Name = "cower", Speed = 1 } );
	schdCower:AddTask( "PlaySequence", { Name = "cower_Idle", Speed = 0.1 } );

	
/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	// setup
	self:SetModel( self.Model );
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
	self:SetSolid( SOLID_BBOX );
	self:SetMoveType( MOVETYPE_STEP );
	self:CapabilitiesAdd( CAP_MOVE_GROUND );
	self:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY );
	self:SetNPCClass( CLASS_PLAYER_ALLY );
	self:SetMaxYawSpeed( 100 );
	
	// defaults
	self.IsDead = false;
	self.CowerTime = 0;
	
end 


/*------------------------------------
	Think
------------------------------------*/
function ENT:Think( )
	
end


/*------------------------------------
	OnTakeDamage
------------------------------------*/
function ENT:OnTakeDamage( dmg )

	// make sure we're not dead
	if ( self.IsDead ) then
	
		return;
		
	end
	
	// get attacker
	local attacker = dmg:GetAttacker();
	
	// make sure its not a player
	if ( ValidEntity( attacker ) && attacker:IsPlayer() ) then
	
		return;
	
	end
	
	// reduce health
	self:SetHealth( self:Health() - dmg:GetDamage() );
	
	// check for death
	if ( self:Health() <= 0 ) then
	
		// die bitch
		self:Die( attacker );
		
	else
	
		// delay done
		if ( CurTime() > ( self.LastPainTime or 0 ) ) then
		
			// random sound
			local sound = Sound( ("vo/npc/female01/pain0%d.wav"):format( math.random( 1, 9 ) ) );
			
			// play it
			self:EmitSound( sound, 120, 100 );
			
			// delay
			self.LastPainTime = CurTime() + 1.5;
			
		end
	
		// cower
		self:StartSchedule( schdCower );
		
	end
	
end 


/*------------------------------------
	Die
------------------------------------*/
function ENT:Die( attacker )

	// dead
	self.IsDead = true;
	
	// thanks Chad!
	self:Fire( "AddOutput", "renderfx 23", 0 );
	SafeRemoveEntityDelayed( self, 0.5 );
		
end


/*------------------------------------
	SelectSchedule
------------------------------------*/
function ENT:SelectSchedule( )

	// idle
	self:StartSchedule( schdIdle );
	
end


/*------------------------------------
	TaskStart_PlaySound
------------------------------------*/
function ENT:TaskStart_PlaySound( data )

	// finish
	self:TaskComplete();

end
