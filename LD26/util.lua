
require "math"


function readFile(file)
	if love.filesystem.exists(file) then
		return love.filesystem.read(file)
	end
end

function lines(file)
	return love.filesystem.lines(file)
end


Rect = {}
Rect_mt = { __index = Rect }

function Rect:create(x,y,w,h)
	r = {}
	setmetatable(r, Rect_mt)
	r.x = x or 0
	r.y = y or 0
	r.w = w or 0
	r.h = h or 0
	return r
end


function Rect:centerOver(r2)
	self.x = r2.x - (self.w -r2.w) / 2
	self.y = r2.y - (self.h -r2.h) / 2
end


function Rect:collidesWith(r2)
	return
	  ( ((self.x >= r2.x) and (self.x >= r2.x)) or (self.x + self.w >= r2.x) )
	  and
	  ( ((self.y >= r2.y) and (self.y <= r2.y + r2.h)) or (self.y + self.h >= r2.y) )
end


function Rect:keepWithin(r2)
	if self.x < r2.x then
		self.x = r2.x
	elseif self.x + self.w > r2.x + r2.w then
		self.x = r2.x + r2.w - self.w
	end
	if self.y < r2.y then
		self.y = r2.y
	elseif self.y + self.h > r2.y + r2.h then
		self.y = r2.y + r2.h - self.h
	end
end


Vec = {}
Vec_mt = { __index = Vec }


function Vec:create(x,y)
	pos = {}
	setmetatable(pos, Vec_mt)
	pos.x = x
	pos.y = y
	return pos
end

function Vec:setTo(x,y)
	self.x = x or 0
	self.y = y or 0
end

function Vec:getDirection()
	return math.atan( self.y / self.x )
end


function Vec:getDirectionTo( vec )
	return atan( (vec.y - self.y) / (vec.x - self.x) )
end

function Vec:move(x,y)
	self.x = x + self.x
	self.y = y + self.y
end

function Vec:moveTo(x,y)
	self.x = x
	self.y = y
end

function Vec:add(vec)
	return Vec:create( self.x + vec.x, self.y + vec.y )
end

function Vec:sub(vec)
	return Vec:create( self.x - vec.x, self.y - vec.y )
end

function Vec:div(vec)
	return Vec:create( self.x / vec.x, self.y / vec.y )
end



-- Create a new class that inherits from a base class
--
function inheritsFrom( baseClass )

    -- The following lines are equivalent to the SimpleClass example:

    -- Create the table and metatable representing the class.
    local new_class = {}
    local class_mt = { __index = new_class }

    -- Note that this function uses class_mt as an upvalue, so every instance
    -- of the class will share the same metatable.
    --
    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    return new_class
end



