require("lovepunk.entity")
Gust = Entity.new(0, 0, gs, gs)
Gust.__index = Gust


function Gust.new(x, y, v)
	local self = setmetatable({}, Gust)
	self.x = x
	self.y = y
	self.originX = self.width/2
	self.originY = self.height/2
	if (math.abs(v.y) > math.abs(v.x)) then
		if (v.y > 0) then self.rotation = toRadians(90) end
		if (v.y < 0) then self.rotation = toRadians(-90) end
	elseif math.abs(v.x) > math.abs(v.y) then
		if (v.x <= 0) then self.scaleX = -1 end
	end
	self.lifetime = 0.2
	self.type = "gust"
	self.image = love.graphics.newImage("assets/img/gust.png")
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(12, 16, self.image:getWidth(), self.image:getHeight())
	self.anim = anim8.newAnimation(grid('1-3', 1), {self.lifetime/2, self.lifetime/4, self.lifetime/4})

	self.counter = 0

	self.layer = -5
	self.v = v
	return self
end
function Gust:update(dt)
	self.anim:update(dt)
	self.lifetime = self.lifetime - dt
	if (self.lifetime < 0) then
		self.scene:remove(self)
	end
	self.v.x = self.v.x * 0.9
	self.v.y = self.v.y * 0.9
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
end
function Gust:draw()
	self.anim:draw(self.image, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
