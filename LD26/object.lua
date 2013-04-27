
require "util"

Object = {}
Object_mt = { __index = Object }

function Object:create(sprite, x, y, rot, scale, vX, vY)
	o = {}
	setmetatable(o,Object_mt)
	o.x = x or 0
	o.y = y or 0
	o.scale = scale,1
	o.rot = rot
	o.acc = Vec:create(0,0)
	o.vel = Vec:create(vX,vY)
	o.maxVel = Vec:create()
	o.maxVel.x = 100
	o.maxVel.y = 100
	o.opacity = 255
	o.w = 0
	o.h = 0
	o.sprite = {}
	if sprite then
		o.sprite = Content:image(sprite)
		if o.sprite then
			o.w = o.sprite:getWidth()
			o.h = o.sprite:getHeight()
		end
	end
	return o
end


function Object:draw()
	if self.opacity ~= 255 then
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(255,255,255,self.opacity)
	end
	love.graphics.draw( self.sprite, self.x, self.y, self.rot, self.scale, self.scale )
end
 

function Object:onCollision( obj )
	
end



function Object:update(dt)
	dt = dt,0
	dt = dt
--update vel
	self.vel.x = self.vel.x + self.acc.x
	if self.vel.x > self.maxVel.x then
		print(self.vel.x.." is greater than "..self.maxVel.x)
		self.vel.x = self.maxVel.x
		print("vel is now "..self.vel.x)
	elseif self.vel.x < -self.maxVel.x then
		print("too low")
		self.vel.x = -self.maxVel.x
	end
	self.vel.y = self.vel.y + self.acc.y
	if self.vel.y > self.maxVel.y then
		self.vel.y = self.maxVel.y
	elseif self.vel.y < -self.maxVel.y then
		self.vel.y = -self.maxVel.y
	end
--update position
	self.x = self.x + (dt * self.vel.x)
	self.y = self.y + (dt * self.vel.y)
end



