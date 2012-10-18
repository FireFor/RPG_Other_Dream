desert = gamestate.new()

local map, tilesets

--état du jeu
function desert:init()
	map = require("maps.desert")
	
	tilesets = {}
	tilesets = setmetatable({}, {__index = function(t, k)
		local f = love.graphics.newFont(k)
		rawset(t, k, f)
		return f
	end})

	for id, tileset in ipairs(map.tilesets) do
		print(serpent.block(id))
		print(serpent.block(tileset))
	end
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
