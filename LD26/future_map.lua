
--todo add position for map
--map size is limited since it is only positive cooridinates

FutureMap = {}
FutureMap_mt = { __index = FutureMap }

local dir = "assets/future/"

function I(s)
	return Content:image(dir..s)
end


function FutureMap.colorToId(r,g,b,a)
	-- Black
	if r == 0 and g == 0 and b == 0 and a == 255 then
		return 1
	end
	return 0
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
			r,g,b,a = map.mapData:getPixel(x,y)
			id = FutureMap.colorToId( r,g,b,a )
			map[x][map.mapData:getHeight()-1-y] = FutureMap.colorToId( r,g,b,a )
			map.rows = map.rows + 1
		end
		
		map.columns = map.columns + 1
	end
	
	--[[
	-- Get the number of rows
	for line in lines(dir.."map.dat") do
		if line:find("%d+%s+") then
			map[map.rows] = {}
			map.rowData[map.rows] = line
			map.rows = map.rows + 1
		end
	end
		
	-- Now read in the rows, in reverse order.
	for i=0, #map.rowData do
		map.columns = 0
		-- Read in each block number.
		for num in map.rowData[i]:gmatch("%d+") do
			map[map.rows-i-1][map.columns] = tonumber(num)
			map.columns = map.columns + 1
		end	
	end
	--]]
	--map.columns = #map[1]
	--print("Col: "..map.columns)
	
	-- Maps the block number to a texture.
	map.images = {
		[0]=Content.BlankTexture
		,[1]=I("rock1.png")
		,[2]=I("rock1.png")
		,[3]=I("rock1.png")
		,[4]=I("rock1.png")
	}
	map.tileSize = 48
	map.tileRes = 8
	-- tileScale
	map.scale = 1
	
	map.width = map.columns * map.tileSize
	map.height = map.rows * map.tileSize
	
	local scale = 1
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


-- Out of bounds counts as SOLID block, exept for the row.
function FutureMap:getBlockType(col, row)
	if self[col] then
		block = self[col][self.rows-row-1]
	else return 1
	end
	return (block or 0)
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
function FutureMap:getCellCoordinate(col,row)
	return (col * self.tileSize),(row * self.tileSize)
end
-- Get X,Y of a cell(C,R).
function FutureMap:getCellCoordinates(col,row)
	return (col * self.tileSize),(row * self.tileSize)
end

-- Get a rect of a cell(C,R)
function FutureMap:getCellBox(col,row)
	return Rect:create((col * self.tileSize), (row * self.tileSize), self.tileSize)
end

-- Get a rect of a range of cells(C1,R1,C2,R2), inclusive
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

function FutureMap:getAlignedPixel(x,y)
	return self:getCellCoordinates( FutureMap.getCellFromPixel(self,x,y) )
end


-- Get the intersection of a rect with the collidible tiles in the map.
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
	-- Experimental value that holds which row/column was intersected with last.
	local prevC
	
	-- Suggestions to handle a double collision (e.g. both sides collide)
	-- Contains either "left", "right", "up", or "down.
	local hPlacement
	local vPlacement
	
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
			-- Now get the intersection the rect has to the column.
			r1 = Rect.intersection(rect, self:getCellRangeBox(c,minC,c,maxC))
			-- It's a side collision of the intersection is taller than wide.
			if r1.w < r1.h and (r1.w > 3 or r1.h > 3) then
				-- Check collision with two columns.
				if not prevC then prevC = c else 
					-- Suggest moving to the smaller intersection result.
					local a1, a2
					a1 = (hRect.w + r1.w) * (hRect.h)
					a2 = (r1.w + hRect.w) * (r1.h)
					if a1 > a2 then
						hPlacement = "right"
					elseif a1 == a2 then
					else hPlacement = "left"
					end
					print("double side collision "..prevC.." "..c)
					print(hPlacement)
					r1:print()
				end
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
			-- Now get the intersection the rect has to the row.
			r1 = Rect.intersection(rect, self:getCellRangeBox(minC,r,maxC,r))
			-- It's a top/bottom collision of the intersection is wider than tall
			if r1.w > r1.h and (r1.w > 3 or r1.h > 3) then
				-- Check collision with two rows.
				if not prevC then prevC = c else
					-- Suggest moving to the smaller intersection result.
					local a1, a2
					a1 = (vRect.h + r1.h) * (vRect.w)
					a2 = (r1.h + vRect.h) * (r1.w)
					if a1 > a2 then
						vPlacement = "down"
					elseif a1 == a2 then
					else vPlacement = "up"
					end
				end
				if (vRect.w == 0 and vRect.h == 0)
				  or (vRect.x == r1.x or vRect.x + vRect.w == r1.x + r1.w)
				then
					vRect = Rect.combine(vRect, r1)
				end
			end
		end
	end
	return hRect,vRect,hPlacement,vPlacement
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

