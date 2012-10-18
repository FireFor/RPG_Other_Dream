menu = gamestate.new()

local gui

--état du jeu
function menu:init()
	gui = require("libs.quickie")
end

--évènements
function menu:keypressed(key, unicode)
	gui.keyboard.pressed(key, unicode)
end

--calculs
function menu:update(dt)
	gui.group.push{grow = "down", pos = {5, 5}}
	if gui.Button{text = "Carte : désert"} then
		require("desert")
		gamestate.switch(desert)
	end
	
	if gui.Button{text = "Fin de partie"} then
		require("gameover")
		gamestate.switch(gameover)
	end
	
	if gui.Button{text = "Quitter"} then
		love.event.quit()
	end
	gui.group.pop{}
end

--dessins
function menu:draw()
	gui.core.draw()
end
