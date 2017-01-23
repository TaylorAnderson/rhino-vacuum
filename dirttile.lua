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
	left = self:collide("level", self.x-1, self.y)
	right = self:collide("level", self.x+1, self.y)
	down = self:collide("level", self.x, self.y+1)
	up = self:collide("level", self.x, self.y-1)

	if (left and right and up and down) then
		local xPos, yPos = 0, 0
		print("got here")
		while yPos ~= 16 do
			self.scene:add(Dirt.new(self.x+xPos, self.y +yPos, self.player, "none"))
			xPos = xPos + 4
			if xPos == 16 then
				yPos = yPos + 4
				xPos = 0
			end

		end
	else
		if (left) then
			self.scene:add(Dirt.new(self.x-1, self.y, self.player, "left"))
			self.scene:add(Dirt.new(self.x-1, self.y+4, self.player, "left"))
			self.scene:add(Dirt.new(self.x-1, self.y+8, self.player, "left"))
			self.scene:add(Dirt.new(self.x-1, self.y+12,self.player, "left"))

		elseif (right) then
			self.scene:add(Dirt.new(self.x+gs-3, self.y,self.player, "right"))
			self.scene:add(Dirt.new(self.x+gs-3, self.y+4,self.player, "right"))
			self.scene:add(Dirt.new(self.x+gs-3, self.y+8,self.player, "right"))
			self.scene:add(Dirt.new(self.x+gs-3, self.y+12,self.player, "right"))

		elseif (down) then
			self.scene:add(Dirt.new(self.x, self.y + gs -3,self.player, "down"))
			self.scene:add(Dirt.new(self.x+4, self.y + gs -3,self.player, "down"))
			self.scene:add(Dirt.new(self.x+8, self.y + gs -3,self.player, "down"))
			self.scene:add(Dirt.new(self.x+12, self.y + gs -3,self.player, "down"))

		elseif (up) then
			self.scene:add(Dirt.new(self.x, self.y - 1,self.player, "up"))
			self.scene:add(Dirt.new(self.x+4, self.y - 1,self.player, "up"))
			self.scene:add(Dirt.new(self.x+8, self.y - 1,self.player, "up"))
			self.scene:add(Dirt.new(self.x+12, self.y - 1,self.player, "up"))
		end
	end


	self.scene:remove(self)


end
