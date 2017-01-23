require("lovepunk.entity")
require("dirt")
DirtTile = Entity.new(0, 0, gs, gs)
DirtTile.__index = DirtTile


function DirtTile.new(x, y, player)
	local self = setmetatable({}, DirtTile)
	self.player = player
	self.x = x
	self.y = y
	self.type = ""
	self.layer = 11
	return self
end
function DirtTile:added()
	left = self:collide("level", self.x-5, self.y)
	right = self:collide("level", self.x+5, self.y)
	down = self:collide("level", self.x, self.y+5)
	up = self:collide("level", self.x, self.y-5)

	if (left) then
		self.scene:add(Dirt.new(self.x-1, self.y, self.player, "left"))
		self.scene:add(Dirt.new(self.x-1, self.y+4, self.player, "left"))
		self.scene:add(Dirt.new(self.x-1, self.y+8, self.player, "left"))
		self.scene:add(Dirt.new(self.x-1, self.y+12,self.player, "left"))
	end
	if (right) then
		self.scene:add(Dirt.new(self.x+gs-3, self.y,self.player, "right"))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+4,self.player, "right"))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+8,self.player, "right"))
		self.scene:add(Dirt.new(self.x+gs-3, self.y+12,self.player, "right"))
	end
	if (down) then
		self.scene:add(Dirt.new(self.x, self.y + gs -3,self.player, "down"))
		self.scene:add(Dirt.new(self.x+4, self.y + gs -3,self.player, "down"))
		self.scene:add(Dirt.new(self.x+8, self.y + gs -3,self.player, "down"))
		self.scene:add(Dirt.new(self.x+12, self.y + gs -3,self.player, "down"))
	end
	if (up) then
		self.scene:add(Dirt.new(self.x, self.y - 1,self.player, "up"))
		self.scene:add(Dirt.new(self.x+4, self.y - 1,self.player, "up"))
		self.scene:add(Dirt.new(self.x+8, self.y - 1,self.player, "up"))
		self.scene:add(Dirt.new(self.x+12, self.y - 1,self.player, "up"))
	end


	self.scene:remove(self)


end
