
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
		,[3]=I("rock1.png")
	}
	map.tileSize = 128
	map.tileRes = 8
	map.scale = 1
	
	local scale = 0
	local newImage
	
	-- For each texture, resize it so it matches the tileSize and target resolution.
	for i,v in ipairs(map.images) do
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

-- TODO redo this function so it returns
--
-- Get the intersection of a rect with the collidible tiles in the map. 
-- If there is no intersection, it returns Rect(0,0,0,0)
function FutureMap:getIntersection(rect)
	local box = self:tilesCollidingWithRect( rect )
	
	local x,y
	-- Holds the intersection of the side collisions.
	local r1 = Rect:create(0,0,0,0)
	-- Holds the intersection of the top and bottom collisions.
	local r2 = Rect:create(0,0,0,0)
	
	for c=box.x,box.w do
			
		for r=box.y,box.h do
			-- If it is a SOLID block.
			if self:getBlockType(c, r) ~= 0 then
				-- Get the players intersection with it.
				tempRect = Rect.intersection(rect, self:getCellBox(c,r))
				
				
				--For each row in this column if the rect intersects a solid tile
				--if the intersection equals the width of the rect
				--or the rect also intersects the column,row+1
				--then it is a side collision
				
				--REDO
				--For each row in this column, it the rect intersects a solid tile
				--if the intersection's left or right side matches the combined rect's
				--or the height is the same then combine the rects <-- move this to the end of the column's intersection
				-- so if this returns a rect that equals the player's rect, that
				-- means he collides on both sides, and should *probably* be pushed up.
				--Now when the next column is tested and there is an intersection
				-- the combined rect won't be added to the first combined
				--intersection unless it matches the height
				
				--Then do the same for but row-major for the top/bottom.
				
				-- Check collision of rect's left and right sides with
				-- map's tiles.
				if rect.w < rect.h
				--if ( rect.y == tempRect.y and
				--	rect.y + rect.h == tempRect.y + tempRect.h )
				then
					r1 = Rect.combine( r1, tempRect )
				end
				-- Check collision of rect's top and bottom sides with
				-- map's tiles.
				if rect.w > rect.h
				--if ( rect.x == tempRect.x and
				--	rect.x + rect.w == tempRect.x + tempRect.w )
				then
					r2 = Rect.combine( r2, tempRect )
				end
				
				-- TODO handle cases of partial intersection
				
				-- Use for debugging the case the rect collides with
				-- the entire top/bottom and entire side
				if ( rect.y == tempRect.y and
					rect.y + rect.h == tempRect.y + tempRect.h )
					and  ( rect.x == tempRect.x and
					rect.x + rect.w == tempRect.x + tempRect.w )
				then
					print "Unhandled collision, player is completely within tile"
				end
			end
		end
	end
	return r1,r2
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
			if self[r] then
				index = self[r][c]
			end
			tile = self.images[ index ]
			if tile ~= nil then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw( tile, b.x-camera.x, b.y-camera.y, 0, self.scale)
				--if index ~= 0 then
				--	love.graphics.print( c.."."..r, b.x-camera.x, b.y-camera.y, 0, .75, .75, 0, -self.tileSize/2)
				--end
			else
				-- Draw the frame of an unknown block and print its number id.
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle( "line", b.x-camera.x, b.y-camera.y, self.tileSize, self.tileSize, 0, 1, 1)
				love.graphics.print( (index or ""), b.x-camera.x, b.y-camera.y, 0, 1)
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

