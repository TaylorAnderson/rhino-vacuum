love.graphics.setDefaultFilter('nearest', 'nearest')
bgColor = {red=29, green=43, blue=83,alpha=1}
scene = nil;
gs = 16
scale = 4

require("lovepunk.scene")
require("gamescene")

function love.load()
	love.graphics.setLineStyle( 'rough' )
	love.window.setMode(12*64, 10*64)
	love.graphics.setBackgroundColor(bgColor.red, bgColor.green, bgColor.blue, bgColor.alpha)
	changeScene(GameScene.new())
end
function love.update(dt)
	scene:update(dt)
end
function love.draw()
	love.graphics.scale(scale, scale)
	scene:draw()
end
function love.keypressed(k)
	scene:keyPressed(k)
	if (k == "r") then love.event.quit("restart") end
end
function love.mousepressed(x, y, button, isTouch)
	scene:mousepressed(x, y, button)
end
function love.mousereleased(x, y, button, isTouch)
	scene:mousereleased(x, y, button)
end
function changeScene(newScene)
	scene = newScene
	scene:load()
end
