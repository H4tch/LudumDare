

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
		,[3]= love.graphics.newImage("assets/future/ground1.png")
	}
	
	local height = math.ceil( love.graphics.getHeight() )
	map.tileSize = math.ceil( height / map.rows )
	
	return map
end



function FutureMap:update(dt)
	--for mob, self.mobs do
	--	mob:update(dt)
	--end
end


function FutureMap:collidesWithTile(rect)
	local col1 = math.ceil(rect.x / self.tileSize)
	local col2 = math.ceil(rect.x + rect.w / self.tileSize)
	local row1 = math.ceil(rect.y / self.tileSize)
	local row2 = math.ceil(rect.y + rect.h / self.tileSize)
	for c=col1,col2 do
		for r=row1,row2 do
			if self:getBlockType(c, r) ~= 0 then
		--		return true
			end
		end
	end
end


function FutureMap:getBlockType(col, row)
	if self[col] then
		block = self[col][row]
	end
	if block then
		return block else
	return 0
	end
end


function FutureMap:getTileFromPixel(x,y)
	local col = math.floor(x / self.tileSize)
	local row = math.floor(y / self.tileSize)
	return self:getBlockType(col,row)
end


function FutureMap:draw(camera)
	love.graphics.setColor(255,255,255,255)
	for row = 1, self.rows do
		for col = 1, self.columns do
			if self[row][col] ~= 0 then
				
				local r = Rect:create( col*self.tileSize - self.tileSize, row*self.tileSize - self.tileSize, self.tileSize, self.tileSize )
				if camera:collidesWith( r ) then
					if row == 1 then
					--print("R:"..row.." C:"..col.." Value:"..self[row][col].."rect["..r.x..","..r.y.." "..r.w.."x"..r.h.."]")
					end
					love.graphics.draw( self.images[ self[row][col] ], r.x-camera.x, r.y-camera.y, 0, 1, 1)
					love.graphics.rectangle( "line", r.x-camera.x, r.y-camera.y, 0, 1, 1)
				end
			end
		end
	end
	--love.graphics.rectangle("line", 0,0,40,50)
end


function FutureMap:getBounds()
	return Rect:create( 0, 0, self.columns*self.tileSize, self.rows*self.tileSize)
end

