
require "util"
require "object"

Player = inheritsFrom(Object)
Player_mt = { __index = Player }

function Player:create(sprite, x, y)
	local p = {}--Object.create(sprite, x, y, 0, 1, 0, 0)
	p.x = x or 0
	p.y = y or 0
	p.scale = scale,1
	p.rot = rot
	p.acc = Vec:create(0,0)
	p.vel = Vec:create(vX,vY)
	p.maxVel = Vec:create()
	p.maxVel.x = 100
	p.maxVel.y = 100
	p.opacity = 255
	p.w = 0
	p.h = 0
	p.sprite = {}
	if sprite then
		p.sprite = Content:image(sprite)
			print("loaded sprite")
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


function Player:draw()
	--self.sprite = self.sprites[self.spriteFrame]
--	Object.draw(self)
	love.graphics.draw( self.sprite, self.x, self.y, self.rot, self.scale, self.scale )
end


function Player:onKeyDown(key, isRepeat)
	if key == "left" or key == "a" then
		self.x = self.x - 4
	elseif key == "right" or key == "d" then
		self.x = self.x + 4
	elseif key == "space" then
		
	end
	
end


function Player:update(dt)
	
end



