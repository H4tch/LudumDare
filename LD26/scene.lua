
require "object"

Scene = {}
Scene_mt = { __index = Scene }


function Scene:create()
	local scene = {}
	scene.layers = {}
	setmetatable(Scene, Scene_mt)
	return scene
end

function Scene.createPlayer()
	return Player:create()
end

function Scene:nextScene()
	return ""
end

function Scene:prevScene()
	return ""
end

function Scene:update(dt, player)
end

function Scene:draw(camera)
end

function Scene:onKeyDown(key, isRepeat)
end

function Scene:onKeyUp(key)
end

function Scene:onMouseDown(x, y, button)
end

function Scene:onMouseUp(x, y, button)
end



