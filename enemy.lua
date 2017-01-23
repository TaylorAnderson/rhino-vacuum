require("lovepunk.entity")
require("helpfuldog")
Enemy = PhysicsObject.new(0, 0, 18, 18)
Enemy.__index = Enemy
function Enemy.new(x, y, w, h)
	local self = setmetatable({}, Enemy)
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.friction = 0.6
	self.gravity = 0.2
	self.normalGravity = 0.2
	self.speed = gs/1.7
	self.accel = self.speed / 10
	self.v = {x=0, y=0}
	self.grounded = false
	self.type = "enemy"

	return self
end
function Enemy:update(dt)
	self.v.y = self.v.y + self.gravity
	PhysicsObject.update(self, dt)
end

function Enemy:die()
	self.scene:add(HitFx.new(self.x + self.width/2, self.y + self.height/2))
	self.scene:shake(0.2, 3)
	self.scene:remove(self)
end
function Enemy:flip(reverse)
	if (reverse) then
		self.originX = self.width + 4
		self.scaleX = -1
	else
		self.originX = 4
		self.scaleX = 1
	end
end
