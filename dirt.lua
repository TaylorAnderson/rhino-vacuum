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
	self.suckRange = 30
	self.img = love.graphics.newImage("assets/img/dirt.png")
	self.layer = 20
	self.pullLock = false
	return self
end
function Dirt:update()

	if (not self.pullLock) then
		Holdable.update(self)
	end
	if (self.beingPulled) then self.pullLock = true end
	if (self.pullLock) then
		local str = (40-distance(self.x, self.y, self.player.x, self.player.y))/5
		if (str < 0) then str = 0 end
		self.v = findVector({x=self.x, y=self.y}, {x=self.player.x+self.player.width/2, y=self.player.y + self.player.height/2}, str)
	end
	self.x = self.x + self.v.x
	self.y = self.y + self.v.y

end
function Dirt:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
