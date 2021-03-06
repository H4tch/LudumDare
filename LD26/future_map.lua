
FutureMap = {}
FutureMap_mt = { __index = FutureMap }

local dir = "assets/future/"

function I(s)
	return Content:image(dir..s)
end

-- Returns the color's unique id(0-16777216) and it's opacity (1-255)
-- The opacity could be used for different collision properties.
-- 0 => Invisible(0,0,0,0)
-- 1 => Black(0,0,0,255)
function FutureMap.colorToBlockId(r,g,b,a)
	if a == 0 then		-- Invisible
		return 0,0
--[[
	elseif r == 0 and g == 0 and b == 0 and a == 255 then		-- Black
		return 1
	elseif r == 255 and g == 255 and b == 255 and a == 255 then	-- White
	elseif r == 255 and g == 0 and b == 0 and a == 255 then		-- Red
	elseif r == 0 and g == 255 and b == 0 and a == 255 then		-- Green
	elseif r == 0 and g == 0 and b == 255 and a == 255 then		-- Blue
	elseif r == 0 and g == 255 and b == 255 and a == 255 then	-- Cyan
	elseif r == 255  and g == 255 and b == 0 and a == 255 then	-- Yellow
	elseif r == 255 and g == 0 and b == 255 and a == 255 then	-- Magenta
--]]
	else	-- Calc each color's own unique id.
		return 1 + r + (g * (2^8)) + (b * (2^16)), a
	end
	return 0,0
end

function FutureMap.colorIdToColor(id)
	id = id - 1
	local b = math.floor(id / (2^16))
	id = id - (b * (2^16))
	local g = math.floor(id / (2^8))
	id = id - (g * (2^8))
	return id,g,b
end

function FutureMap:load()
	local map = {}
	setmetatable(map, FutureMap_mt)
	
	map.rows = 0
	map.columns = 0
	map.rowData = {}
	
	map.mapData = love.image.newImageData("/assets/future/map.png")
	local r,g,b,a
	local id
	
	for x=0,(map.mapData:getWidth()-1) do
		map[x] = {}
		
		map.rows = 0
		for y=0,(map.mapData:getHeight()-1) do
			id = nil
			r,g = nil,nil
			b,a = nil,nil
			
			r,g,b,a = map.mapData:getPixel(x,y)
			id = FutureMap.colorToBlockId( r,g,b,a )
			map[x][map.mapData:getHeight()-1-y] = id
			
			map.rows = map.rows + 1
		end
		
		map.columns = map.columns + 1
	end
	
	--map.columns = #map[1]
	--print("Col: "..map.columns)
	
	-- Maps the block number to a texture.
	map.images = {
		--[0]=Content.BlankTexture
		[0]=I("rock2.png")
		,[1]=I("rock1.png")
		,[2]=I("rock1.png")
		,[3]=I("rock1.png")
		,[4]=I("rock1.png")
	}
	map.tileSize = 32
	map.tileRes = 16
	-- tileScale
	map.scale = 1
	
	map.width = map.columns * map.tileSize
	map.height = map.rows * map.tileSize
	
	local scale = 1
	local newImage
	
	-- For each texture, resize it so it matches the tileSize and target resolution.
	for i=0,#map.images do
		v = map.images[i]
		v:setFilter("nearest","nearest")
		-- Minify
		if v:getWidth() ~= map.tileRes then
			scale = map.tileRes / v:getWidth()
			newImage = love.graphics.newCanvas(map.tileRes, map.tileRes)
			love.graphics.setCanvas(newImage)
			love.graphics.draw(v, 0, 0, 0, scale, scale)
			v = love.graphics.newImage(newImage:getImageData())
			map.images[i] = v
		end
		-- Embrace pixelization!
		v:setFilter("nearest","nearest")
		-- Magnify
		if v:getWidth() ~= map.tileSize then
			scale = map.tileSize / v:getWidth()
			newImage = love.graphics.newCanvas(map.tileSize, map.tileSize)
			love.graphics.setCanvas(newImage)
			love.graphics.draw(v, 0, 0, 0, scale, scale)
			map.images[i] = love.graphics.newImage(newImage:getImageData())
		end
	end
	
	
	return map
end



function FutureMap:update(dt)
	--for mob, self.mobs do
	--	mob:update(dt)
	--end
end



function FutureMap:tilesCollidingWithRect( rect )
	-- This box holds (col1,row1,col2,row2) which represents the tiles
	-- the rect intersects
	local box = Rect:create(
		math.floor((rect.x) / self.tileSize)
		,math.floor((rect.y) / self.tileSize)
		,math.floor((rect.x + rect.w-1) / self.tileSize)
		,math.floor((rect.y + rect.h-1) / self.tileSize)
	)

	return box
end


-- Out of bounds counts as SOLID block.
function FutureMap:getBlockType(col, row)
	if self[col] then
		block = self[col][self.rows-row-1]
	else return 1
	end
	return (block or 1)
end


function FutureMap:getTileFromPixel(x,y)
	local col = math.floor(x / self.tileSize)
	local row = math.floor((self.height - y) / self.tileSize)
	--if col < 0 then col = 0 end
	--if row < 0 then row = 0 end
	return self:getBlockType(col,row)
end


function FutureMap:getCell(col,row)
	return self:getBlockType(col,row)
end


-- Get X,Y of a cell(C,R).
function FutureMap:getCellCoordinates(col,row)
	return (col * self.tileSize),(row * self.tileSize)
end


-- Get a rect of a cell(C,R).
function FutureMap:getCellBox(col,row)
	return Rect:create((col * self.tileSize), (row * self.tileSize), self.tileSize)
end


-- Get a rect of a range of cells(C1,R1,C2,R2), inclusive.
function FutureMap:getCellRangeBox( c1, r1, c2, r2 )
	local x,y
	local r = Rect:create(0,0,0,0)
	x,y = self:getCellCoordinates(c1, r1)
	r.x = x
	r.y = y
	r.w = (c2 - c1 + 1) * self.tileSize
	r.h = (r2 - r1 + 1) * self.tileSize
	return r
end


-- Get the cell(C,R) of an X,Y pixel.
function FutureMap:getCellFromPixel(x,y)
	-- Changed to ceil() - 1 instead of floor() so
	return math.ceil(x / self.tileSize)-1, math.ceil(y / self.tileSize)-1
end


-- Get the upper-left pixel coordinate of the cell that X,Y is within.
function FutureMap:getAlignedPixel(x,y)
	return self:getCellCoordinates( FutureMap.getCellFromPixel(self,x,y) )
end


-- Get the intersection of a rect with the collidable tiles in the map.
-- Note: This is a very long function.
function FutureMap:getIntersection(rect)
	-- Used to iterate over a slice of the map tiles.
	local box = self:tilesCollidingWithRect( rect )
	
	-- Holds the final result of the side collisions.
	local hRect = Rect:create(0,0,0,0)
	
	-- Holds the final result of the top/bottom collisions.
	local vRect = Rect:create(0,0,0,0)
	
	-- Holds the intersection of the rect with the current column or row.
	local r1 = Rect:create(0,0,0,0)
	
	-- Holds the rect of a cell
	local cellRect = Rect:create(0,0,0,0)
	
	-- Holds the minimun and maximun cell in the row/column that is
	--collidible.
	local minC
	-- Holds the maximun cell in the row/column that is solid.
	local maxC
	
	for c=box.x,box.w do
		-- Reset bounds for each column.
		minC = nil
		maxC = nil
		for r=box.y,box.h do
			-- For each SOLID block in this column, get the upper and lower
			-- bounds of the row.
			if self:getBlockType(c, r) ~= 0 then
				if not minC then minC = r
				elseif r < minC then minC = r end
				
				if not maxC then maxC = r
				elseif r > maxC then maxC = r end
			end
		end
		if minC then
			-- Now get the intersection the rect has with the column.
			r1 = Rect.intersection(rect, self:getCellRangeBox(c,minC,c,maxC))
			-- It's a side collision if it's taller than wide.
			if r1.w < r1.h and (r1.w > 3 or r1.h > 3) then
				-- Combine/Create the vRect.
				if (hRect.w == 0 and hRect.h == 0)
				  or (hRect.y == r1.y or hRect.y + hRect.h == r1.y + r1.h)
				then
					hRect = Rect.combine(hRect, r1)
				end
			end
		end
	end
	
	for r=box.y,box.h do
		-- Reset bounds for each row.
		minC = nil
		maxC = nil
		for c=box.x,box.w do
			-- For each SOLID block in this row, get the upper and lower
			-- bounds of the column.
			if self:getBlockType(c, r) ~= 0 then
				if not minC then minC = c
				elseif c < minC then minC = c end
				
				if not maxC then maxC = c
				elseif c > maxC then maxC = c end
			end
		end
		if minC then
			-- Now get the intersection the rect has with the row.
			r1 = Rect.intersection(rect, self:getCellRangeBox(minC,r,maxC,r))
			-- It's a top/bottom collision if it's wider than tall.
			if r1.w > r1.h and (r1.w > 3 or r1.h > 3) then
				-- Combine/Create the vRect.
				if (vRect.w == 0 and vRect.h == 0)
				  or (vRect.x == r1.x or vRect.x + vRect.w == r1.x + r1.w)
				then
					vRect = Rect.combine(vRect, r1)
				end
			end
		end
	end
	return hRect,vRect
end


function FutureMap:draw(camera, debug)
	local box = self:tilesCollidingWithRect(camera)
	local index
	for c=box.x,box.w do
		for r=box.y,box.h do
			local b = self:getCellBox(c,r)
			index = self:getCell(c,r)
			tile = self.images[ index ]
			if tile ~= nil then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw( tile, b.x-camera.x, b.y-camera.y, 0, self.scale)
			else
				-- Draw the frame of an unknown block and print its number id.
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle( "line", b.x-camera.x, b.y-camera.y, self.tileSize, self.tileSize, 0, 1, 1)
				love.graphics.print( (index or ""), b.x-camera.x, b.y-camera.y, 0, 1)
			end
			if index ~= 0 and debug then
				love.graphics.print( (c.."."..(self.rows-r-1)), b.x-camera.x, b.y-camera.y, 0, .75, .75, 0, -self.tileSize/2)
			end
		end
	end
	--self:drawGrid(camera)
	--love.graphics.draw(self.mapData,0,0,0,1)
end


function FutureMap:drawGrid(camera)
	-- Default line drawing is "smooth" which is too slow.
	love.graphics.setLine(1, "rough")
	local p
	for r=1,(self.rows-1) do
		p = (r*self.tileSize)-camera.y
		love.graphics.line( 0, p, window.w, p )
		for c=1,self.columns do
			p = (c*self.tileSize)-camera.x
			love.graphics.line( p, 0, p, window.h )
		end
	end
end


function FutureMap:getBounds()
	-- The plus ones are for w/h are to account for the tile plus its w/h.
	return Rect:create( 0, 0, (self.columns)*self.tileSize, (self.rows)*self.tileSize)
end

