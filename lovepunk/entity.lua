Entity = {}
Entity.__index = Entity
function Entity.new(x, y, width, height)
	local self = setmetatable({}, Entity)
	self.x, self.y = x, y
	self.width, self.height = width, height
	self.v = {x=0, y=0}
	self.image = nil;
	self.type = "null"
	self.layer=0
	self.scene=nil
	self.useCollisions = false
	self.originX = 0
	self.originY = 0
	self.scaleX = 1
	self.scaleY = 1
	self.collisionMap={}
	return self
end
function entityFilter(item, other)
	if (item.collisionMap[other.type] == nil) then return "cross" end
	return item.collisionMap[other.type]
end
function Entity:added()
end
function Entity:draw()
end
function Entity:update()
end
function Entity:keyPressed(k)
end
function Entity:collide(type, x, y)
	return scene:collide(self, type, x, y)
end
function Entity:mousepressed(x, y, button)
end
function Entity:mousereleased(x, y, button)
end
function Entity:removed()
end
