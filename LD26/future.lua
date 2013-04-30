
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
	
	for i=1,75 do
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
--[[
	if self.map:getTileFromPixel(player.x, player.y) ~= 0 then
		player.vel.x = 0
		player.jumpVel = 0
	elseif self.map:getTileFromPixel(player.x+player.w, player.y) ~= 0 then
		player.vel.x = 0
		player.jumpVel = 0
	elseif self.map:getTileFromPixel(player.x, player.y+player.h) ~= 0 then
		player.vel.x = 0
		player.vel.y = 0
		player.jumpVel = 0
	elseif self.map:getTileFromPixel(player.x+player.w, player.y+player.h) ~= 0 then
		player.vel.x = 0
		player.vel.y = 0
		player.jumpVel = 0
	end
--]]
--	if self.map:collidesWithTile(player) then
--		player.vel.x = 0
--		player.vel.y = 0
--		player.jumpVel = 0
--	end
	
	-- Check edges
	--top
	if self.map:edgeCollidesWithTile(player.x, player.y, player.x+player.w, player.y) then
		print("top")
		player.vel.y = 0
	end
	--right
	if self.map:edgeCollidesWithTile(player.x+player.w, player.y, player.x+player.w, player.y+player.h) then
		print("right")
		player.vel.x = 0
	end
	--bottom
	if self.map:edgeCollidesWithTile(player.x, player.y+player.h, player.x+player.w, player.y+player.h) then
		print("bottom")
		player.vel.y = 0
	end
	--left
	if self.map:edgeCollidesWithTile(player.x, player.y, player.x, player.y+player.h) then
		print("left")
		player.vel.x = 0
	end
	
end




function Future:updateClouds(dt, player)
	love.graphics.setBlendMode("alpha")
	for i=1,table.getn(self.clouds) do
		-- If it passed the edge of the screen, wrap it to the other side.
		if self.clouds[i].x < window.x - (self.clouds[i].w * self.clouds[i].scale) then
			self.clouds[i].x = self.map.columns * self.map.tileSize
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



