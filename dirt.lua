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

	return self
end
function Dirt:update()
	if (not self.pullLock) then
		--holdable update without the physics schtuff
		self.beingPulled = false
		if (self.player ~= nil and not self.beingCarried) then
			if (distance(self.player.x, self.player.y, self.x, self.y) < self.suckRange) then
				local isBeingSucked = false
				local facing = self.player.facing
				if self.player.vacuumState == VS_SUCKING and not self.player.carrying and
					((facing == F_DOWN and self .y > self.player.y) or
					(facing == F_UP and self.y < self.player.y) or
					(facing == F_LEFT and self.x < self.player.x) or
					(facing == F_RIGHT and self.x > self.player.x)) then
					self.v = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.width/2, y=self.player.y + self.player.height/2}, 3)
					self.beingPulled = true
				end
			end
		end
	end

	if (self.beingPulled) then self.pullLock = true end
	if (self.pullLock and not self.player.canSuck) then self.pullLock = false end

	if (self.pullLock) then
		self.dislodged = true
		self.lodgeTimer = 1
		local str = (20-distance(self.x, self.y, self.player.x, self.player.y))/10
		if (str < 0) then str = 0 end
		local pull = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.width/2, y=self.player.y + self.player.height/2}, str)
		self.v.x = self.v.x + pull.x
		self.v.y = self.v.y + pull.y
	end

	if (self.dislodged) then
		self.v.y = self.v.y + self.gravity
	end
	self.v.x = self.v.x * self.friction
	if (self:collide("gust", x, y)) then
		local gust = self:collide("gust", x, y)
		self.v.x = self.v.x + gust.v.x/20
		self.v.y = self.v.y + gust.v.y/40 - 0.2
		self.dislodged = true
		self.lodgeTimer = 1
	end
	self.lodgeTimer = self.lodgeTimer - 1
	if ((self:collide("level", self.x, self.y) or self:collide("dirt", self.x, self.y)) and self.dislodged and self.lodgeTimer < 0) then
		self.v.y = 0
		self.v.x = 0
		self.dislodged = false
	end
	if (self:collide("player", self.x, self.y) and self.player.canSuck) then
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
