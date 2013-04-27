

local Content = {}
--Content_mt = {__index = Content}

Content.images = { ["nil"]= nil }

function Content:image(image)
	if not love.filesystem.exists(image) then
		print("File "..image.." does not exist.")
	else
		if not self.images[image] then
			self.images[image] = love.graphics.newImage(image)
		end
	end
	return self.images[image]
end

Content.BlankTexture = Content:image("assets/blank.png")

return Content
