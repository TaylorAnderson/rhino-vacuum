Scene = {} --defining ourselves
Scene.__index = Scene --so when we reference a nil key, we just return ourselves.
function Scene.new()
	local self = setmetatable({}, Scene)
	self.entities = {}
	self.loaded = false
	return self
end
function Scene:load()
	self.loaded = true
end
function Scene:update(dt)
	if not self.loaded then return end
	for _, v in pairs(self.entities) do
		v:update(dt)
	end
end
function Scene:draw()
	if not self.loaded then return end
	table.sort(self.entities, layerSort)
	for _, v in pairs(self.entities) do
		v:draw()
	end
end
function Scene:add(entity)
	if not self.loaded then return end
	table.insert(self.entities, entity)
	entity.scene = self;
	entity:added()
end
function Scene:remove(entity)
	if not entity then return end

	for i, v in pairs(self.entities) do
		if (v == entity) then
			table.remove(self.entities, i)
		end
	end

	entity.scene = nil
	entity:removed()
end
function Scene:collide(entity, type, x, y)
	checks = {}
	for _, v in pairs(self.entities) do
		if v.type == type then
			table.insert(checks, v)
		end
	end
	for _, v in pairs(checks) do
		if aabb(entity, x, y, v) then return v end
	end
	return nil
end

function layerSort(e1, e2)
	return e1.layer > e2.layer
end

function aabb(a, ax, ay, b)
	return ay <= b.y + b.height and ay + a.height > b.y and ax <= b.x + b.height and ax + a.height > b.x
end
