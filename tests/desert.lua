desert = gamestate.new()

local map

--état du jeu
function desert:init()
	map = require("maps.desert")
	print(serpent.block(map.tilesets))
end

--évènements
function desert:keyreleased(key)
	gamestate.switch(menu)
end

function desert:mousereleased(x, y, button)
	gamestate.switch(menu)
end

--calculs
function desert:update(dt)
	
end

--dessins
function desert:draw()
	love.graphics.print("Ceci n'est pas un désert.", 0, 0)
	love.graphics.print("Cliquez ou appuyez pour revenir au menu.", 0, 100)
end
