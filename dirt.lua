require("lovepunk.entity")
require("holdable")
Dirt = Holdable.new(0, 0, 4, 4)
Dirt.__index = Dirt


function Dirt.new(x, y, player, dir)

	local self = setmetatable({}, Dirt)
	self.x = x
	self.y = y
	self.v = {x=0, y=0}
	self.player = player
	self.type = "carryable"
	self.kind = "dirt"
	self.filters={["level"]="touch"}
	self.gravity = 0.05
	self.suckRange = 30
	self.img = love.graphics.newImage("assets/img/dirt.png")
	self.layer = 20
	self.pullLock = false
	self.dislodged = false
	self.friction = 0.99
	self.lodgeTimer = 0

	self.canBeSucked = true

	return self
end
function Dirt:update()

	if (not self.pullLock) then
		--holdable update without the physics schtuff
		self.beingPulled = false
		if (self.player ~= nil and not self.beingCarried) then
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
					self.v = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.facingOffset.x, y=self.player.y + self.player.facingOffset.y}, 3)
					self.beingPulled = true
				end
			end
		end
	end

	if (self.beingPulled) then self.pullLock = true end
	if (self.pullLock and not self.player.canSuck) then
		self.pullLock = false
	end

	if (self.pullLock) then
		self.dislodged = true
		self.lodgeTimer = 1
		str = 5
	 	self.v = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.facingOffset.x, y=self.player.y + self.player.facingOffset.y}, str)
	end

	if (self.dislodged and not self.pullLock) then
		self.v.y = self.v.y + self.gravity
	end
	self.v.x = self.v.x * self.friction
	self.lodgeTimer = self.lodgeTimer - 1
	if ((self:collide("level", self.x, self.y) or self:collide("dirt", self.x, self.y)) and self.dislodged and self.lodgeTimer < 0) then
		self.v.y = 0
		self.v.x = 0
		self.dislodged = false
	end
	if (self:collide("player", self.x, self.y) and self.player.canSuck and self.pullLock) then
		self.scene:remove(self)
		if self.player.dirtCount < self.player.maxDirtCount then
			self.player.dirtCount = self.player.dirtCount+1
		end
	end

	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
end
function Dirt:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
