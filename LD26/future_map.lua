
--todo add position for map
--map size is limited since it is only positive cooridinates

FutureMap = {}
FutureMap_mt = { __index = FutureMap }

local dir = "assets/future/"

function I(s)
	return Content:image(dir..s)
end


function FutureMap:load()
	local map = {}
	setmetatable(map, FutureMap_mt)
	
	map.rows = 0
	map.columns = 0
	-- Read the map file.
	for line in lines(dir.."map.dat") do
		map[map.rows] = {}
		
		map.columns = 0
		-- Read in each block number.
		for num in line:gmatch("%d+") do
			map[map.rows][map.columns] = tonumber(num)
			map.columns = map.columns + 1
		end		
		map.rows = map.rows + 1
	end
	
	-- Set columns to the number on the top row.
	map.columns = #map[1]
	
	-- Maps the block number to a texture.
	map.images = {
		[0]=Content.BlankTexture
		,[1]=I("ground1.png")
		,[2]=I("ground2.png")
	}
	
	map.tileSize = 64
	map.scale = map.tileSize / map.images[1]:getWidth()
	
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
	--if box.x < 1 then box.x = 1 end
	--if box.y < 1 then box.y = 1 end
	--if box.w > self.columns then box.w = self.columns end
	--if box.h > self.rows then box.h = self.rows end
	
	--if box.w < box.x then box.w = box.x end
	--if box.h < box.y then box.h = box.y end
	
	--if box.w < 1 then box.w = 1 end
	--if box.h < 1 then box.h = 1 end
	--if box.x > self.columns then box.x = self.columns end
	--if box.y > self.rows then box.y = self.rows end
	return box
end


function FutureMap:edgeCollidesWithTile(x1,y1,x2,y2)
	local box = self:tilesCollidingWithRect(Rect:create(x1,y1,x2-x1,y2-y1))
	for c=box.x,box.w do
		for r=box.y,box.h do
			if self:getBlockType(c, r) ~= 0 or self[r] == nil or self[r][c] == nil then
				return true
			end
		end
	end
end


function FutureMap:collidesWithTile(rect)
	local box = self:tilesCollidingWithRect( rect )
	
	print("Player collides with these coordinates "..box.x..","..box.y.." "..box.w..","..box.h)
	
	for c=box.x,box.w do
		for r=box.y,box.h do
			if self:getBlockType(c, r) ~= 0 then
				return true
			end
		end
	end
end


function FutureMap:getBlockType(col, row)
	if self[row] then
		block = self[row][col]
	end
	return (block or 0)
end


function FutureMap:getTileFromPixel(x,y)
	local col = math.floor(x / self.tileSize)
	local row = math.floor(y / self.tileSize)
	if col < 1 then col = 1 end
	if row < 1 then row = 1 end
	return self:getBlockType(col,row)
end

function FutureMap:getCell(col,row)
	return self:getBlockType(col,row)
end

-- Get X,Y of a cell(C,R).
function FutureMap:getCellCoordinate(col,row)
	return (col * self.tileSize),(row * self.tileSize)
end

-- Get a rect of a cell(C,R)
function FutureMap:getCellBox(col,row)
	return Rect:create((col * self.tileSize), (row * self.tileSize), self.tileSize)
end

-- Get the cell(C,R) of an X,Y pixel.
function FutureMap:getCellFromPixel(x,y)
	return math.floor(x / self.tileSize), math.floor(y / self.tileSize)
end

-- Get the intersection of a rect with the collidible tiles in the map. 
-- If there is no intersection, it returns Rect(0,0,0,0)
function FutureMap:getIntersection(rect)
	local box = self:tilesCollidingWithRect( rect )
	
	local x,y
	-- Holds the bounds in which the player collides the map.
	local r2 = Rect:create(0,0,0,0)
	for c=box.x,box.w do
		for r=box.y,box.h do
			-- If it is a SOLID block.
			if self:getBlockType(c, r) ~= 0 then
				-- Get the players intersection with it.
				tempRect = Rect.intersection(rect, self:getCellBox(c,r))
				-- Now combine this with all other intersections.
				r2 = Rect.combine( r2, tempRect )
			end
		end
	end
	return r2
end

function FutureMap:getAlignedPixel(x,y)
	return self:getCellCoordinate( FutureMap.getCellFromPixel(self,x,y) )
end


function FutureMap:draw(camera)
	local box = self:tilesCollidingWithRect(camera)
	local index
	for c=box.x,box.w do
		for r=box.y,box.h do
			local b = self:getCellBox(c,r)
			index = self[r][c]
			tile = self.images[ index ]
			if tile ~= nil then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw( tile, b.x-camera.x, b.y-camera.y, 0, self.scale)
			else
				-- Draw the frame of an unknown block and print its number id.
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle( "line", b.x-camera.x, b.y-camera.y, self.tileSize, self.tileSize, 0, 1, 1)
				love.graphics.print( index, b.x-camera.x, b.y-camera.y, 0, 1)
			end
			if index ~= 0 then
				love.graphics.print( c..","..r, b.x-camera.x, b.y-camera.y, 0, .75, .75, 0, -self.tileSize/2)
			end
		end
	end
	--self:drawGrid(camera)
end


function FutureMap:drawGrid(camera)
	love.graphics.setLine(1, "rough")
	local p
	for r=1,self.rows do
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
	return Rect:create( 0, 0, (self.columns+1)*self.tileSize, (self.rows+1)*self.tileSize)
end

