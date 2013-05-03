
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
	local r = {}
	setmetatable(r, Rect_mt)
	r.x = x or 0
	r.y = y or 0
	r.w = w or 0
	r.h = h or r.w
	return r
end

-- Returns X,Y,W,H
function Rect:values()
	return self.x, self.y, self.w, self.h
end

-- Returns the intersection of two rects
function Rect.intersection(r1, r2)
	local r3 = Rect:create(0,0,0,0)
	if Rect.collidesWith( r1, r2 ) then
		r3.x = math.max(r2.x, r1.x)
		r3.y = math.max(r2.y, r1.y)
		if (r2.x + r2.w <= r1.x + r1.w) then
			r3.w = (r2.w + r2.x) - r3.x
		else
			r3.w = (r1.x + r1.w) - r3.x
		end
		if (r2.y + r2.h <= r1.y + r1.h) then
			r3.h = (r2.h + r2.y) - r3.y
		else
			r3.h = (r1.y + r1.h) - r3.y
		end
	end
	return r3
end


function min(...)
	local m = select(1, ...)
	for i=2,select("#", ...) do
		if m > select(i, ...) then
			m = select(i, ...)
		end
	end
	return m
end

function max(...)
	local m = 0
	for i=1,select("#", ...) do
		if m < select(i, ...) then
			m = select(i, ...)
		end
	end
	return m
end

-- Returns the combination of two rects, resulting in a rect that
-- encapsulates both of them.
function Rect.combine(r1, r2)
	if (r1.w == 0 and r1.h == 0) then
		return r2
	elseif (r2.w == 0 and r2.h == 0) then
		return r1
	end
	local r3 = Rect:create(math.min(r1.x, r2.x), math.min(r1.y, r2.y),0,0)
	r3.w = math.max(r1.w, r2.w) + math.max(r1.x, r2.x) - r3.x
	r3.h = math.max(r1.h, r2.h) + math.max(r1.y, r2.y) - r3.y
--	print("x "..r1.x.." "..r2.x)
--	print("y "..r1.y.." "..r2.y)
--	print("w "..r1.w.." "..r2.w)
--	print("h "..r1.h.." "..r2.h)
--	r3:print()
	return r3
end

--[[
function Rect.combine( ... )
	local xs = {}
	local ys = {}
	local ws = {}
	local hs = {}
	for i=1,select("#", ...) do
		--select(i, ...):print()
		xs[i] = (select(i, ...).x or 0)
		ys[i] = (select(i, ...).y or 0)
		ws[i] = (select(i, ...).w or 0) + select(i, ...).x
		hs[i] = (select(i, ...).h or 0) + select(i, ...).y
		print("h "..(select(i, ...).h))
	end
	rect = Rect:create( min( unpack(xs) or 0 ), min( unpack(ys) or 0 ), 0, 0 )
	rect.w = max( unpack(ws) or 0 ) - rect.x
	rect.h = max( unpack(hs) or 0 ) + (max(unpack(ys) or 0)) - rect.y
	print("max W "..(max( unpack(ws) or 0 )))
	print("max H "..(max( unpack(hs) or 0 )))
	print("max X "..(max(unpack(xs) or 0)))
	print("max Y "..(max(unpack(ys) or 0)))
	print("min Y "..rect.y)
	print()
	rect:print()
	return rect
end
--]]

-- Checks if two rects are equal
function Rect.equal(r1,r2)
	return ( r1.x == r2.x and r1.y == r2.y
		 and r1.w == r2.w and r1.h == r2.h )
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


function Rect:print()
	print("("..(self.x or "nil")..","..(self.y or "nil")..
		 ")["..(self.w or "nil").."x"..(self.h or "nil").."]")
end


Vec = {}
Vec_mt = { __index = Vec }


function Vec:create(x,y)
	local pos = {}
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



