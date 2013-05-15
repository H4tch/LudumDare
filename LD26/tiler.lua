
require "object"

-- A scene that tiles an image.

Tiler = {}
Tiler_mt = { __index = Tiler }


function Tiler:create( file )
	local s = {}
	s.filename = file
	s.interval = 2
	s.refTime = 0
	setmetatable(s, Tiler_mt)
	s.scale = 1
	s.originalTile = Content:image(file)
	s.tileSize = s.originalTile:getWidth()
	s.tileRes = s.tileSize
	s.tile = s:setImage(file)
	s.cols = math.floor(window.w / s.tileSize)
	s.rows = math.floor(window.h / s.tileSize)
	return s
end


function Tiler:setImage( file )
	local tempTile = love.graphics.newImage( file )
	if not tempTile then
		return self.tile
	else self.tile = tempTile
	end
	-- Embrace pixelization!
	self.tile:setFilter("nearest","nearest")
	--[[
	-- Magnify
	if self.tile:getWidth() ~= self.tileSize then
		print "MAGNIFYING"
		local wScale = self.tileSize / self.tile:getWidth()
		local hScale = self.tileSize / self.tile:getHeight()
		local newImage = love.graphics.newCanvas(self.tileSize, self.tileSize)
		love.graphics.setCanvas(newImage)
		love.graphics.draw(self.tile, 0, 0, 0, wScale, hScale)
		self.tile = love.graphics.newImage(newImage:getImageData())
	end
	self.tile:setFilter("nearest","nearest")
	--]]
	
	self:setTileResolution(self.tileRes)
	return self.tile
end


--Todo, maybe use a Quad
function Tiler:setTileResolution(res, filter)
	print(res)
	local scale = 0
	local v = self.originalTile
	local newImage
	self.tileRes = res
	
	v:setFilter((filter or "nearest"),(filter or "nearest"))
	-- Minify
	if v:getWidth() ~= self.tileRes then
		scale = self.tileRes / v:getWidth()
		newImage = love.graphics.newCanvas(self.tileRes, self.tileRes)
		love.graphics.setCanvas(newImage)
		love.graphics.draw(v, 0, 0, 0, scale, scale)
		self.originalTile = love.graphics.newImage(newImage:getImageData())
	end
	
	self.originalTile:setFilter((filter or "nearest"),(filter or "nearest"))
	-- Magnify
	scale = self.tileSize / v:getWidth()
	newImage = love.graphics.newCanvas(self.tileSize, self.tileSize)
	love.graphics.setCanvas(newImage)
	love.graphics.draw(v, 0, 0, 0, scale, scale)
end


function Tiler:setTileSize(size)
	if size <= 0 then return end
	self.scale = (size / self.tileSize) * self.scale
	self.tileSize = size
	self.cols = math.ceil(window.w / self.tileSize)
	self.rows = math.ceil(window.h / self.tileSize)
end


function Tiler:draw(camera)
	for x=0,self.cols do
		for y=0,self.rows do
			if self.tile then
				love.graphics.draw(self.tile, x*self.tileSize, y*self.tileSize, 0, self.scale)
			end
		end
	end
end

function Tiler:getBounds()
	return window
end

function Tiler:nextScene()
	return ""
end

function Tiler:prevScene()
	return ""
end

function Tiler:update(dt, player)
	self.refTime = self.refTime + dt
	if self.refTime >= self.interval then
		print "Reloading.."
		self.refTime = 0
		self:setImage(self.filename)
	end
end

function Tiler:onKeyDown(key, isRepeat)
	if key == "return" then
		self:setImage(self.filename)
	elseif key == "up" then
		self:setTileSize(self.tileSize+16)
	elseif key == "down" then
		self:setTileSize(self.tileSize-16)
	elseif key == "left" then
		self:setTileResolution(self.tileRes-32)
	elseif key == "right" then
		self:setTileResolution(self.tileRes+32)
	end
end

function Tiler:onKeyUp(key)
end

function Tiler:onMouseDown(x, y, button)
end

function Tiler:onMouseUp(x, y, button)
end



