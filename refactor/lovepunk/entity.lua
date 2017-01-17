Entity = {}
Entity.__index = Entity
function Entity.new(x, y, width, height)
	local self = setmetatable({}, Entity)
	self.x, self.y = x, y
	self.width, self.height = width, height
	self.image = nil;
	self.type = "null"
	self.layer=0
	self.scene=nil
	return self
end
function Entity:added()
end
function Entity:draw()
end
function Entity:update()
end
function Entity:collide(type, x, y)
	return scene:collide(self, type, x, y)
end
function Entity:removed()
end
