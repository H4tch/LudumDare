

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



function FutureMap:draw(camera)
	love.graphics.setColor(255,255,255,255)
	for row = 1, self.rows do
		for col = 1, self.columns do
			if self[row][col] then
				local r = Rect:create( col*self.tileSize - self.tileSize, row*self.tileSize - self.tileSize, self.tileSize, self.tileSize )
				if camera:collidesWith( r ) then
					--print("R:"..row.." C:"..col.." Value:"..self[row][col])
					love.graphics.draw(self.images[ self[row][col] ], r.x, r.y, 0, 1, 1)
				end
			end
		end
	end
end



