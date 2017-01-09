require("lovepunk.entity")
BouncyBall = Entity.new(0, 0, 14, 14)
BouncyBall.__index = BouncyBall


function BouncyBall.new(x, y)
	local self = setmetatable({}, BouncyBall)
	self.x = x
	self.y = y
	self.originX = self.width/2
	self.originY = self.height/2
	self.v.x = -2
	self.type = "ball"
	self.image = love.graphics.newImage("assets/img/bouncyball.png")
	self.layer = 11
	self.gravity = 0.1
	self.friction = 0.99
	self.rotation = 0
	self.collisionMap = {["level"]="bounce"}
	return self
end
function BouncyBall:update()
	self.v.y = self.v.y + self.gravity
	self.v.x = self.v.x * self.friction
	self.rotation = self.rotation + toRadians(self.v.x*2)
	self:move()
end
function BouncyBall:move()
	local _,_,cols = self.scene.bumpWorld:move(self, self.x + self.v.x, self.y + self.v.y, entityFilter)
	for _, c in pairs(cols) do
		if (c.other.type == "level") then
			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)*1.9
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)*1.9
		end
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	self.scene.bumpWorld:update(self, self.x, self.y)
end
function BouncyBall:draw()
	love.graphics.draw(self.image, self.x + self.width/2, self.y + self.height/2, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end
