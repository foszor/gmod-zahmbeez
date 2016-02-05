

/*

vo/npc/male01/behindyou01.wav and 02 - BEHIND YOU!
vo/npc/male01/finally.wav - FINALLY
vo/npc/male01/goodgod.wav - GOOD GOD
vo/npc/male01/headcrabs01.wav and 02 - HEADCRABS!

vo/npc/male01/no01.wav and 02 - NO!
vo/npc/male01/ok01.wav and 02 - OKAY


*/

// sound events
SE_GENERIC				= 0;
SE_PAIN_WEAK			= 1;
SE_PAIN_STRONG			= 2;
SE_MOVEOUT				= 3;
SE_WIN					= 4;
SE_RELOAD				= 5;
SE_DIED					= 6;
SE_KILLEDZOMBIE			= 7;
SE_INCOMING_ONE			= 8;
SE_INCOMING_FEW			= 9;
SE_INCOMING_MANY		= 10;
SE_LOSE					= 11;

// sound event thinks
SET_ZOMBIES				= 1;

// design events
local EventSoundTable = {

	// event
	[ SE_PAIN_WEAK ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/pain01.wav",
			"vo/npc/male01/pain02.wav",
			"vo/npc/male01/pain03.wav",
			"vo/npc/male01/pain04.wav",
			"vo/npc/male01/pain05.wav",
			"vo/npc/male01/pain06.wav"
			
		},
		
		// delay between
		Freq = { 1, 3 }
	
	},
	
	// event
	[ SE_PAIN_STRONG ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/pain07.wav",
			"vo/npc/male01/pain08.wav",
			"vo/npc/male01/pain09.wav"
			
		},
		
		// delay between
		Freq = { 2, 4 }
	
	},
	
	// event
	[ SE_MOVEOUT ] = {
	
		// sound to use
		Sounds = {
		
			"vo/npc/male01/evenodds.wav",
			"vo/npc/male01/leadtheway01.wav",
			"vo/npc/male01/leadtheway02.wav",
			"vo/npc/male01/letsgo01.wav",
			"vo/npc/male01/letsgo02.wav",
			"vo/npc/male01/okimready01.wav",
			"vo/npc/male01/okimready02.wav",
			"vo/npc/male01/okimready03.wav",
			"vo/npc/male01/readywhenyouare01.wav",
			"vo/npc/male01/readywhenyouare02.wav"
			
		}
	
	},
	
	// event
	[ SE_WIN ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/coast/odessa/male01/nlo_cheer01.wav",
			"vo/coast/odessa/male01/nlo_cheer02.wav",
			"vo/coast/odessa/male01/nlo_cheer03.wav",
			"vo/coast/odessa/male01/nlo_cheer04.wav"
		
		}
		
	},
	
	// event
	[ SE_RELOAD ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/coverwhilereload01.wav",
			"vo/npc/male01/coverwhilereload02.wav",
			"vo/npc/male01/gottareload01.wav"
		
		},
		
		// delay between
		Freq = { 8, 16 }
	
	},
	
	// event
	[ SE_DIED ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/moan01.wav",
			"vo/npc/male01/moan01.wav",
			"vo/npc/male01/moan01.wav",
			"vo/npc/male01/moan01.wav",
			"vo/npc/male01/moan01.wav"
		
		}
	
	},
	
	// event
	[ SE_KILLEDZOMBIE ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/likethat.wav",
			"vo/npc/male01/fantastic01.wav",
			"vo/npc/male01/fantastic02.wav",
			"vo/npc/male01/gotone01.wav"
		
		},
		
		// delay between
		Freq = { 5, 10 }
	
	},
	
	// event
	[ SE_INCOMING_ONE ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/incoming02.wav",
			"vo/npc/male01/getdown02.wav",
			"vo/npc/male01/overthere01.wav",
			"vo/npc/male01/overthere02.wav",
			"vo/npc/male01/headsup01.wav",
			"vo/npc/male01/headsup02.wav"
		
		},
		
		// delay between
		Freq = { 8, 16 }
	
	},
	
	// event
	[ SE_INCOMING_FEW ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/heretheycome01.wav",
			"vo/npc/male01/zombies01.wav",
			"vo/npc/male01/zombies02.wav",
			"vo/npc/male01/watchout.wav",
			"vo/npc/male01/takecover02.wav"
		
		},
		
		// delay between
		Freq = { 8, 16 }
	
	},
	
	// event
	[ SE_INCOMING_MANY ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/runforyourlife01.wav",
			"vo/npc/male01/runforyourlife02.wav",
			"vo/npc/male01/runforyourlife03.wav",
			"vo/npc/male01/gethellout.wav",
			"vo/npc/male01/help01.wav"
			
		},
		
		// delay between
		Freq = { 8, 16 }
	
	},
	
	// event
	[ SE_LOSE ] = {
	
		// sounds to use
		Sounds = {
		
			"vo/npc/male01/answer40.wav",
			"vo/npc/male01/answer25.wav",
			"vo/npc/male01/answer17.wav",
			"vo/npc/male01/doingsomething.wav",
			"vo/npc/male01/goodgod.wav",
			"vo/npc/male01/gordead_ans01.wav",
			"vo/npc/male01/gordead_ans02.wav",
			"vo/npc/male01/gordead_ans04.wav",
			"vo/npc/male01/gordead_ans19.wav"
		
		}
	
	}

};

// loop events
for _, event in pairs( EventSoundTable ) do

	// loop sounds
	for __, sound in pairs( event.Sounds ) do
	
		// precache
		util.PrecacheSound( sound );
	
	end

end


/*------------------------------------
	PlayerSoundEvent
------------------------------------*/
function GM:PlayerSoundEvent( pl, event, linked_delay )

	// defaults
	pl.NextSoundEvent = pl.NextSoundEvent or {};
	pl.NextSoundEvent[ event ] = pl.NextSoundEvent[ event ] or 0;
	pl.NextSoundEvent[ SE_GENERIC ] = pl.NextSoundEvent[ SE_GENERIC ] or 0;
	
	// generic delay in between sounds
	if ( pl.NextSoundEvent[ SE_GENERIC ] > CurTime() ) then
	
		// talking too much
		return;
	
	// event specific delay
	elseif ( pl.NextSoundEvent[ event ] > CurTime() ) then
	
		// too soon
		return;
		
	end
	
	// get event information
	local soundinfo = EventSoundTable[ event ];
	
	// no delay
	if ( !soundinfo.Freq ) then
	
		// now?
		pl.NextSoundEvent[ event ] = CurTime();
	
	// delay range
	elseif ( type( soundinfo.Freq ) == "table" ) then
	
		// random delay
		pl.NextSoundEvent[ event ] = CurTime() + math.random( soundinfo.Freq[ 1 ], soundinfo.Freq[ 2 ] );
	
	// specific delay
	elseif ( type( soundinfo.Freq ) == "number" ) then
	
		// set delay
		pl.NextSoundEvent[ event ] = CurTime() + soundinfo.Freq;
	
	end
	
	// check for linked delays
	if ( linked_delay && type( linked_delay ) == "table" ) then
	
		// cycle links
		for _, link in pairs( linked_delay ) do
		
			// delay
			pl.NextSoundEvent[ link ] = pl.NextSoundEvent[ event ];
		
		end
	
	end
	
	// over all talking needs to have a delay
	pl.NextSoundEvent[ SE_GENERIC ] = CurTime() + 1;
	
	// random sound
	local sound = soundinfo.Sounds[ math.random( 1, #soundinfo.Sounds ) ];
	
	// play it
	pl:EmitSound( sound, 120, 100 );
	
end


/*------------------------------------
	PlayerSoundEventThink
------------------------------------*/
function GM:PlayerSoundEventThink( pl, event )

	// defaults
	pl.NextSoundEventThink = pl.NextSoundEventThink or {};
	pl.NextSoundEventThink[ event ] = pl.NextSoundEventThink[ event ] or 0;
	
	// time to think?
	if ( pl.NextSoundEventThink[ event ] > CurTime() ) then
	
		// too soon
		return;
		
	end
	
	// zombies event
	if ( event == SET_ZOMBIES ) then
	
		// delay next think
		pl.NextSoundEventThink[ event ] = CurTime() + 1;
		
		// close zombies
		local close = 0;
		
		// find ents in range
		local entlist = ents.FindInSphere( pl:GetPos(), 356 );
		
		// cycle ents
		for _, ent in pairs( entlist ) do
		
			// validate as zombie
			if ( ValidEntity( ent ) && ent:IsNPC() && table.HasValue( ZombieClasses, ent:GetClass() ) ) then
			
				// get aiming direction
				local dir = pl:GetAimVector();
				
				// dot product
				local dot = ( pl:GetPos() - ent:GetPos() ):Normalize():DotProduct( dir );
				
				// visible zombie
				if ( pl:Visible( ent ) && dot <= 0 && !ent.Spotted ) then
				
					// add to count
					close = close + 1;
					ent.Spotted = true;
					
				end
			
			end
		
		end
		
		// many zombies?
		if ( close >= 4 ) then
		
			// call event
			self:PlayerSoundEvent( pl, SE_INCOMING_MANY, { SE_INCOMING_FEW, SE_INCOMING_ONE } );
		
		// some zombies?
		elseif ( close >= 2 ) then
		
			// call event
			self:PlayerSoundEvent( pl, SE_INCOMING_FEW, { SE_INCOMING_MANY, SE_INCOMING_ONE } );
		
		// found a zoombie
		elseif ( close >= 1 ) then
		
			// call event
			self:PlayerSoundEvent( pl, SE_INCOMING_ONE, { SE_INCOMING_MANY, SE_INCOMING_FEW } );
		
		end
	
	end

end


/*------------------------------------
	GlobalSoundEvent
------------------------------------*/
function GM:GlobalSoundEvent( event, use_delay )

	// get all active players
	local players = self:ActivePlayers( alive );
	
	// startign delay
	local delay = 0;
	
	// get event info
	local soundinfo = EventSoundTable[ event ];
	
	// cycle players
	for _, pl in pairs( players ) do
	
		// get a random sound
		local sound = soundinfo.Sounds[ math.random( 1, #soundinfo.Sounds ) ];
		
		// delay
		timer.Simple( delay, function()
		
			// make sure we're still valid
			if ( ValidEntity( pl ) && pl:Alive() ) then
		
				// play the sound
				pl:EmitSound( sound, 120, 100 );
				
			end
			
		end );
		
		// if we're using a delay...
		if ( use_delay ) then
		
			// ... increase it
			delay = delay + use_delay;
		
		end
	
	end

end
