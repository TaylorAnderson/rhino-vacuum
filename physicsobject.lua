require("lovepunk.entity")
PhysicsObject = Entity.new(0, 0, 1, 1)
PhysicsObject.__index = PhysicsObject

function PhysicsObject.new(x, y, w, h)
	local self = setmetatable({}, PhysicsObject)
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.v = {x=0, y=0}
	self.filters = {["level"]="slide"}
	return self
end


function PhysicsObject:update(dt)
	local actualX,actualY,cols = self.scene.bumpWorld:move(self, self.x+self.v.x, self.y+self.v.y, getFilter)
	for _, col in pairs(cols) do
		if col.other.type == "level" then
			self.v.x = self.v.x + col.normal.x*math.abs(self.v.x)
			self.v.y = self.v.y + col.normal.y*math.abs(self.v.y)
		end
	end
	self.x = actualX
	self.y = actualY
end
function getFilter(item,other)
	if (item.filters[other.type] == nil) then return "cross"
	else return item.filters[other.type] end
end
