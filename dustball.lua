require("lovepunk.entity")
require("holdable")
DustBall = PhysicsObject.new(0, 0, 8, 8)
DustBall.__index = DustBall


function DustBall.new(x, y, player)
	local self = setmetatable({}, DustBall)
	self.x = x-self.width/2
	self.y = y
	self.collisionLock = false
	self.player = player
	self.v = {x=0, y=0}
	self.type = "dustball"
	self.filters = {["level"]="touch"}
	self.image = love.graphics.newImage("assets/img/dustbullet.png")

	self.originX = self.width/2
	self.originY = self.height/2
	self.layer = 5
	self.isSolid = false

	self.lifetime = 20
	return self
end
function DustBall:update()

	rotation = vectorToAngle(self.v.x, self.v.y)
	PhysicsObject.update(self)
	self.lifetime = self.lifetime - 1
	if self.lifetime < 0 then self:die() end
	if (self:collide("level", self.x+self.v.x, self.y+self.v.y)) then self:die() end
end
function DustBall:draw()
	love.graphics.draw(self.image, self.x + self.width/2, self.y + self.height/2, rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
function DustBall:die()
	self.scene:remove(self)
end
