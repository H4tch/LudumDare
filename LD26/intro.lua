
require "scene"

function Intro:create()
	local Intro = Scene:create()
	Intro.scene = {}
	Intro.currentScene = "future"
	return Intro
end


function Intro:update(dt)
end


function Intro:draw()
end


function Intro:moveTo(x,y)
end


function Intro:onKeyDown(key, isRepeat)
	-- handle 'menu' if there is one
end


function Intro:onKeyUp(key)
end


function Intro:onMouseDown(x, y, button)
end


function Intro:onMouseUp(x, y, button)
end


local Intro = Intro:create()
return intro
