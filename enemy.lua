require("lovepunk.entity")
require("helpfuldog")
Enemy = PhysicsObject.new(0, 0, 18, 18)
Enemy.__index = Enemy
function Enemy.new(x, y, w, h, player)
	local self = setmetatable({}, Enemy)
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.player = player
	self.friction = 0.6
	self.gravity = 0.2
	self.normalGravity = 0.2
	self.speed = gs/1.7
	self.accel = self.speed / 10
	self.v = {x=0, y=0}
	self.grounded = false
	self.type = "enemy"
	self.suckRange = 50
	self.isSuckable = false
	self.pullLock = false
	self.damage = 1
	return self
end
function Enemy:update(dt)
	self.v.y = self.v.y + self.gravity

	if self.isSuckable then
		local items, len = self.scene.bumpWorld:querySegment(self.x + self.width/2,self.y+self.height/2,self.player.x + self.player.facingOffset.x,self.player.y + self.player.facingOffset.y)
		local count = 0
		for i, v in ipairs(items) do
			if (v.type == "level") then count = count + 1 end
		end
		if (distance(self.player.x, self.player.y, self.x, self.y) < self.suckRange and count == 0) then
			local isBeingSucked = false
			local facing = self.player.facing
			if self.player.vacuumState == VS_SUCKING and not self.player.carrying and
				((facing == F_DOWN and self .y > self.player.y) or
				(facing == F_UP and self.y < self.player.y) or
				(facing == F_LEFT and self.x < self.player.x) or
				(facing == F_RIGHT and self.x > self.player.x)) then
				self.v = findVector({x=self.x, y=self.y}, {x=self.player.x, y=self.player.y}, 3)
				self.beingPulled = true
			end
		end

		if (self.pullLock) then
			self.dislodged = true
			self.lodgeTimer = 1
			str = 5
			self.v = findVector({x=self.x+self.width/2, y=self.y+self.height/2}, {x=self.player.x+self.player.facingOffset.x - self.width, y=self.player.y + self.player.facingOffset.y-self.height}, str)
		end
	end

	PhysicsObject.update(self, dt)
	local player = self:collide("player", self.x, self.y)
	if player then
		if self.isSuckable then
			if player.canSuck then
				player:suck(self)
				self.scene:remove(self)
			end
		else
			player:takeDamage(self, damage)
		end
	end

end

function Enemy:die()
	self.scene:add(HitFx.new(self.x + self.width/2, self.y + self.height/2))
	self.scene:shake(0.2, 3)
	self.scene:remove(self)
end
function Enemy:flip(reverse)
	if (reverse) then
		self.scaleX = -1
	else
		self.scaleX = 1
	end
end
