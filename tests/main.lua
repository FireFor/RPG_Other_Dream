serpent = require("libs.serpent.serpent")
Gamestate = require("libs.hump.gamestate")

require("menu")

--un peu de debug
function love.draw()
	love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 740, 580)
end

function love.focus(focus)
	print(string.format('<love.focus(%q) />', tostring(focus)))
end

function love.keyreleased(key)
	print(string.format('<love.keyreleased(%q) />', key))
end

function love.keypressed(key, unicode)
	print(string.format('<love.keypressed(%q, %q) />', key, unicode))
end

function love.mousepressed(x, y, button)
	print(string.format('<love.mousepressed(%d, %d, %q) />', x, y, button))
end

function love.mousereleased(x, y, button)
	print(string.format('<love.mousereleased(%d, %d, %q) />', x, y, button))
end

function love.joystickpressed(joystick, button)
	print(string.format('<love.joystickpressed(%d, %d) />', joystick, button))
end

function love.joystickreleased(joystick, button)
	print(string.format('<love.joystickreleased(%d, %d) />', joystick, button))
end

function love.quit()
	print('<love.quit()>')
	love.timer.sleep(1) --debug
	print('</love.quit()>')
end

--en dernier pour Gamestate.registerEvents()
function love.load()
	print('<love.load()>')
	Gamestate.registerEvents()
	Gamestate.switch(menu)
	print('</love.load()>')
end
