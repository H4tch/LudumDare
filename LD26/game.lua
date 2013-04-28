
require "util"
require "player"
require "scene"
require "future"


Game = inheritsFrom( Scene )


function Game:init()
	Game.scene = {}
	Game.scene["future"] = Future:create()
	Game.currentScene = "future"
	Game.player = Game.scene[Game.currentScene].createPlayer()
	Game.camera = Rect:create( 0, 0, window.w, window.h )
end


function Game.update(dt)
	Game.player:update(dt)
	Game.camera:centerOver(Game.player)
	Game.camera.x = Game.camera.x + (Game.camera.w / 5)
	Game.camera.y = Game.camera.y - (Game.camera.h / 5)
	Game.camera:keepWithin(Game.scene[Game.currentScene].map:getBounds())
	--Game.camera:centerOver(Game.scene[Game.currentScene]:getPlayer())
	
	Game.scene[Game.currentScene]:update(dt, Game.player)
	
	--Game.scene[Game.currentScene]:update(Game.player)
	
	--print(Game.player.x..","..Game.player.y.."  "..Game.player.w.."x"..Game.player.h)
	--print(Game.camera.x..","..Game.camera.y.."  "..Game.camera.w.."x"..Game.camera.h)
end


function Game:draw()
	Game.scene[Game.currentScene]:draw(Game.camera)
	Game.player:draw(Game.camera)
	--drawHud()
end


function Game:moveTo(x,y)
end


function Game:onKeyDown(key, isRepeat)
	if key == "escape" then
		if Game.currentScene == "future" then
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


