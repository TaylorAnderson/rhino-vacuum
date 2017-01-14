require("lovepunk.entity")
require("holdable")
Dirt = Holdable.new(0, 0, 4, 4)
Dirt.__index = Dirt


function Dirt.new(x, y, player)
	local self = setmetatable({}, Dirt)
	self.x = x
	self.y = y
	self.v = {x=0, y=0}
	self.player = player
	self.type = "carryable"
	self.kind = "dirt"
	self.gravity = 0.1
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
		Holdable.update(self)
	end
	if (self.beingPulled) then self.pullLock = true end
	if (self.pullLock and self.player.vacuumState == VS_SUCKING) then
		local str = (40-distance(self.x, self.y, self.player.x, self.player.y))/5
		if (str < 0) then str = 0 end
		self.v = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.width/2, y=self.player.y + self.player.height/2}, str)
	end
	if (self.dislodged) then
		self.v.y = self.v.y + self.gravity
	end
	self.v.x = self.v.x * self.friction
	self.v.y = self.v.y * self.friction
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y
	if (self:collide("gust", x, y)) then
		local gust = self:collide("gust", x, y)
		self.v.x = self.v.x + gust.v.x/20
		self.v.y = self.v.y + gust.v.y/20 - 0.4
		self.dislodged = true
		self.lodgeTimer = 30
	end
	self.lodgeTimer = self.lodgeTimer - 1
	if (self:collide("level", self.x, self.y) and self.dislodged and self.lodgeTimer < 0) then
		self.v.y = 0
		self.v.x = 0
		self.dislodged = false
	end
end
function Dirt:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
