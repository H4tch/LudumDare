
require "object"

Scene = {}
Scene_mt = { __index = Scene }


function Scene:create()
	local scene = {}
	scene.camera = Object:create(0,0)
	scene.background = nil
	scene.midground = nil
	scene.foreground = nil
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

function Scene:update(dt)
end

function Scene:draw()
end

function Scene:moveTo(x,y)
end

function Scene:onKeyDown(key, isRepeat)
end

function Scene:onKeyUp(key)
end

function Scene:onMouseDown(x, y, button)
end

function Scene:onMouseUp(x, y, button)
end



