
// get metatable
local meta = FindMetaTable( "NPC" );
if ( !meta ) then return; end

// accessors
AccessorFuncNW( meta, "bufftype", "BuffType", 0, FORCE_NUMBER );
