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

end
