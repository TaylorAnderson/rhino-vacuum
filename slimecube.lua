require("lovepunk.entity")
SlimeCube = PhysicsObject.new(0, 0, gs, gs)
SlimeCube.__index = SlimeCube

function SlimeCube.new(x, y, v)
	local self = setmetatable({}, SlimeCube)
	self.x = x
	self.y = y-2
	self.v = v
	self.img = love.graphics.newImage("assets/img/slime-block.png")
	self.filters = {["level"]="touch"}
	self.collideTypes = {}
	self.type = "null"
	self.gravity = 0.1
	self.friction = 0.999

	self.addedPlayerCollide =false
	return self
end

function SlimeCube:update(dt)
	if self:collide("level", self.x+self.v.x, self.y+self.v.y) then self.type = "level" end
	if not self:collide("player", self.x, self.y) and not self.addedPlayerCollide then
		self.filters.player = "slide"
		table.insert(self.collideTypes, 0, "player")
		self.addedPlayerCollide = true
	end
	self.v.x = self.v.x * self.friction
	self.v.y = self.v.y + self.gravity
	PhysicsObject.update(self, dt)
end
function SlimeCube:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
