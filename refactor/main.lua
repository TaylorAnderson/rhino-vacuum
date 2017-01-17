
love.graphics.setDefaultFilter('nearest', 'nearest')
scale = 4;
scene = nil;
require("gamescene")

function love.load()
	changeScene(GameScene.new())
end
function love.update(dt)
	scene:update(dt)
end
function love.draw()
	love.graphics.scale(scale, scale)
	scene:draw()
end
function changeScene(newScene)
	scene = newScene
	scene:load()
end
