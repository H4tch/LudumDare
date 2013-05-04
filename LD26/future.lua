
require "future_map"

Future = inheritsFrom(Scene)
Future_mt = { __index = Future }

function Future:create()
--	local future = Scene:create()
	local future = {}
	setmetatable(future, Future_mt)
	future.background = love.graphics.newImage("assets/sunset2.png")
	
	--width = 2000
	
	h = love.graphics.getHeight()*3
	w = love.graphics.getWidth()
	sky = (h / 5)

	future.clouds = {}
	
	for i=1,100 do
		local x = 0
		local y = 0
		local cloud1 = Object:create(
				"assets/cloud_dark"..math.random(1,2)..".png", --sprite
				math.random(-50, w + 200),	-- X
				math.random(0, h), 	-- Y
				0, 1,				-- Rotation, scale
				0,					-- Velocity X
				0					-- Velocity Y
				)
		cloud1.y = (cloud1.y / 5) * 3 - 100
		
		local fade = (cloud1.y+1)
		cloud1.scale = -cloud1.y / (sky + (sky * .2) ) + 1
		cloud1.opacity = math.random(168,255) * cloud1.scale
		cloud1.vel.x = math.random(-40, -10) * (cloud1.scale)
		
		cloud1.w = cloud1.sprite:getWidth()
		cloud1.h = cloud1.sprite:getHeight()
		
		future.clouds[i] = cloud1 
	end
	
	future.camera = Rect:create()
	
	future.map = FutureMap:load()
	
	setmetatable(future,Future_mt)
	return future
end

function Future.createPlayer()
	return Player:create("assets/future/player.png", 64, 416)
end

function Future:nextScene()
	return "midieval"
end


function Future:prevScene()
	return "intro"
end


function Future:update(dt, player)
	self:updateClouds(dt)
	
	self.map:update(dt)

	local p = player
	local x = 0
	local y = 0
	
	rect = self.map:getIntersection( player )
--[[
	-- Check Left edge.
	if Rect.collidesWith(rect, Rect:create(p.x, p.y, 2, p.h)) then
		if math.floor(rect.w) == math.floor(p.w) then
		elseif rect.w < rect.h then
			print "left collided with wall"
			p.vel.x = 0
			x,_ = self.map:getAlignedPixel( p.x, p.y)
			player.x = x + self.map.tileSize
		end
	-- Check Right edge.
	elseif Rect.collidesWith(rect, Rect:create(p.x+p.w-1, p.y, 3, p.h)) then
		--if math.floor(rect.x+rect.w) == math.floor(p.x+p.w) then
		if rect.w < rect.h then
			print "right collided with wall"
			p.vel.x = 0
			x,_ = self.map:getAlignedPixel( p.x + p.w, p.y)
			p.x = x - p.w
		end
	end
	
	-- Check Top edge.
	if Rect.collidesWith(rect, Rect:create(p.x, p.y, p.w, 2)) then
		if math.floor(rect.y + rect.h) == math.floor(p.y + p.h) then
		elseif rect.w > rect.h then
			print "top collided with ceiling"
			p.vel.y = 0
			p.jumpVel = 0
			p.state.isJumping = false
			_,y = self.map:getAlignedPixel( p.x, p.y)
			p.y = y + self.map.tileSize
		end
--]]
	-- Check Bottom edge.
--[[	elseif self.map:edgeCollidesWithTile(player.x, player.y+player.h+1, player.x+player.w, player.y+player.h+1) then
		player.vel.y = 0
		_,y = self.map:getAlignedPixel( player.x, player.y + player.h)
		player.y = y - player.h
		player.state.inAir = false
		player.jumpVel = 0
		player.state.isJumping = false
	else
		player.state.inAir = true
		-- This would prevent 'double jumping'
		player.state.inJumping = true
	end	
--]]
--[[
	-- Check Bottom edge.
	elseif Rect.collidesWith(rect, Rect:create(p.x, p.y+p.h, p.w, 2)) then
	--elseif self.map:edgeCollidesWithTile(player.x, player.y+player.h+1, player.x+player.w, player.y+player.h+1) then
		if math.floor(rect.y) == math.floor(p.y) then
		elseif rect.w > rect.h then
			player.vel.y = 0
			_,y = self.map:getAlignedPixel( p.x, p.y + p.h)
			p.y = y - p.h
			p.state.inAir = false
			p.jumpVel = 0
			p.state.isJumping = false
		--else
		end
	else 
		p.state.inAir = true
		-- This would prevent 'double jumping'
		player.state.isJumping = true
	end
--]]


	-- Check for side collision.
	if rect.h == p.h and rect.w < rect.h then
		if rect.w == p.w then
		-- Left edge.
		elseif rect.x == p.x then
			print "left collided with wall"
			p.vel.x = 0
			x,_ = self.map:getAlignedPixel( p.x, p.y)
			player.x = x + self.map.tileSize
		
		-- Right edge.
		elseif rect.x + rect.w == p.x + p.w then
			print "right collided with wall"
			p.vel.x = 0
			x,_ = self.map:getAlignedPixel( p.x + p.w, p.y)
			p.x = x - p.w + .1
		end
	end
	
	-- rect = self.map:getBottomIntersection()
	-- rect = self.map:getColumnIntersection()
	
	-- Check top and bottom collisions.
	if rect.w == p.w or rect.w >= rect.h then
		-- Top edge.
		if rect.y == p.y then
			print "top collided with ceiling"
			p.vel.y = 0
			p.jumpVel = 0
			p.state.isJumping = false
			_,y = self.map:getAlignedPixel( p.x, p.y)
			p.y = y + self.map.tileSize
		
		-- Bottom edge.
		elseif rect.y + rect.h == p.y + p.h then
			print "bottom collided with floor"
			p.vel.y = 0
			_,y = self.map:getAlignedPixel( p.x, p.y + p.h)
			p.y = y - p.h
			--p.state.inAir = false
			p.jumpVel = 0
			p.state.isJumping = false
		end
	end
--]]
end



function Future:updateClouds(dt, player)
	love.graphics.setBlendMode("alpha")
	for i=1,table.getn(self.clouds) do
		-- If it passed the edge of the screen, wrap it to the other side.
		if self.clouds[i].x < window.x - (self.clouds[i].w * self.clouds[i].scale) then
			self.clouds[i].x = window.x + window.w + math.random(1,140)
		end
		self.clouds[i]:update(dt)
	end
end



function Future:draw(camera)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.background,0,0,0,1,1)
	love.graphics.setColor(0,0,0,255)
	self:drawClouds(camera)
	self.map:draw(camera)
	--self.map:getIntersection( Rect:create(100,450,100,150) ):print()
end


function Future:drawClouds(camera)
	for i=1,table.getn(self.clouds) do
		-- If collides with camera
		if window:collidesWith( self.clouds[i] ) then
			self.clouds[i]:draw(Rect:create(0,camera.y/20,0,0))
		end
	end
end


function Future:moveTo(x,y)
end

function Future:onKeyDown(key, isRepeat)
end

function Future:onKeyUp(key)
end

function Future:onMouseDown(x, y, button)
end

function Future:onMouseUp(x, y, button)
end



