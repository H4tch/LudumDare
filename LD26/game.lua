
require "util"
require "player"
require "scene"
require "future"
require "tiler"

Game = inheritsFrom( Scene )

require "test"

function Game:init()
	Game.scene = {}
	Game.scene["future"] = Future:create()
	Game.scene["tiler"] = Tiler:create("assets/future/rock1.png")
	Game.currentScene = "future"
	Game.player = Game.scene[Game.currentScene].createPlayer()
	Game.camera = Rect:create( 0, 0, window.w, window.h )
	
	--print("Map tileSize: "..Game.scene[Game.currentScene].map.tileSize)
	--print(Game.scene[Game.currentScene].tileSize)
	--Game.scene[Game.currentScene].map:tilesCollidingWithRect( Rect:create(32,32,0,0) ):print()
	x,y = Game.scene[Game.currentScene].map:getAlignedPixel(500, 200)
	c,r = Game.scene[Game.currentScene].map:getCellFromPixel(x, y)
end


function Game.update(dt)
	Game.player:update(dt)
	Game.camera:centerOver(Game.player)
	Game.camera.x = Game.camera.x + (Game.camera.w / 5)
	Game.camera.y = Game.camera.y - (Game.camera.h / 5)
	Game.camera:keepWithin(Game.scene[Game.currentScene]:getBounds())
	--Game.camera:centerOver(Game.scene[Game.currentScene]:getPlayer())
	
	Game.scene[Game.currentScene]:update(dt, Game.player)
	
	--Game.camera:print()
	--Rect.print(Game.player)
end


function Game:draw()
	Game.scene[Game.currentScene]:draw(Game.camera)
	--Test.rect()
	Game.player:draw(Game.camera)
	--drawHud()
	
	--local r2 = Game.scene[Game.currentScene].map:getIntersection(Rect:create(200,480,500,600))
	love.graphics.setColor(255,255,255,255)
	
	--local p = Game.player
	--Rect.print(p)
	--local r2 = Game.scene[Game.currentScene].map:getIntersection(Rect:create(p.x-5,p.y-5,p.w+10,p.h+10))
	--local r2 = Game.scene[Game.currentScene].map:getIntersection(Rect:create(p.x,p.y,p.w,p.h))
	--love.graphics.rectangle("fill", r2.x-Game.camera.x, r2.y-Game.camera.y, r2.w, r2.h)	
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
	end
	Game.scene[Game.currentScene]:onKeyDown(key, isRepeat)
	Game.player:onKeyDown(key, isRepeat)
end


function Game:onKeyUp(key)
	Game.player:onKeyUp(key, isRepeat)
end


function Game:onMouseDown(x, y, button)
end


function Game:onMouseUp(x, y, button)
end


