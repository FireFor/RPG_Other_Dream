--à mettre en dernier pour gamestate.registerEvents()
function love.load()
	serpent = require("libs.serpent.serpent")
	gamestate = require("libs.hump.gamestate")
	
	gamestate.registerEvents()
	
	require("menu")
	gamestate.switch(menu)
end
