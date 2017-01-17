require("lovepunk.entity")
Face = Entity.new(0, 0, gs*2, gs*2)
Face.__index = Face


function Face.new(x, y)
	local self = setmetatable({}, Face)
	self.x = x
	self.y = y
	self.type = "level"
	self.image = love.graphics.newImage("assets/img/face.png")
	self.layer = 11
	return self
end

function Face:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
