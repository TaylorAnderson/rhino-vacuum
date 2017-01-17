require("lovepunk.entity")
GameObject = Entity.new(0, 0, gs, gs)
GameObject.__index = GameObject

function GameObject.new(x, y)
	local self = setmetatable({}, GameObject)
	self.x = x
	self.y = y
	self.v = {x=0, y=0}
	return self
end

function GameObject:update(dt)
end

function GameObject:draw()
end
