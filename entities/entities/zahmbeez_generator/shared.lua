
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zahmbeez_baseobject";
ENT.PrintName				= "Generator";
ENT.Model					= Model( "models/props_vehicles/generatortrailer01.mdl" );
ENT.SoundStart				= Sound( "Airboat_engine_start" );
ENT.SoundIdle 				= Sound( "Airboat_engine_idle" );
ENT.SoundStop				= Sound( "Airboat_engine_stop" );
ENT.SoundFueled				= Sound( "plats/elevator_start1.wav" );
ENT.SoundWarning 			= Sound( "ambient/alarms/klaxon1.wav" );
ENT.WarningLevel			= 20;

// accessors
AccessorFuncNW( ENT, "fuel", "Fuel", 0, FORCE_NUMBER );
AccessorFuncNW( ENT, "maxfuel", "MaxFuel", 100, FORCE_NUMBER );
AccessorFuncNW( ENT, "ison", "On", false, FORCE_BOOL );
