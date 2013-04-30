

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
		map.rows = map.rows + 1
		map[map.rows] = {}
		
		map.columns = 0
		-- Read in each block number.
		for num in line:gmatch("%d+") do
			map.columns = map.columns + 1
			map[map.rows][map.columns] = tonumber(num)
		end		
	end
	
	-- Set columns to the number on the top row.
	map.columns = #map[1]
	
	-- Maps the block number to a texture.
	map.images = {
		[0]=Content.BlankTexture
		,[1]=I("ground1.png")
		,[2]=I("ground2.png")
	}
	
	map.tileSize = 32
	--map.tileSize = math.ceil( window.h / map.rows )
	
	return map
end



function FutureMap:update(dt)
	--for mob, self.mobs do
	--	mob:update(dt)
	--end
end


--todo add position for map
--map size is limited since it is only positive cooridinates
function FutureMap:tilesCollidingWithRect( rect )
	-- This box holds (col1,row1,col2,row2) which represents the tiles
	-- the rect intersects
	local box = Rect:create(
		math.floor((rect.x) / self.tileSize) + 1
		,math.floor((rect.y) / self.tileSize) + 1
		,math.floor((rect.x + rect.w-1) / self.tileSize) + 1
		,math.floor((rect.y + rect.h-1) / self.tileSize) + 1
		)
	if box.x < 1 then box.x = 1 end
	if box.y < 1 then box.y = 1 end
	if box.w > self.columns then box.w = self.columns end
	if box.h > self.rows then box.h = self.rows end
	
	if box.w < box.x then box.w = box.x end
	if box.h < box.y then box.h = box.y end
	
	if box.w < 1 then box.w = 1 end
	if box.h < 1 then box.h = 1 end
	if box.x > self.columns then box.x = self.columns end
	if box.y > self.rows then box.y = self.rows end
	return box
end


function FutureMap:edgeCollidesWithTile(x1,y1,x2,y2)
	local box = self:tilesCollidingWithRect(Rect:create(x1,y1,x2-x1,y2-y1))
	for c=box.x,box.w do
		for r=box.y,box.h do
			if self:getBlockType(c, r) ~= 0 then
				--print("Edge Collided with "..self:getBlockType(c, r).." at "..c..","..r)
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
				print("collided")
		--		return true
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


function FutureMap:getAlignedPixel(x,y)
	x = math.floor(x / self.tileSize) * self.tileSize
	y = math.floor(y / self.tileSize) * self.tileSize
	return x,y
end


function FutureMap:draw(camera)
	box = self:tilesCollidingWithRect(camera)
	for c=box.x,box.w do
		for r=box.y,box.h do
			local b = Rect:create( c*self.tileSize - self.tileSize, r*self.tileSize - self.tileSize, self.tileSize )
			tile = self.images[ self[r][c] ]
			if tile ~= nil then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw( tile, b.x-camera.x, b.y-camera.y, 0, 1, 1)
			else
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle( "line", b.x-camera.x, b.y-camera.y, self.tileSize, self.tileSize, 0, 1, 1)
			end
			--love.graphics.print( c..","..r, b.x-camera.x, b.y-camera.y, 0, .75, .75)
		end
	end
end


function FutureMap:getBounds()
	return Rect:create( 0, 0, self.columns*self.tileSize, self.rows*self.tileSize)
end

