require("lovepunk.entity")
require("helpfuldog")
require("hiteffect")
Slime = Enemy.new(0, 0, 18, 18)
Slime.__index = Slime
function Slime.new(x, y)
	local self = setmetatable({}, Slime)
	self.x = x
	self.y = y
	print("here!")
	self.originX = -16
	self.v = {x=0.5, y=0}
	local rand = randomRange(1, 2)

	self.type = "enemy"
	self.image = love.graphics.newImage("assets/img/enemy.png")

	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(24, 24, self.image:getWidth(), self.image:getHeight())
	self.anim = anim8.newAnimation(grid('1-2', 1, '1-2', 2), 0.1)
	self.currentAnim = self.anim
	self.damageCounter = 0
	self.flickerCounter = 0
	self.flickerAmt = 5
	return self

end
function Slime:update(dt)
	if (self:collide("carryable", self.x, self.y)) then
		local carryable = self:collide("carryable", self.x, self.y)
		if (carryable.kind == "dustball") then
			local dustball = carryable
			if (magnitude(dustball.v) > 3) then
				self.scene:remove(dustball)
				self:die()
				return
			end
	 		local bounce = findVector({x=self.x, y=self.y}, {x=dustball.x, y=dustball.y}, magnitude(dustball.v))
			dustball.v.x = dustball.v.x + bounce.x
			dustball.v.y = dustball.v.y + bounce.y
		end
	end
	if (self.damageCounter > 0) then
		self.flickerCounter = self.flickerCounter + 1
		if (self.flickerCounter > self.flickerAmt) then
			self.visible = true
			if (self.flickerCounter > self.flickerAmt*2) then
				self.visible = false
				self.flickerCounter = 0
			end
		end
		self.damageCounter = self.damageCounter - 1
	else
		self.flickerCounter = 0
		self.visible = true
		local distToAdd = -1
		if (self.v.x > 0) then distToAdd = distToAdd + self.width+1 end

		local items, len = self.scene.bumpWorld:queryPoint(self.x + distToAdd, self.y + self.height + 1) -- 1 pixel below the left bottom corner of the object
		local foundLevel = false
		for i = 1, len do
			if (items[i].type == "level") then foundLevel = true end
		end
		if self:collide("level", self.x + self.v.x, self.y-1) or not foundLevel then self.v.x = self.v.x * -1 end
	end
	if (self.v.x > 0.5) then self.v.x = self.v.x * 0.9 end
	if (math.abs(self.v.x) < 0.5) then self.v.x = self.v.x +0.05 end
	self:updateAnimation(dt)
	Enemy.update(self, dt)
end

function Slime:draw()
	Enemy.draw(self)
	self.currentAnim:draw(self.image, self.x, self.y - 6, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
function Slime:updateAnimation(dt)
	self.currentAnim:update(dt)
	self:flip(self.v.x<0)
end
function Slime:takeDamage(e, amt)
	self.v.x = self.v.x + e.v.x
	self.v.y = self.v.y + e.v.y

	self.damageCounter = 120
end
function Slime:die()
	self.scene:add(HitFx.new(self.x, self.y))
	self.scene:remove(self)
end
