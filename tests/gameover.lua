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
	love.graphics.print("Game over.", 0, 0)
end

--adieu
function gameover:quit()
	
end
