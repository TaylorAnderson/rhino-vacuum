require("lovepunk.scene")
require("player")
require("tile")
require("enemy")
require("platform")
require("helpfuldog")
require("slime")
require ("bouncyball")
require("dirttile")
require("dirt")
require("face")
require("luaXML")
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



	-- self.map1 = sti("assets/maps/map1.lua")
	-- self.map2 = sti("assets/maps/map2.lua")
	-- self.maps = {self.map1, self.map2}
	-- local mapx=0
	-- local mapy=0
	-- for _, map in pairs(self.maps) do
	-- 	for _, object in pairs(map.objects) do
	-- 		if (object.name == "player") then
	-- 			self.player = Player.new(object.x+mapx, object.y+mapy)
	-- 			self:add(self.player)
	-- 		end
	-- 	end
	-- end
	-- local counter = 0
	-- for _, map in pairs(self.maps) do
	-- 	for _, object in pairs(map.objects) do
	-- 		if (object.name == "bouncyball") then
	-- 			self:add(BouncyBall.new(object.x + mapx, object.y + mapy, self.player))
	-- 		end
	--
	-- 		if (object.name == "slime") then
	-- 			self:add(Slime.new(object.x + mapx, object.y + mapy))
	-- 		end
	--
	-- 		if (object.name == "face") then
	-- 			self:add(Face.new(object.x + mapx, object.y + mapy))
	-- 		end
	-- 	end
	--
	-- 	self.camera.x = -(self.player.x - halfWidth + 40)
	--
	-- 	local dirtLayer = map.layers["dirt"].data
	-- 	local xPos, yPos = 1, 1
	-- 	local mapWidth = map.layers["tiles"].width
	-- 	local mapHeight = map.layers["tiles"].height
	-- 	local layer = map.layers["tiles"].data
	-- 	while yPos < mapHeight do
	-- 		if layer[yPos][xPos] ~= nil then
	-- 			self:add(Tile.new((xPos*gs-gs)+mapx, (yPos*gs)+mapy))
	-- 			counter = counter + 1
	-- 		end
	-- 		xPos = xPos +1
	-- 		if xPos > mapWidth then
	-- 			xPos = 1
	-- 			yPos = yPos + 1
	-- 		end
	-- 	end
	-- 	xPos, yPos = 1, 1
	-- 	local mapWidth = map.layers["dirt"].width
	-- 	local mapHeight = map.layers["dirt"].height
	-- 	while yPos < mapHeight do
	-- 		if dirtLayer[yPos][xPos] ~= nil then
	-- 			self:add(DirtTile.new((xPos*gs-gs)+mapx, (yPos*gs)+mapy, self.player))
	-- 		end
	-- 		xPos = xPos +1
	-- 		if xPos > mapWidth then
	-- 			xPos = 1
	-- 			yPos = yPos + 1
	-- 		end
	-- 	end
	--
	-- 	mapx = mapx + map.layers["tiles"].width * gs
	-- 	self.bounds.width = self.bounds.width + map.layers["tiles"].width * gs
	-- end
	--
	-- self.bounds.height = self.maps[1].layers["tiles"].height * gs
	-- print(counter)
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
function GameScene:shake(duration, intensity)
	self.intensity = intensity or 5
	self.duration = duration or 1
	self.shakeTimer = duration
end
