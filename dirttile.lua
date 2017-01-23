require("lovepunk.entity")
require("dirt")
DirtTile = Entity.new(0, 0, gs-2, gs-2)
DirtTile.__index = DirtTile


function DirtTile.new(x, y, player)
	local self = setmetatable({}, DirtTile)
	self.player = player
	self.x = x+1
	self.y = y+1
	self.type = ""
	self.layer = 11
	return self
end
function DirtTile:added()
	left = self:collide("level", self.x-2, self.y)
	right = self:collide("level", self.x+2, self.y)
	down = self:collide("level", self.x, self.y+2)
	up = self:collide("level", self.x, self.y-2)

	self.x = self.x - 1
	self.y = self.y - 1
	if (left) then
		self.scene:add(Dirt.new(self.x-1, self.y, self.player))
		self.scene:add(Dirt.new(self.x-1, self.y+4, self.player))
		self.scene:add(Dirt.new(self.x-1, self.y+8, self.player))
		self.scene:add(Dirt.new(self.x-1, self.y+12,self.player))
	end
	if (right) then
		self.scene:add(Dirt.new(self.x+gs-3, self.y,self.player))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+4,self.player))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+8,self.player))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+12,self.player))
	end
	if (down) then
		self.scene:add(Dirt.new(self.x, self.y + gs -3,self.player))
		self.scene:add(Dirt.new(self.x+4, self.y + gs -3,self.player))
		self.scene:add(Dirt.new(self.x+8, self.y + gs -3,self.player))
		self.scene:add(Dirt.new(self.x+12, self.y + gs -3,self.player))
	end
	if (up) then
		self.scene:add(Dirt.new(self.x, self.y - 1,self.player))
		self.scene:add(Dirt.new(self.x+4, self.y - 1,self.player))
		self.scene:add(Dirt.new(self.x+8, self.y - 1,self.player))
		self.scene:add(Dirt.new(self.x+12, self.y - 1,self.player))
	end
	self.scene:remove(self)


end
