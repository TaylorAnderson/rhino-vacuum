require("lovepunk.entity")
SlimeCube = PhysicsObject.new(0, 0, gs, gs)
SlimeCube.__index = SlimeCube

function SlimeCube.new(x, y, v)
	local self = setmetatable({}, SlimeCube)
	self.x = x
	self.y = y-10
	self.v = v
	self.img = love.graphics.newImage("assets/img/slime-block.png")
	self.filters = {["level"]="touch"}
	self.type = "level"
	self.gravity = 0.5
	self.friction = 0.999
	return self
end

function SlimeCube:update(dt)
	self.v.x = self.v.x * self.friction
	self.v.y = self.v.y + self.gravity
	PhysicsObject.update(self, dt)
end
function SlimeCube:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
