require("lovepunk.entity")
require("helpfuldog")
require("physicsobject")

Holdable = PhysicsObject.new(0, 0, 14, 14)
Holdable.__index = Holdable


function Holdable.new(x, y,w, h)
	local self = setmetatable({}, Holdable)
	self.x = x
	self.y = y
	self.kind = ""
	self.type = "carryable"
	self.width = w
	self.height = h
	self.suckRange = 60
	self.beingPulled = false
	self.beingCarried = false
	self.filters={["level"]="cross"}
	return self
end
function Holdable:update()
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
	if (self.beingCarried) then
		self.v.x = 0
		self.v.y = 0
	end
	PhysicsObject.update(self)

end
function Holdable:drop()
end
