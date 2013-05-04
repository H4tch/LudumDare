
Content = require "content"
require "util"

window = Rect:create(0,0,love.graphics.getWidth(),love.graphics.getHeight())

require "game"

Keys = {}
stage = {}
--Stage["intro"] = require "intro"
stage["game"] = Game
currentStage = "game"
--titleText = love.graphics.newFont("", 40)
--text = love.graphics.newFont("", 20)


function love.load()
	love.graphics.setCaption("TimeRelease")
	Game:init()
end


function love.update(dt)
	stage[currentStage].update(dt)
	
end


function love.draw()
	love.graphics.setCanvas()
	love.graphics.clear()
	stage[currentStage].draw()
	love.graphics.setColor(255,255,255,255)
end



function love.mousepressed(x, y, button)
	stage[currentStage].onMouseDown(x,y,button)
end



function love.mousereleased(x, y, button)
	stage[currentStage].onMouseUp(x,y,button)
end



function love.keypressed(key)
	--print (key)
	local isRepeat = false
	if Keys[key] == true then
		isRepeat = true
	else
		Keys[key] = true
	end
	
	if currentStage == "intro" then
		if key == "escape" then
		elseif key == "space" or key == "return" then
			currentStage = "game"
		end
	end
	
	stage[currentStage]:onKeyDown(key, isRepeat)
end


function love.keyreleased(key)
	Keys[key] = false
	stage[currentStage]:onKeyUp(key)
end


function love.quit()
	love.graphics.print("Thanks for Playing!",300,50,0,1,1,0)
--	love.timer.sleep(1)
end

