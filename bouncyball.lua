require("lovepunk.entity")
require("holdable")
BouncyBall = Holdable.new(0, 0, 14, 14)
BouncyBall.__index = BouncyBall


function BouncyBall.new(x, y, player)
	local self = setmetatable({}, BouncyBall)
	self.x = x
	self.y = y
	self.collisionLock = false
	self.player = player
	self.originX = self.width/2
	self.originY = self.height/2
	self.v.x = -1
	self.image = love.graphics.newImage("assets/img/bouncyball.png")
	self.layer = -5
	self.gravity = 0.1
	self.friction = 0.99
	self.rotation = 0
	return self
end
function BouncyBall:update()
	self.v.y = self.v.y + self.gravity
	self.v.x = self.v.x * self.friction
	self.rotation = self.rotation + toRadians(self.v.x*2)
	self:move()
	Holdable.update(self)
end
function BouncyBall:move()
	local _,_,cols = self.scene.bumpWorld:move(self, self.x, self.y, entityFilter)
	local len = 0
	for _, c in pairs(cols) do
		len = len+1
		if (c.other.type == "level" and not self.collisionLock) then
			if (self.beingCarried) then
				self.player.v.x = self.player.v.x + c.normal.x*math.abs(self.player.v.x)*8
				self.player.v.y = self.player.v.y + c.normal.y*math.abs(self.player.v.y)*2.05
				self.collisionLock = true
			end
			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)*1.3
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)*1.3
		end
	end
	if (len == 1) then self.collisionLock = false end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.scene.bumpWorld:update(self, self.x, self.y)
end
function BouncyBall:draw()
	love.graphics.draw(self.image, self.x + self.width/2, self.y + self.height/2, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
