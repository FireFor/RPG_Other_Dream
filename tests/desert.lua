local map = nil

desert = Gamestate.new()

--état du jeu
function desert:init()
	print('<desert:init()>')
	map = require("maps.desert")
	print(serpent.block(map))
	print('</desert:init()>')
end

function desert:enter()
	print('<desert:enter()>')
	
	print('</desert:enter()>')
end

function desert:leave()
	print('<desert:leave()>')
	print('</desert:leave()>')
end

--évènements
function desert:focus(focus)
	
end

function desert:keyreleased(key)
	
end

function desert:keypressed(key, unicode)
	Gamestate.switch(menu)
end

function desert:mousepressed(x, y, button)
	
end

function desert:mousereleased(x, y, button)
	Gamestate.switch(menu)
end

function desert:joystickpressed(joystick, button)
	
end

function desert:joystickreleased(joystick, button)
	
end

--calculs
function desert:update(dt)
	
end

function desert:draw()
	love.graphics.print("Ceci n'est pas un désert.", 0, 0)
	love.graphics.print("Cliquez ou appuyez pour revenir au menu.", 0, 100)
end

--adieu
function desert:quit()
	
end
