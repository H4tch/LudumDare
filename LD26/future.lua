
require "future_map"


Future = inheritsFrom(Scene)
Future_mt = { __index = Future }


function Future:create()
--	local future = Scene:create()
	local future = {}
	setmetatable(future, Future_mt)
	future.background = love.graphics.newImage("assets/sunset.png")
	
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


function Future:createPlayer()
--	local x,y = self.map:getCellCoordinate(105,100)
	local x,y = self.map:getCellCoordinate(25,110)
	return Player:create("assets/future/player.png", x, y)
end


function Future:nextScene()
	return "modern"
end


function Future:prevScene()
	return "intro"
end


function Future:update(dt, player, debug)
	-- Debug string.
	local s = ""
	
	self:updateClouds(dt)
	self.map:update(dt)
	--self.map:updatePlayer(dt)
	
	local p = Rect:create(player.x, player.y, player.w, player.h)
	local x = 0
	local y = 0
	
	-- Stores player's (Left|Right) intersection with the map.
	local hRect = Rect:create(0,0,0,0)
	-- Stores player's (Top|Bottom) intersection with the map.
	local vRect = Rect:create(0,0,0,0)
	
	-- Holds a string("left","right","up","down" to suggest a new placement
	-- of the player for if both sides collide on an axis collide with map.)
	local hPlacement, vPlacement
	
	hRect,vRect,hPlacement,vPlacement = self.map:getIntersection( p )
	
	-- If a small portion of the bottom or top intersects, then don't
	-- count it as a side collision. This is to avoid false positives.
	if (hRect.h < 15 and p.h >= 15)
	  and ( ((p.y < hRect.y) and (p.y + p.h == hRect.y + hRect.h)) --bottom
	    or  ((p.y == hRect.y) and (p.y + p.h > hRect.y + hRect.h)) ) --top
	then
		-- Do Nothing.
	-- If Left edge.
	elseif hRect.x == p.x then
		if hRect.w == p.w then
			-- Do nothing if both sides collide.
			if hPlacement then s = s.."Suggested to move "..hPlacement.."\n" end
		else
			x,_ = self.map:getAlignedPixel( p.x, p.y)
			player.x = x + self.map.tileSize
			-- EXPERIMENTAL, should be safe.
			if player.vel.x < 0 then
				player.vel.x = 0
			end
			player.state["collidesLeft"] = true
			player.state["collidesRight"] = false
		end
	
	-- If Right edge.
	elseif hRect.x + hRect.w == p.x + p.w then
		x,_ = self.map:getAlignedPixel( p.x + p.w, p.y)
		player.x = x - p.w
		-- EXPERIMENTAL, should be safe.
		if player.vel.x > 0 then
			player.vel.x = 0
		end
		player.state["collidesRight"] = true
		player.state["collidesLeft"] = false
	end
	
	-- If Top edge.
	if vRect.y == p.y then
		if vRect.h == p.h then
			-- Do nothing if top+bottom sides collide.
			if vPlacemnet then s = s.."Suggested to move "..vPlacement.."\n" end
		else
			_,y = self.map:getAlignedPixel( p.x, p.y)
			player.y = y + self.map.tileSize
			if player.vel.y < 0 then
				player.vel.y = 0
				player.jumpVel = 0
			end
			player.state["collidesTop"] = true
			player.state["collidesBottom"] = false
		end
		
	-- If Bottom edge.
	elseif vRect.y + vRect.h == p.y + p.h then
		_,y = self.map:getAlignedPixel( player.x, player.y + player.h)
		player.y = y - player.h
		if player.vel.y > 0 then
			player.vel.y = 0
			player.state.inAir = false
			player.jumpVel = 0
			player.state.isJumping = false
		end
		player.state["collidesbottom"] = true
		player.state["collidesTop"] = false
	end
	
	-- In no blocks under player, make him fall.
	if (self.map:getBlockType(self.map:getCellFromPixel(p.x+.5, p.y+p.h+2)) == 0
		  and self.map:getBlockType(self.map:getCellFromPixel(p.x+p.w-1, p.y+p.h+2)) == 0)
	then
		player.state.inAir = true
		player.state.isJumping = true
	end
	
	if debug then print(s) end
	s = ""
end



function Future:updateClouds(dt, player)
	love.graphics.setBlendMode("alpha")
	for i=1,table.getn(self.clouds) do
		-- If it passed the edge of the screen, wrap it to the other side.
		if self.clouds[i].x < window.x - (self.clouds[i].w * self.clouds[i].scale)
		then
			self.clouds[i].x = window.x + window.w + math.random(1,140)
		end
		self.clouds[i]:update(dt)
	end
end


function Future:draw(camera, debug)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.background,0,0,0,1,1)
	love.graphics.setColor(0,0,0,255)
	self:drawClouds(camera)
	self.map:draw(camera, debug)
end


function Future:drawClouds(camera)
	for i=1,table.getn(self.clouds) do
		if window:collidesWith( self.clouds[i] ) then
			self.clouds[i]:draw(Rect:create(0,camera.y/20,0,0))
		end
	end
end


function Future:getBounds()
	return self.map:getBounds()
end


function Future:onKeyDown(key, isRepeat)
end


function Future:onKeyUp(key)
end


function Future:onMouseDown(x, y, button)
end


function Future:onMouseUp(x, y, button)
end


