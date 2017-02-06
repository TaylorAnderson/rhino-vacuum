require("lovepunk.entity")
require("helpfuldog")
require("hiteffect")
Slime = Enemy.new(0, 0, 18, 18)
Slime.__index = Slime
function Slime.new(x, y)
	local self = setmetatable({}, Slime)
	self.x = x
	self.y = y
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
	self.oldDir = 0

	self.friction = 0.9
	self.gravity = 0.5
	self.health = 5
	return self

end
function Slime:update(dt)
	print(self.damageCounter)
	Enemy.update(self, dt)

	self.damageCounter = self.damageCounter - 1

	local distToAdd = 0
	if (self.v.x > 0) then distToAdd = distToAdd + self.width end

	local items, len = self.scene.bumpWorld:queryRect(self.x + distToAdd, self.y + self.height + 1, 2, 2) -- 1 pixel below the left bottom corner of the object
	local foundLevel = false
	for i, v in ipairs(items) do
		if (v.type == "level") then foundLevel = true end
	end
	if self:collide("level", self.x + self.v.x, self.y-1) or not foundLevel then
		self.v.x = self.v.x * -1
	end

	local ball = self:collide("dustball", self.x, self.y)
	if ball then
		self.scene:remove(ball)
		self:takeDamage(ball, 1)

	end
	self:updateAnimation(dt)

end

function Slime:draw()
	Enemy.draw(self)
	if self.damageCounter > 0 then love.graphics.setColor(255, 100, 100, 255) end
	self.currentAnim:draw(self.image, self.x, self.y - 6, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
function Slime:updateAnimation(dt)
	self.currentAnim:update(dt)

	self:flip(self.v.x<0)
end
function Slime:takeDamage(e, amt)
	if self.damageCounter > 0 then return end
	local push = normalize(e.v, 1)
	self.oldDir = self.v.x
	--self.v.x = push.x
	--self.v.y = push.y
	self.health = self.health - amt
	if self.health == 0 then self:die() end
	self.damageCounter = 30
end
function Slime:die()
	self.scene:add(HitFx.new(self.x, self.y))
	self.scene:remove(self)
end
