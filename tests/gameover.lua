gameover = Gamestate.new()

--état du jeu
function gameover:init()
	print('<gameover:init()>')
	print('</gameover:init()>')
end

function gameover:enter()
	print('<gameover:enter()>')
	print('</gameover:enter()>')
end

function gameover:leave()
	print('<gameover:leave()>')
	print('</gameover:leave()>')
end

--évènements
function gameover:focus(focus)
	
end

function gameover:keyreleased(key)
	
end

function gameover:keypressed(key, unicode)
	Gamestate.switch(menu)
end

function gameover:mousepressed(x, y, button)
	
end

function gameover:mousereleased(x, y, button)
	Gamestate.switch(menu)
end

function gameover:joystickpressed(joystick, button)
	
end

function gameover:joystickreleased(joystick, button)
	
end

--calculs
function gameover:update(dt)
	
end

function gameover:draw()
	love.graphics.print("Fin de partie.", 0, 0)
	love.graphics.print("Cliquez ou appuyez pour revenir au menu.", 0, 100)
end

--adieu
function gameover:quit()
	
end
