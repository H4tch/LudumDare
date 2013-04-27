
require "util"
require "player"
require "scene"
require "future"

Game = inheritsFrom( Scene )

function Game:init()
	Game.scene = {}
	Game.scene["future"] = Future:create()
	Game.currentScene = "future"
	Game.player = Player:create()
	Game.scene[Game.currentScene].createPlayer(Game.player)
	Game.camera = Rect:create( 0, 0, love.graphics.getWidth(), love.graphics.getHeight() )
end


function Game.update(dt)
	Game.player:update(dt)
	Game.camera:centerOver(Game.player)
	Game.camera.x = Game.camera.x + (Game.camera.w / 3)
	Game.camera.y = Game.camera.y + (Game.camera.h / 3)
	Game.scene[Game.currentScene]:update(dt)
end


function Game:draw(camera)
	Game.scene[Game.currentScene]:draw(Game.camera)
	love.graphics.draw(Game.player.sprite, Game.player.x, Game.player.y, 0, 1)
	Game.player:draw()
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
end


function Game:onMouseDown(x, y, button)
end


function Game:onMouseUp(x, y, button)
end


