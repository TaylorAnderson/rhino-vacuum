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
dofile("libs/LuaXML-master/xml.lua")
dofile("libs/LuaXML-master/handler.lua")

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
	local files =
	{
		"assets/maps/level1.oel",
		"assets/maps/level2.oel"
	}
	local xPos = 0
	for i, v in ipairs(files) do
		local width, height = self:loadLevel(v, xPos, 0)
		xPos = xPos + width
	end
	print(self.player)
end
function GameScene:update(dt)
	Scene.update(self, dt)
	if (pressing("right")) then self.camera.x = self.camera.x - 5 end
	if (pressing("left")) then self.camera.x = self.camera.x + 5 end
	self.camera.y = -(self.player.y - halfHeight) + self.shakeOffsetY;
	self.camera.x = clamp(-(self.player.x - halfWidth + 40)- self.player.width/2, self.camera.x, -(self.player.x - halfWidth - 40)-self.player.width/2)

	if self.camera.x > 0 then self.camera.x = 0 end
	print(self.camera.x)
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

function GameScene:loadLevel(path, x, y)
	print(x)
	local xmltext = ""
	local f, e = io.open(path, "r")

	if f then
		xmltext = f:read("*all")
	else error(e) end

	local xml = simpleTreeHandler()
	local xmlparser = xmlParser(xml)
	xmlparser:parse(xmltext)

	local level = xml.root.level
	self.bounds.height = level._attr.height
	local tiles = level.tiles[1]
	local dirt = level.dirt[1]
	local xPos, yPos = 0, 0
	local entities = level.entities
	if (entities ~= "") then
		for i, v in pairs(level.entities) do
			local ex = tonumber(v._attr.x)
			local ey = tonumber(v._attr.y)
			if i == "player" then
				self.player = Player.new(ex+x, ey)
				self:add(self.player)
			end
			if (i == "bouncyball") then
				self:add(BouncyBall.new(ex+x, ey, self.player))
			end
			if (i == "slime") then
				self:add(Slime.new(ex+x, ey, self.player))
			end
		end
	end

	for i = 1, #tiles do
		local c = tiles:sub(i,i)
		if c == "1" then self:add(Tile.new(xPos+x, yPos)) end
		xPos = xPos + gs
		if c ~= "0" and c ~= "1" then
			xPos = 0
			yPos = yPos + gs
		end
	end
	xPos, yPos = 0, 0
	for i = 1, #dirt do
		local c = dirt:sub(i,i)
		if c == "1" then self:add(DirtTile.new(xPos+x, yPos, self.player)) end
		xPos = xPos + gs
		if c ~= "0" and c ~= "1" then
			xPos = 0
			yPos = yPos + gs
		end
	end
	f:close()
	return level._attr.width, level._attr.height
end
