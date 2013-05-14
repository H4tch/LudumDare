
require "util"
require "player"
require "scene"
require "future"
require "tiler"

Game = inheritsFrom( Scene )

require "test"

function Game:init()
	Game.debug = false
	Game.scene = {}
	Game.scene["future"] = Future:create()
	Game.scene["tiler"] = Tiler:create("assets/future/rock1.png")
	Game.currentScene = "future"
	Game.player = Game.scene[Game.currentScene]:createPlayer()
	Game.camera = Rect:create( 0, 0, window.w, window.h )
	
	--print("Map tileSize: "..Game.scene[Game.currentScene].map.tileSize)
	--print(Game.scene[Game.currentScene].tileSize)
	--Game.scene[Game.currentScene].map:tilesCollidingWithRect( Rect:create(32,32,0,0) ):print()
	x,y = Game.scene[Game.currentScene].map:getAlignedPixel(500, 200)
	c,r = Game.scene[Game.currentScene].map:getCellFromPixel(x, y)
end


function Game.update(dt)
	if Game.currentScene ~= "tiler" then
		Game.player:update(dt, Game.debug)
		Game.camera:centerOver(Game.player)
		Game.camera.x = Game.camera.x + (Game.camera.w / 5)
		Game.camera.y = Game.camera.y - (Game.camera.h / 5)
		Game.camera:keepWithin(Game.scene[Game.currentScene]:getBounds())
	end
	--Game.camera:centerOver(Game.scene[Game.currentScene]:getPlayer())
	
	Game.scene[Game.currentScene]:update(dt, Game.player, Game.debug)
	
	--Game.camera:print()
	--Rect.print(Game.player)
end


function Game:draw()
	Game.scene[Game.currentScene]:draw(Game.camera, Game.debug)
	--love.graphics.rectangle("fill",Game.scene[Game.currentScene].map:getCellRangeBox(2,7,3,9):offset(Game.camera):print():values())
	--Test.rect()
	if Game.currentScene ~= "tiler" then
		Game.player:draw(Game.camera)
	end
	--drawHud()
	
	--local r2 = Game.scene[Game.currentScene].map:getIntersection(Rect:create(200,480,500,600))
	love.graphics.setColor(255,255,255,255)
	
	local p = Game.player
	if Game.debug then
		local r1,r2 = Game.scene[Game.currentScene].map:getIntersection(Rect:create(p.x-1,p.y-1,p.w+2,p.h+2))
		love.graphics.setColor(20,20,130,255)
		love.graphics.rectangle("fill", r1.x-Game.camera.x-2, r1.y-Game.camera.y-2, r1.w+4, r1.h+4)
		love.graphics.setColor(130,20,20,255)
		love.graphics.rectangle("fill", r2.x-Game.camera.x-2, r2.y-Game.camera.y-2, r2.w+4, r2.h+4)
	end
end


function Game:onKeyDown(key, isRepeat)
	if key == "escape" then
		if Game.currentScene == "future" then
		end
	elseif key == "f1" then
		if Game.currentScene ~= "tiler" then
			Game.currentScene = "tiler"
		else
			Game.currentScene = "future"
		end
	elseif key == "f2" then
		Game.debug = not Game.debug
	end
	Game.scene[Game.currentScene]:onKeyDown(key, isRepeat)
	if Game.currentScene ~= "tiler" then
		Game.player:onKeyDown(key, isRepeat)
	end
end


function Game:onKeyUp(key)
	if Game.currentScene ~= "tiler" then
		Game.player:onKeyUp(key, isRepeat)
	end
end


function Game:onMouseDown(x, y, button)
end


function Game:onMouseUp(x, y, button)
end


