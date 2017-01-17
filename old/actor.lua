require("lovepunk.entity")
Actor = Entity.new(0, 0, gs, gs)
Actor.__index = Actor


function Actor.new(x, y)
	local self = setmetatable({}, Actor)
	self.x = x
	self.y = y
	return self
end
function Actor:takeDamage(e, dmg)
	local knockback = {x=0, y=0}
	knockback = findVector({x=self.x, y=self.y}, {x=e.x, y=e.y}, 7, true)
	if (knockback.y > 0) then knockback.y = 0 end
	self.v.x = self.v.x + knockback.x*2
	self.v.y = self.v.y + knockback.y-1
	self.damageCounter = 120
end
