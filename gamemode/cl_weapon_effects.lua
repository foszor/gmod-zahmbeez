
//---------- Sprite Flags
FX_SPRITE_FADEIN		= 1;
FX_SPRITE_FADEOUT		= 2;
FX_SPRITE_GROW			= 4;
FX_SPRITE_SHRINK		= 8;
FX_OFFSET_SHRINK		= 16;

//---------- Discreet Line
local FXDiscreetLine = {};

/*------------------------------------
	create
------------------------------------*/
function FXDiscreetLine:create( start, direction, velocity, length, clip_length, scale, life, material, color )

	// create
	local obj = {};
	setmetatable( obj, self );
	self.__index = self;
	
	// store vars
	obj.origin = start;
	obj.direction = direction;
	obj.velocity = velocity;
	obj.length = length;
	obj.clip_length = clip_length;
	obj.scale = scale;
	obj.life = life;
	obj.lifetime = life;
	obj.start_time = 0;
	obj.material = type( material ) == "string" && Material( material ) || material;
	obj.color = color;
	obj.started_at = CurTime() + life;
	
	return obj;

end

/*------------------------------------
	SetCallback
------------------------------------*/
function FXDiscreetLine:SetCallback( func )

	self.callback = func;

end

/*------------------------------------
	Draw
------------------------------------*/
function FXDiscreetLine:Draw( )

	// update
	self.life = self.started_at - CurTime();
	self.start_time = self.lifetime - self.life;
	
	// distance along path
	local sdist = self.velocity * self.start_time;
	local edist = sdist - self.length;
	
	// clip
	sdist = math.max( 0, sdist );
	edist = math.max( 0, edist );
	
	// gonezor?
	if( sdist == 0 && edist == 0 ) then return Vector( 0, 0, 0 ), Vector( 0, 0, 0 ); end
	
	// clip
	if( self.clip_length != 0 ) then
	
		sdist = math.min( sdist, self.clip_length );
		edist = math.min( edist, self.clip_length );
	
	end
	
	// calculate the points
	local endpos = self.origin + self.direction * edist;
	local startpos = self.origin + self.direction * sdist;
	
	// callback
	if( self.callback ) then
	
		self.callback( self, endpos, startpos );
	
	end
	
	// taper off the end of the beam.
	render.SetMaterial( self.material );
	
	// draw beam.
	render.StartBeam( 2 );
		render.AddBeam( startpos, self.scale, 1, self.color );
		render.AddBeam( endpos, self.scale, 0, self.color );
	render.EndBeam();
	
	return startpos, endpos;

end

/*------------------------------------
	IsFinished
------------------------------------*/
function FXDiscreetLine:IsFinished( )

	return self.life > 0;

end


//---------- Muzzle Sprite
local FXMuzzleSprite = {};

/*------------------------------------
	create
------------------------------------*/
function FXMuzzleSprite:create( weapon, size, life, material, color, flags, count, offset, endsize )

	// create
	local obj = {};
	setmetatable( obj, self );
	self.__index = self;
	
	// store vars
	obj.weapon = weapon;
	obj.size = size;
	obj.die = CurTime() + life;
	obj.life = life;
	obj.material = type( material ) == "string" && Material( material ) || material;
	obj.color = color;
	obj.flags = flags;
	obj.count = count || 1;
	obj.offset = offset || size / 2;
	obj.endsize = endsize || size;

	return obj;

end

/*------------------------------------
	Draw
------------------------------------*/
function FXMuzzleSprite:Draw( )

	// invalid?
	if( !ValidEntity( self.weapon ) ) then
	
		return;
	
	end

	// get the muzzle position
	local pos, ang = GetMuzzle( self.weapon, 1 );
	
	local percent = ( 1 / self.life ) * ( self.die - CurTime() );
	local size = self.size;
	local endsize = self.endsize;
	local color = Color(
		self.color.r,
		self.color.g,
		self.color.b,
		self.color.a
	);
	
	// scale
	if( self.flags & FX_SPRITE_GROW != 0 ) then
	
		size = self.size - self.size * percent;
		endsize = self.endsize - self.endsize * percent;
	
	elseif( self.flags & FX_SPRITE_SHRINK != 0 ) then
	
		size = self.size * percent;
		endsize = self.endsize * percent;
	
	end
	
	
	// fade
	if( self.flags & FX_SPRITE_FADEIN != 0 ) then
	
		color.a = color.a - color.a * percent;
	

	elseif( self.flags & FX_SPRITE_FADEOUT != 0 ) then
	
		color.a = color.a * percent;
	
	end
	
	
	// have more than one?
	if( self.count > 0 ) then
	
		for i = 0, self.count - 1 do
		
			// calculate new size
			local newsize = size + ( ( endsize - size ) / self.count ) * i;
			
			// offset
			local offset = self.offset;
			if( self.flags & FX_OFFSET_SHRINK != 0 ) then
			
				offset = offset * percent;
			
			end
	
			// draw sprite
			render.SetMaterial( self.material );
			render.DrawSprite(
				pos + ang:Forward() * offset * i,
				newsize, newsize,
				color
			
			);
			
		end
	
	end

end

/*------------------------------------
	IsFinished
------------------------------------*/
function FXMuzzleSprite:IsFinished( )

	return self.die >= CurTime() && ValidEntity( self.weapon );

end


/*------------------------------------
	MuzzleSprite
------------------------------------*/
function MuzzleSprite( weapon, size, life, material, color, flags, count, offset, endsize )

	return FXMuzzleSprite:create( weapon, size, life, material, color, flags, count, offset, endsize );

end


/*------------------------------------
	DiscreetLine
------------------------------------*/
function DiscreetLine( start, direction, velocity, length, clip_length, scale, life, material, color )

	return FXDiscreetLine:create( start, direction, velocity, length, clip_length, scale, life, material, color );

end

/*------------------------------------
	GetMuzzle
------------------------------------*/
function GetMuzzle( weapon, attachment )

	// invalid weapon?
	if( !ValidEntity( weapon ) ) then
	
		return;
		
	end

	// default to the given position
	local origin = weapon:GetPos();
	local angle = weapon:GetAngles();
	
	// if we are carrying this weapon use our view model instead
	/*
	if( weapon:IsWeapon() && weapon:IsCarriedByLocalPlayer() ) then
	
		// get owner
		local owner = weapon:GetOwner();
		if( ValidEntity( owner ) && GetViewEntity() == owner ) then
		
			// get view model
			local viewmodel = owner:GetViewModel();
			if( ValidEntity( viewmodel ) ) then
			
				weapon = viewmodel;
			
			end
			
		end
	
	end
	*/
	
	// get the attachment
	local attachment = weapon:GetAttachment( attachment or 1 );
	if( !attachment ) then
	
		return origin, angle;
		
	end
	
	// use the attachment origin
	return attachment.Pos, attachment.Ang;

end

/*------------------------------------
	GetTracerOrigin
------------------------------------*/
function GetTracerOrigin( data )

	// default to the given position
	local start = data:GetStart();
	
	// entity
	local entity = data:GetEntity();
	
	// validate
	if ( !ValidEntity( entity ) || !ValidEntity( entity.WorldEntity ) || !entity.WorldEntity.MuzzlePosition ) then
	
		// use start
		return start;
	
	end
	
	// muzzle position
	return entity.WorldEntity.MuzzlePosition;

end
