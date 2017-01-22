require("lovepunk.entity")
require("helpfuldog")
require("hiteffect")
require("gust")
require("dustball")
Player = Entity.new(0, 0, gs, gs)
Player.__index = Player

S_INAIR = "inair"
S_ONGROUND = "onground"
S_NONE = "none"

VS_SUCKING = "sucking"
VS_BLOWING = "blowing"
VS_NONE = "none"

F_LEFT = "left"
F_RIGHT = "right"
F_DOWN = "down"
F_UP = "up"

function Player.new(x, y)
	local self = setmetatable({}, Player)
	self.x = x
	self.y = y
	self.facing = F_RIGHT
	self.keys= {
		left = moveLeft,
		right = moveRight,
		up = jump
	}
	self.vacuumState = VS_NONE
	self.friction = 0.6
	self.normalFriction = 0.6
	self.gravity = 0.2
	self.normalGravity = 0.2
	self.speed = gs/1.7
	self.accel = self.speed / 10
	self.v = {x=0, y=0}
	self.jumpSpeed = gs/3.5
	self.grounded = false
	self.type = "player"
	self.image = love.graphics.newImage("assets/img/rhino.png")
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(16, 16, self.image:getWidth(), self.image:getHeight())
	self.sideRunAnim = anim8.newAnimation(grid('1-4', 1), 0.1)
	self.upRunAnim = anim8.newAnimation(grid('1-4', 2), 0.1)
	self.downRunAnim = anim8.newAnimation(grid('1-4', 3), 0.1)
	self.currentAnim = self.sideRunAnim
	self.suckImg = love.graphics.newImage("assets/img/suck.png")
	local grid = anim8.newGrid(16, 16, self.suckImg:getWidth(), self.suckImg:getHeight())
	self.suckAnim = anim8.newAnimation(grid('1-4', 1), 0.05)

	self.collisionMap = {["level"]="slide", ["enemy"]="cross"}

	self.layer = -3
	self.flipped = false
	self.gustCooldown = 0
	self.modeSwitchCooldown = 0
	self.carrying = nil

	self.dirtCount = 0

	self.canSuck = false

	self.canSwitchToSuck = true

	self.flickerCounter = 0
	self.flickerAmt = 5
	self.damageCounter = 0
	self.controlLock = 0
	return self
end

function Player:update(dt)
	self.grounded = self:collide("level", self.x, self.y + 1) ~= nil
	self:checkState()
	self:stateUpdate()
	self.canSuck = self.vacuumState == VS_SUCKING and not self.carrying
	self:move()
	self:updateAnimation(dt)

	self.modeSwitchCooldown = self.modeSwitchCooldown - 1
	self.gustCooldown = self.gustCooldown - 1
	if self.currentAnim == self.upRunAnim then self.facing = F_UP end
	if self.currentAnim == self.downRunAnim then self.facing = F_DOWN end
	if self.currentAnim == self.sideRunAnim then
		if (self.flipped) then self.facing = F_LEFT
		else self.facing = F_RIGHT end
	end

	if self.carrying then
		local cOffset = {x=0, y=0}
		if (self.facing == F_LEFT) then cOffset.x = -self.width/2-6 end
		if (self.facing == F_RIGHT) then cOffset.x = self.width/2+6 end
		if (self.facing == F_DOWN) then
			cOffset.y = self.height/2+5
			if (self.flipped) then cOffset.x = -3
			else cOffset.x = 3 end
		end
		if (self.facing == F_UP) then
			cOffset.y = -self.height/2-5
			if (self.flipped) then cOffset.x = -6
			else cOffset.x = 6 end
		end
		self.carrying.x = self.x + cOffset.x
		self.carrying.y = self.y + cOffset.y
		self.carrying.v.x = 0
		self.carrying.v.y = 0
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
		self.damageCounter = self.damageCounter -1
	else
		self.flickerCounter = 0
		self.visible = true
	end
	self.controlLock = self.controlLock - 1
end

function Player:move()
	local _,_,cols = self.scene.bumpWorld:move(self, self.x + self.v.x, self.y + self.v.y, entityFilter)
	for _, c in pairs(cols) do
		if (c.other.type == "level") then
			self.v.x = self.v.x + c.normal.x*math.abs(self.v.x)
			self.v.y = self.v.y + c.normal.y*math.abs(self.v.y)
		end

		if (c.other.kind == "dirt" and self.vacuumState == VS_SUCKING and not self.carrying) then
			self.scene:remove(c.other)
			self.dirtCount = self.dirtCount + 1
			if (self.dirtCount > 30) then
				local dustball = DustBall.new()
				self.scene:add(dustball)
				self.carrying = dustball
				self.dirtCount = 0
			end
		end
		if (c.other.type == "carryable" and c.other.kind ~= "dirt") and self.canSuck then
			self.carrying = c.other
			c.other.beingCarried = true
		end
		if (c.other.type == "enemy") then
			self:takeDamage(c.other, 1)
		end
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y


	self.scene.bumpWorld:update(self, self.x, self.y)
end

function Player:draw()
	self.currentAnim:draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)

	if self.vacuumState == VS_SUCKING then
		local animX = self.x
		local animY = self.y
		local animRotation = 0
		if self.currentAnim == self.sideRunAnim then
			animX = self.x + self.width+6
			if (self.flipped) then
				animX = self.x-6
				animRotation = 180
			end
			animY = self.y + self.height/2 + 2
		end
		if self.currentAnim == self.upRunAnim then
			animY = self.y-6
			animX = self.x + self.width/2 + 6
			if (self.flipped) then animX = self.x+2 end
			animRotation = -90
		end
		if self.currentAnim == self.downRunAnim then
			animY = self.y + self.height/2 + 12
			animX = self.x + self.width/2+2
			if (self.flipped) then animX = self.x+6 end
			animRotation = 90
		end
		if not self.carrying then
			self.suckAnim:draw(self.suckImg, animX, animY, toRadians(animRotation), 1, 1, 6, 8)
		end
	end
end

function Player:checkState()
	if self.grounded then
		self.state = S_ONGROUND
	else self.state = S_INAIR
	end
end

function Player:stateUpdate()
	self.collisionMap.enemy = "cross"
	self:updateControls()
	self.v.x = self.v.x * self.friction
	self.v.y = self.v.y + self.gravity
	if (self.state == S_ONGROUND or self.state == S_INAIR) then
		self.friction = self.normalFriction
	end

	if (self.vacuumState == VS_BLOWING) then
		if self.gustCooldown <= 0 then
			local gustV = {x=0, y=0}
			if (self.currentAnim == self.upRunAnim) then gustV.y = -5 end
			if (self.currentAnim == self.sideRunAnim) then
				if (self.flipped) then gustV.x = -5
				else gustV.x = 5 end
			end
			if (self.currentAnim == self.downRunAnim) then gustV.y = 5 end

			gustV.x = gustV.x + self.v.x
			gustV.y = gustV.y + self.v.y

			self.v.x = self.v.x - gustV.x*0.9
			self.v.y = self.v.y - gustV.y*0.9
			if (self.carrying) then

				self.carrying.v.x = gustV.x
				self.carrying.v.y = gustV.y
				self:drop()
			else
				self.scene:add(Gust.new(self.x + self.width/2, self.y + self.height/2, gustV))
			end
			self.gustCooldown = 60
		end
	end
end
function Player:drop()
	self.carrying.beingCarried = false
	self.carrying:drop()
	self.carrying = nil


end
function Player:updateControls()
	if (self.controlLock > 0) then return end
	if pressing("left") then self:moveLeft() end
	if pressing("right") then self:moveRight() end
	if pressing("jump") and (self.grounded) then
		self:jump()
	end
	if (pressing("button1")) then self.vacuumState = VS_BLOWING
	elseif (self.vacuumState ~= VS_SUCKING) then self.vacuumState = VS_NONE end

	if (pressing("button2") and self.canSwitchToSuck) then
		if (self.vacuumState == VS_SUCKING) then self.vacuumState = VS_NONE
		else self.vacuumState = VS_SUCKING end
		self.canSwitchToSuck = false
	end

	if (not pressing("button2")) then self.canSwitchToSuck = true end
end

function Player:updateAnimation(dt)
	self.currentAnim:update(dt)
	if (self.vacuumState == VS_SUCKING) then self.suckAnim:update(dt) end


	if pressing("up") then
		self.currentAnim = self.upRunAnim
	elseif pressing("down") then
		self.currentAnim = self.downRunAnim
	else self.currentAnim = self.sideRunAnim end
	if pressing("left") or pressing("right") then
		self.currentAnim:resume()
	else
		self.currentAnim:gotoFrame(1)
	end

	if not self.grounded then self.currentAnim:gotoFrame(2) end

	if (pressing("right")) then
		self:flip(false)
	end
	if pressing("left") then self:flip(true) end
end

function Player:moveLeft()
	self.v.x = self.v.x - self.accel
end

function Player:moveRight()
	self.v.x = self.v.x + self.accel
end

function Player:jump()
	self.v.y = -self.jumpSpeed
end

function Player:flip(reverse)
	if (reverse) then
		self.originX = self.width
		self.scaleX = -1
		self.flipped = true
	else
		self.originX = 0
		self.scaleX = 1
		self.flipped = false
	end
end

function Player:takeDamage(e, dmg)
	local knockback = {x=0, y=0}
	knockback = findVector({x=self.x, y=self.y}, {x=e.x, y=e.y}, 7, true)
	if (knockback.y > 0) then knockback.y = 0 end
	self.v.x = self.v.x + knockback.x*2
	self.v.y = self.v.y + knockback.y
	self.damageCounter = 120
	self.controlLock = 60
end
