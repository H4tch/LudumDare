
require "util"
require "object"



Player = inheritsFrom(Object)
Player_mt = { __index = Player }



function Player:create(sprite, x, y)
	local p = {}--Object.create(sprite, x, y, 0, 1, 0, 0)
	p.state = {
		[""]=false
		,["left"]=false
		,["right"]=false
		,["up"]=false
		,["down"]=false
		,["isRunning"]=false
		,["isJumping"]=false
		,["inAir"]=false
	}
	p.x = x or 0
	p.y = y or 0
	p.scale = scale,1
	p.rot = rot
	p.acc = Vec:create(0,0)
	p.vel = Vec:create(0,0)
	p.maxVel = Vec:create()
	p.maxVel.x = 200
	p.maxVel.y = 400
	p.opacity = 255
	p.w = 0
	p.h = 0
	p.sprite = {}
	if sprite then
		p.sprite = Content:image(sprite)
		if p.sprite then
			p.w = p.sprite:getWidth()
			p.h = p.sprite:getHeight()
		end
	end
	p.sprites = {
		[1]=p.sprite
	}
	p.spriteFrame = 1
	setmetatable(p, Player_mt)
	return p
end



function Player:draw(camera)
	--self.sprite = self.sprites[self.spriteFrame]
	love.graphics.draw( self.sprite, self.x - camera.x, self.y - camera.y, self.rot, self.scale, self.scale )
end



function Player:onKeyDown(key, isRepeat)
	if key == "left" or key == "a" then
		self.state.left = true
		--self.x = self.x - 4
	elseif key == "right" or key == "d" then
		self.state.right = true
		--self.x = self.x + 4
	elseif key == " " then
		--if self.state.inAir == false then
			-- Make player jump
			self.state.isJumping = true
			self.state.inAir = true
			self.jumpVel = 800
		--end
	elseif key == "lshift" or key == "rshift" then
		self.state.isRunning = true
	end
end



function Player:onKeyUp(key, isRepeat)
	if key == "left" or key == "a" then
		self.state.left = false
		--self.x = self.x - 4
	elseif key == "right" or key == "d" then
		self.state.right = false
		--self.x = self.x + 4
	elseif key == " " then
		if not self.state.inAir then
			self.state.isJumping = false
		end
	elseif key == "lshift" or key == "rshift" then
		self.state.isRunning = false
	end
end


-- brings a value closer to zero for either sign without going
-- into other sign.
function Player:slowDown( value, amount )
	if value == 0 then
	elseif value > 0 then
		value = value - amount
		if value < 15 then
			value = 0
		end
	else
		value = value + amount
		if value > 15 then
			value = 0
		end
	end
	return value
end



function Player:update(dt)
	dt = dt or 0
	dt = dt
	
--update vel
	if self.state.left then
		self.vel.x = self.vel.x - 20
	end
	if self.state.right then
		self.vel.x = self.vel.x + 20
	end
	
	if self.vel.x ~= 0
	  and ( self.state.left == false
		or self.state.right == false ) then
		self.vel.x = self:slowDown( self.vel.x, 5 )
	end
	
--[[	
	if self.state.up then
		self.vel.y = self.vel.y - 10
	end
	if self.state.down then
		self.vel.y = self.vel.y + 10
	end
	
	if not (self.vel.y == 0)
	  and self.state.up == false
	  or self.state.down == false then
		self.vel.y = self:slowDown( self.vel.y, 5 )
	end
--]]
	
	if self.state.isJumping then
		self.vel.y = self.vel.y - self.jumpVel
		self.jumpVel = self:slowDown(self.jumpVel, 30)
	end
	
	if self.state.inAir then
		self.vel.y = self.vel.y + 20
	end
	
	-- Limit Player's velocity
	--self.vel.x = self.vel.x + self.acc.x
	if self.vel.x > self.maxVel.x then
		self.vel.x = self.maxVel.x
	elseif self.vel.x < -self.maxVel.x then
		self.vel.x = -self.maxVel.x
	end
	--self.vel.y = self.vel.y + self.acc.y
	if self.vel.y > self.maxVel.y then
		self.vel.y = self.maxVel.y
	elseif self.vel.y < -self.maxVel.y then
		self.vel.y = -self.maxVel.y
	end
	
	--print("Velocity "..self.vel.x.." "..self.vel.y)
	-- Update position
	self.x = self.x + (dt * self.vel.x)
	self.y = self.y + (dt * self.vel.y)
end



