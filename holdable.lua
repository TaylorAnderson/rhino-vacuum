require("lovepunk.entity")
require("helpfuldog")

Holdable = Entity.new(0, 0, 14, 14)
Holdable.__index = Holdable


function Holdable.new(x, y,w, h)
	local self = setmetatable({}, Holdable)
	self.x = x
	self.y = y
	self.type = "carryable"
	self.width = w
	self.height = h
	self.beingCarried = false
	return self
end
function Holdable:update()
	if (self.player ~= nil and not self.beingCarried) then
		if (distance(self.player.x, self.player.y, self.x, self.y) < 60) then
			local isBeingSucked = false
			local facing = self.player.facing
			if self.player.vacuumState == VS_SUCKING and
				((facing == F_DOWN and self.y > self.player.y) or
				(facing == F_UP and self.y < self.player.y) or
				(facing == F_LEFT and self.x < self.player.x) or
				(facing == F_RIGHT and self.x > self.player.x)) then
				self.v = findVector({x=self.x, y=self.y}, {x=self.player.x, y=self.player.y}, 3)
			end
		end
	end

end
