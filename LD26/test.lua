
Test = {}

function Test.rect()
	-- Rect intersection test
	love.graphics.setColor(255,0,0,255)
	r1 = Rect:create(128,512,64,64)
	love.graphics.rectangle("fill", r1:values())
	love.graphics.setColor(0,255,0,255)
	r2 = Rect:create(100,530,60,80)
	love.graphics.rectangle("fill", r2:values())
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle("fill", Rect.intersection(r1,r2):values())
	
	-- Rect combination test
	r1 = Rect:create(60,100,223,180)
	r2 = Rect:create(50,70,150,190)
	love.graphics.setColor(0,0,255,255)
	r3 = Rect.combine(r1,r2)
	love.graphics.rectangle("fill", r3.x-2,r3.y-2,r3.w+4,r3.h+4)
	love.graphics.setColor(255,0,0,255)
	love.graphics.rectangle("fill", r1:values())
	love.graphics.setColor(0,255,0,255)
	love.graphics.rectangle("fill", r2:values())
	
	-- Intersects test
	r1 = Rect:create(512,64,20,64)
	r2 = Rect:create(480,68,2,10)
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle("fill", r1:values())
	love.graphics.setColor(0,255,0,255)
	love.graphics.rectangle("fill", r2:values())
	
	if r1:intersects(r2) then
		love.graphics.setColor(255,0,0,255)
		love.graphics.rectangle("fill", r1:values())
	end
end
