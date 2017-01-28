require("lovepunk.entity")
VacuumIndicator = Entity.new(0, 0, 3, 2)
VacuumIndicator.__index = VacuumIndicator

function VacuumIndicator.new(player)
	local self = setmetatable({}, VacuumIndicator)
	self.image = love.graphics.newImage("assets/img/vacuum-indicator.png")
	self.player = player
	local anim8 = require "libs.anim8"
	local grid = anim8.newGrid(3, 2, self.image:getWidth(), self.image:getHeight())
	self.anim = anim8.newAnimation(grid('1-2', 1, '1-2', 2), 0.1)
	self.layer = -4
	self.offsetX = 0
	self.offsetY=9
	return self
end
function VacuumIndicator:update()

	self.offsetX=0
	self.offsetY=9

	if self.player.flipped then self.offsetX = 13 end
	if self.player.currentAnim.position == 2 or self.player.currentAnim.position == 4 then self.offsetY = 8 end
	self.x = self.player.x+self.offsetX
	self.y = self.player.y+self.offsetY
end
function VacuumIndicator:draw()
	self.anim:draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
end
