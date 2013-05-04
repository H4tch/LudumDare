
require "object"

-- A scene that tiles an image.

Tiler = {}
Tiler_mt = { __index = Tiler }


function Tiler:create( file )
	local s = {}
	setmetatable(s, Tiler_mt)
	s.tileSize = 64
	s.scale = 1
	s.tile = s:setImage(file)
	s.cols = math.floor(window.w / s.tileSize)
	s.rows = math.floor(window.h / s.tileSize)
	return s
end

function Tiler:setImage( file )
	self.tile = love.graphics.newImage( file )
	-- Embrace pixelization!
	self.tile:setFilter("nearest","nearest")
	-- Magnify
	if self.tile:getWidth() ~= self.tileSize then
		local scale = self.tileSize / self.tile:getWidth()
		local newImage = love.graphics.newCanvas(self.tileSize, self.tileSize)
		love.graphics.setCanvas(newImage)
		love.graphics.draw(self.tile, 0, 0, 0, scale, scale)
		self.tile = love.graphics.newImage(newImage:getImageData())
	end
	self.tile:setFilter("nearest","nearest")
	return self.tile
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
end

function Tiler:onKeyDown(key, isRepeat)
	if key == "up" then
		self:setTileSize(self.tileSize+16)
	elseif key == "down" then
		self:setTileSize(self.tileSize-16)
	end
end

function Tiler:onKeyUp(key)
end

function Tiler:onMouseDown(x, y, button)
end

function Tiler:onMouseUp(x, y, button)
end



