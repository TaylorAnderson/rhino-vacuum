require("lovepunk.entity")
require("helpfuldog")
require("hiteffect")
require("gust")
require("dustball")
require("physicsobject")
require("vacuumindicator")
require("slimecube")
Player = PhysicsObject.new(0, 0, gs-2, gs)
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

SUCKTYPE_SLIME = "slime"

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
	self.originX = 1
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


	self.suckImg = love.graphics.newImage("assets/img/suck.png")
	self.image = love.graphics.newImage("assets/img/rhino.png")
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(16, 16, self.image:getWidth(), self.image:getHeight())
	local suckgrid = anim8.newGrid(16, 16, self.suckImg:getWidth(), self.suckImg:getHeight())

	self.sideRunAnim = anim8.newAnimation(grid('1-4', 1), 0.1)
	self.upRunAnim = anim8.newAnimation(grid('1-4', 2), 0.1)
	self.downRunAnim = anim8.newAnimation(grid('1-4', 3), 0.1)
	self.suckAnim = anim8.newAnimation(suckgrid('1-4', 1), 0.05)
	self.currentAnim = self.sideRunAnim
	self.defaultFilters = {["level"]="slide", ["enemy"]="cross"}
	self.filters = self.defaultFilters
	self.layer = -3
	self.flipped = false
	self.gustCooldown = 0
	self.modeSwitchCooldown = 0
	self.carrying = nil
	self.dirtCount = 0
	self.maxDirtCount = 120
	self.canSuck = false
	self.canSwitchToSuck = true
	self.flickerCounter = 0
	self.flickerAmt = 5
	self.damageCounter = 0

	self.facingOffset = {x=0, y=0}
	self.doubleCount = 0

	self.specialCarry = ""
	return self
end

function Player:added()
	self.vacuumIndicator = VacuumIndicator.new(self)
	self.scene:add(self.vacuumIndicator)
end

function Player:draw()

	self.currentAnim:draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
	self.vacuumIndicator.anim:gotoFrame(math.floor(self.dirtCount/self.maxDirtCount * 4)+1)
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

function Player:update(dt)

	self:updateControls()
	self:updateAnimation(dt)
	self:updateCollisions()
	self:updateForces()
	print(self.dirtCount)
	if self.damageCounter > 0 then self:updateDamageResponse() end
	self.facingOffset.x, self.facingOffset.y = 0, 0
	if (self.facing == F_LEFT) then
		self.facingOffset.x = 0
		self.facingOffset.y = self.height/2
	end
	if (self.facing == F_RIGHT) then
		self.facingOffset.x = self.width
		self.facingOffset.y = self.height/2
	end
	if (self.facing == F_DOWN) then
		self.facingOffset.y = self.height

		self.facingOffset.x = self.width/2

		if (self.flipped) then self.facingOffset.x = self.facingOffset.x-3
		else self.facingOffset.x = self.facingOffset.x + 3 end

	end
	if (self.facing == F_UP) then
		self.facingOffset.y = 0

		self.facingOffset.x = self.width/2
		if (self.flipped) then
			self.facingOffset.x = self.facingOffset.x-6
		else self.facingOffset.x = self.facingOffset.x + 3 end
	end

	self.doubleCount = self.doubleCount-1

	self.grounded = self:collide("level", self.x, self.y + 1) ~= nil

	self.canSuck = self.vacuumState == VS_SUCKING and not self.carrying
	self.modeSwitchCooldown = self.modeSwitchCooldown - 1

	self.gustCooldown = self.gustCooldown - 1


	PhysicsObject.update(self, dt)
end

function Player:updateControls()

	if pressing("left") then self.v.x = self.v.x - self.accel end
	if pressing("right") then self.v.x = self.v.x + self.accel end
	if pressing("jump") and (self.grounded) then self.v.y = -self.jumpSpeed end

	if (pressing("button1")) then
		self.vacuumState = VS_BLOWING
		if self.gustCooldown <= 0 then
			local gustV = {x=0, y=0}
			if (self.currentAnim == self.upRunAnim) then gustV.y = -5 end
			if (self.currentAnim == self.sideRunAnim) then
				if (self.flipped) then gustV.x = -5
				else gustV.x = 5 end
			end
			if (self.currentAnim == self.downRunAnim) then gustV.y = 5 end
			--gustV.x = gustV.x + self.v.x
			--gustV.y = gustV.y + self.v.y
			if self.dirtCount <= 0 and self.specialCarry == "" then
				self.scene:add(Gust.new(self.x + self.facingOffset.x, self.y + self.facingOffset.y, gustV))
				self.dirtCount = 0
			else
				if self.specialCarry == "" then
					local dustball = DustBall.new(self.x + self.facingOffset.x, self.y+self.facingOffset.y, self)
					dustball.v.x = gustV.x
					dustball.v.y = gustV.y
					dustball.v = normalize(dustball.v, 3)
					self.dirtCount = self.dirtCount-3

					if self.dirtCount < 0 then self.dirtCount = 0 end

					self.scene:add(dustball)
				elseif self.specialCarry == SUCKTYPE_SLIME then
					local slimeblock = SlimeCube.new(self.x, self.y)
					slimeblock.v.x = gustV.x
					slimeblock.v.y = gustV.y
					slimeblock.v = normalize(slimeblock.v, 5)
					self.scene:add(slimeblock)
					self.specialCarry = ""
				end
			end
			gustV = normalize(gustV, 5)
			self.gustCooldown = 6
		end
	elseif self.vacuumState ~= VS_SUCKING then
		self.vacuumState = VS_NONE
	end

	if (pressing("button2") and self.canSwitchToSuck) then
		if (self.vacuumState == VS_SUCKING) then self.vacuumState = VS_NONE
		else self.vacuumState = VS_SUCKING end
		self.canSwitchToSuck = false
	end
	if not pressing("button2") then self.canSwitchToSuck = true end
end

function Player:updateAnimation(dt)
	self.currentAnim:update(dt)
	if (self.vacuumState == VS_SUCKING) then self.suckAnim:update(dt) end

	if not self.animLocked then
		if self.flipped then self.facing = F_LEFT
		else self.facing = F_RIGHT end
		if pressing("up") then
			--if self.doubleCount > 0 then self.animLocked = true end
			self.doubleCount = 5
			self.currentAnim = self.upRunAnim
			self.facing = F_UP
		elseif pressing("down") then
			--if self.doubleCount > 0 then self.animLocked = true end
			self.doubleCount = 5
			self.currentAnim = self.downRunAnim
			self.facing = F_DOWN
		else self.currentAnim = self.sideRunAnim end
	end
	if pressing("left") or pressing("right") then
		self.currentAnim:resume()
	else
		self.currentAnim:gotoFrame(1)
	end

	if not self.grounded then self.currentAnim:gotoFrame(2) end

	if (pressing("right")) then
		self:flip(false)
	end
	if pressing("left") then
		self:flip(true)
	end
end

function Player:updateCollisions()
end

function Player:updateForces()
	self.v.x = self.v.x * self.friction
	self.v.y = self.v.y + self.gravity
	if (self.state == S_ONGROUND or self.state == S_INAIR) then
		self.friction = self.normalFriction
	end
end

function Player:drop()
	self.carrying.beingCarried = false
	self.carrying:drop()
	self.carrying = nil
end

function Player:flip(reverse)
	if (reverse) then
		self.originX = self.width-1
		self.scaleX = -1
		self.flipped = true
	else
		self.originX = 1
		self.scaleX = 1
		self.flipped = false
	end
end

function Player:takeDamage(e, dmg)
	if (self.damageCounter > 0) then return end
	local knockback = {x=0, y=0}
	knockback = findVector({x=self.x, y=self.y}, {x=e.x, y=e.y}, 7, true)
	if (knockback.y > 0) then knockback.y = 0 end
	self.v.x = knockback.x*2
	self.v.y = knockback.y
	self.damageCounter = 120
	self.controlLock = 60
end

function Player:updateDamageResponse()
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
end

function Player:suck(enemy)
	self.specialCarry = enemy.suckType
end
