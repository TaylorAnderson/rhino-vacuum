require("lovepunk.entity")
require("holdable")
BouncyBall = Holdable.new(0, 0, 8,8)
BouncyBall.__index = BouncyBall


function BouncyBall.new(x, y, player)
	local self = setmetatable({}, BouncyBall)
	self.x = x
	self.y = y
	self.collisionLock = false
	self.player = player
	self.originX = 7
	self.originY = 7
	self.v.x = -1
	self.filters = {["level"]="bounce"}
	self.image = love.graphics.newImage("assets/img/bouncyball.png")
	self.layer = -5
	self.gravity = 0.1
	self.friction = 0.99
	self.rotation = 0
	self.bounciness = 1.9
	self.suckRange = 40

	self.isSolid = true
	return self
end
function BouncyBall:update()
	self.v.y = self.v.y + self.gravity
	self.v.x = self.v.x * self.friction
	self.rotation = self.rotation + toRadians(self.v.x*2)
	Holdable.update(self)
end
function BouncyBall:draw()
	love.graphics.draw(self.image, self.x + self.width/2, self.y + self.height/2, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
