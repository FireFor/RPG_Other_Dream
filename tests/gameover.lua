gameover = gamestate.new()

--évènements
function gameover:keyreleased(key)
	gamestate.switch(menu)
end

function gameover:mousereleased(x, y, button)
	gamestate.switch(menu)
end

--dessins
function gameover:draw()
	love.graphics.print("Fin de partie.", 0, 0)
	love.graphics.print("Cliquez ou appuyez pour revenir au menu.", 0, 100)
end
