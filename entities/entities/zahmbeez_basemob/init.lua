
// client files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared files
include( 'shared.lua' );


/*------------------------------------
	Initialize
------------------------------------*/
function ENT:Initialize( )

	self:SetModel( Model( "models/Zombie/Classic.mdl" ) );
	
	self:SetHullType( HULL_HUMAN ); 
	self:SetHullSizeNormal(); 
	
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP ) 
	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_OPEN_DOORS | CAP_SKIP_NAV_GROUND_CHECK | CAP_MOVE_CLIMB );
	self:SetMaxYawSpeed( 100 );
	
end


/*------------------------------------
	TaskStart_FindEnemy
------------------------------------*/
function ENT:TaskStart_FindEnemy( data )

	local choices = ents.FindInSphere( self:GetPos(), data.Radius or 512 );
	
	for _, ent in ipairs( choices ) do
	
		if ( ent:IsValid() && ent != self && ent:GetClass() == data.Class ) then
		
			print( "Setting Enemy ", ent, "\n" );
			self:SetEnemy( ent, true );
			self:UpdateEnemyMemory( ent, ent:GetPos() );
			self:TaskComplete();
			return;
			
		end
		
	end
	
	self:SetEnemy( NULL );
	
end


/*------------------------------------
	Task_FindEnemy
------------------------------------*/
function ENT:Task_FindEnemy( data )
end


/*------------------------------------
	SelectSchedule
------------------------------------*/
function ENT:SelectSchedule( )

	self:Hunt( "player", 200000 );

end


/*------------------------------------
	Hunt
------------------------------------*/
function ENT:Hunt( class, radius )

	local hunt = ai_schedule.New( "Zahmbeez Basemob Hunt" );
	
	hunt:AddTask( "FindEnemy", {
		Class = class,
		Radius = radius
		} );
		
	hunt:EngTask( "TASK_GET_PATH_TO_ENEMY_LKP", 0 );
    hunt:EngTask( "TASK_RUN_PATH_TIMED", 0.2 );
    hunt:EngTask( "TASK_WAIT", 0.2 );
    
	self:StartSchedule( hunt );
	
end
