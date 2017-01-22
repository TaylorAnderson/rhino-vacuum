require("lovepunk.entity")
require("holdable")
DustBall = Holdable.new(0, 0, 14, 14)
DustBall.__index = DustBall


function DustBall.new(x, y, player)
	local self = setmetatable({}, DustBall)
	self.x = x
	self.y = y
	self.collisionLock = false
	self.player = player
	self.originX = self.width/2
	self.originY = self.height/2
	self.v = {x=0, y=0}
	self.type = "carryable"
	self.kind = "dustball"
	self.filters = {["level"]="bounce"}
	self.image = love.graphics.newImage("assets/img/dustball.png")
	self.layer = -5
	self.gravity = 0.1
	self.friction = 0.99
	self.rotation = 0
	return self
end
function DustBall:update()
	self.v.y = self.v.y + self.gravity
	self.v.x = self.v.x * self.friction
	self.rotation = self.rotation + toRadians(self.v.x*2)
	Holdable.update(self)
end

function DustBall:draw()
	love.graphics.draw(self.image, self.x + self.width/2, self.y + self.height/2, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
