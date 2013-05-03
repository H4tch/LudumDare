
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
	
	-- The collision detection should work like this:
	-- 	  get the bounds of the tiles the player collides with.
	--      -> self.map:tilesCollidingWithRect( player )  
	-- 	  for each tile, check if the player collides with each side

	-- Todo: Check player's corners?
	-- Todo: Tiles need methods for collidedOnTop() and so on for each side.
	-- Need to get the edge the player collides with, not the player's edge
	-- that collides with a tile.

	-- Check Player's edges to see if they collide.
	--top
--[[
	if self.map:edgeCollidesWithTile(player.x+5, player.y, player.x+player.w-5, player.y) then
		player.vel.y = 0
		player.jumpVel = 0
		player.state.isJumping = false
		_,y = self.map:getAlignedPixel( player.x, player.y)
		player.y = y + self.map.tileSize
	end
	--right
	if player.vel.x > 0 and
	  self.map:edgeCollidesWithTile(player.x+player.w, player.y+5, player.x+player.w, player.y+player.h-5)
	  then
		player.vel.x = 0
		x,y = self.map:getAlignedPixel( player.x + player.w, player.y)
		-- this checks to make sure it actually collided with the left
		-- side of the block
		if (Rect.collidesWith( Rect:create(player.x,player.y,player.w,player.h),
		  Rect:create(x,y,1,self.map.tileSize)) ) then
			player.x = x - player.w
		end
	end
	--bottom
	-- The +5 offset causes a player to fall off a block when he is not
	-- quite over the edge. If this isn't here though, when the player
	-- falls and hits a block, it will register as bottom and side collision
	if self.map:edgeCollidesWithTile(player.x+5, player.y+player.h+1, player.x+player.w-5, player.y+player.h+1) then
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
	--left
	if player.vel.x < 0
	  and self.map:edgeCollidesWithTile(player.x, player.y+5, player.x, player.y+player.h-5)
	  then
		player.vel.x = 0
		x,_ = self.map:getAlignedPixel( player.x, player.y)
		player.x = x + self.map.tileSize
	end
]]--

	rect = self.map:getIntersection( player )

	if Rect.intersects(rect, Rect:create(p.x, p.y, 1, p.h)) then
		print "Left collision"
	end
	-- Check Left edge
	if self.map:edgeCollidesWithTile(player.x, player.y, player.x, player.y+player.h)
	  then
		player.vel.x = 0
		x,y = self.map:getAlignedPixel( player.x, player.y)
		c,r = self.map:getCellFromPixel(x,y)
		
		if self.map:getCell(c,r) ~= 0
		  and (self.map:getCell(c,r+1) ~= 0
		    or self.map:getCell(c,r+1) ~= 0)
		  then
			player.x = x + self.map.tileSize
		end
	end
	--right
	if player.vel.x > 0 and
	  self.map:edgeCollidesWithTile(player.x+player.w, player.y+5, player.x+player.w, player.y+player.h-5)
	  then
		player.vel.x = 0
		x,y = self.map:getAlignedPixel( player.x + player.w, player.y)
		-- this checks if it collided with the left side of the block
		if (Rect.collidesWith( Rect:create(player.x,player.y,player.w,player.h),
		  Rect:create(x,y,1,self.map.tileSize)) ) then
			player.x = x - player.w
		end
	end
	
	-- top
	if self.map:edgeCollidesWithTile(player.x+5, player.y, player.x+player.w-5, player.y) then
		player.vel.y = 0
		player.jumpVel = 0
		player.state.isJumping = false
		_,y = self.map:getAlignedPixel( player.x, player.y)
		player.y = y + self.map.tileSize
	end
	--bottom
	-- The +5 offset causes a player to fall off a block when he is not
	-- quite over the edge. If this isn't here though, when the player
	-- falls and hits a block, it will register as bottom and side collision
	if self.map:edgeCollidesWithTile(player.x+5, player.y+player.h+1, player.x+player.w-5, player.y+player.h+1) then
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



