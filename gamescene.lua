require("lovepunk.scene")
require("player")
require("tile")
require("enemy")
require("platform")
require("helpfuldog")
require("slime")
require ("bouncyball")
GameScene = Scene.new()
GameScene.__index = GameScene
local sti = require "libs.sti"

local halfWidth =(love.graphics.getWidth()/scale)/2
local halfHeight =(love.graphics.getHeight()/scale)/2
function GameScene.new()
	local self=setmetatable({}, GameScene)
	self.shakeIntensity = 0
	self.shakeTimer = 0

	self.oCameraX = 0

	self.shakeOffsetX = 0
	self.shakeOffsetY = 0
	return self
end
function GameScene:load()
	Scene.load(self)

	self.map1 = sti("assets/maps/map1.lua")
	self.map2 = sti("assets/maps/map2.lua")
	self.maps = {self.map1, self.map2}
	local mapx=0
	local mapy=0

	for _, map in pairs(self.maps) do
		for _, object in pairs(map.objects) do
			if (object.name == "player") then
				self.player = Player.new(object.x+mapx, object.y+mapy)
				self:add(self.player)
			end

			if (object.name == "bouncyball") then
				self:add(BouncyBall.new(object.x + mapx, object.y + mapy))
			end
		end
		self.camera.x = -(self.player.x - halfWidth + 40)
		local layer = map.layers["tiles"].data
		for x in ipairs(layer) do
			for y in ipairs(layer) do
				if layer[x][y] ~= nil then
					self:add(Tile.new((y-1)*gs+mapx, (x-1)*gs+mapy))
				end
			end
		end
		mapx = mapx + map.layers["tiles"].width * 8
		self.bounds.width = self.bounds.width + map.layers["tiles"].width * 8
	end
	self.bounds.height = self.maps[1].layers["tiles"].height * gs
end
function GameScene:update(dt)
	Scene.update(self, dt)

	if (pressing("right")) then self.camera.x = self.camera.x - 5 end
	if (pressing("left")) then self.camera.x = self.camera.x + 5 end
	self.camera.y = -(self.player.y - halfHeight) + self.shakeOffsetY;
	self.camera.x = clamp(-(self.player.x - halfWidth + 40)- self.player.width/2, self.camera.x, -(self.player.x - halfWidth - 40)-self.player.width/2)
	self.camera.x = clamp(-self.bounds.width + (love.graphics.getWidth()/scale) , self.camera.x, 0)
	self.camera.y = clamp(-self.bounds.height + (love.graphics.getHeight()/scale), self.camera.y, 0)

	self.shakeTimer = self.shakeTimer - dt
	if (self.shakeTimer > 0) then
		self.shakeOffsetX = randomRange(-self.intensity, self.intensity)
		self.shakeOffsetY = randomRange(-self.intensity, self.intensity)
	else
		self.shakeOffsetX = 0
		self.shakeOffsetY = 0
	end

end
function GameScene:draw()


	Scene.draw(self)
end
function GameScene:shake(duration, intensity)
	self.intensity = intensity or 5
	self.duration = duration or 1
	self.shakeTimer = duration
end
