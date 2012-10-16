local gui = require("quickie")

menu = Gamestate.new()

-- lazy font loading
local fonts = setmetatable({}, {__index = function(t,k)
	local f = love.graphics.newFont(k)
	rawset(t, k, f)
	return f
end })

local menu_open = {
	main  = false,
	right = false,
	foo   = false,
	demo  = false
}
local check0   = {checked = true, label = "coucou"}
local check1   = {checked = false, label = "Checkbox"}
local check2   = {checked = false, label = "Another one"}
local input    = {text = ""}
local slider   = {value = .5}
local slider2d = {value = {.5,.5}}

--état du jeu
function menu:init()
	print('<menu:init()>')
	print('</menu:init()>')
end

function menu:enter()
	print('<menu:enter()>')
	love.graphics.setBackgroundColor(17,17,17)
	love.graphics.setFont(fonts[12])

	-- group defaults
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 25
	gui.group.default.spacing = 5
	print('</menu:enter()>')
end

function menu:leave()
	print('<menu:leave()>')
	print('</menu:leave()>')
end

--évènements
function menu:focus(focus)
	
end

function menu:keyreleased(key)
	
end

function menu:keypressed(key, unicode)
	gui.keyboard.pressed(key, unicode)
end

function menu:mousepressed(x, y, button)
	
end

function menu:mousereleased(x, y, button)
	
end

function menu:joystickpressed(joystick, button)
	
end

function menu:joystickreleased(joystick, button)
	
end

--calculs
function menu:update(dt)
	gui.group.push{grow = "down", pos = {5, 5}}
	if gui.Button{text = "Menu"} then
		menu_open.main = not menu_open.main
	end

	if menu_open.main then
		gui.group.push{grow = "right"}
		if gui.Button{text = "Group stacking"} then
			menu_open.right = not menu_open.right
		end

		if menu_open.right then
			gui.group.push{grow = "up"}
			if gui.Button{text = "Foo"} then
				menu_open.foo = not menu_open.foo
			end
			if menu_open.foo then
				gui.Button{text = "???"}
			end
			gui.group.pop{}

			gui.Button{text = "Bar"}
			gui.Button{text = "Baz"}
		end
		gui.group.pop{}

		if gui.Button{text = "Widget demo"} then
			menu_open.demo = not menu_open.demo
		end
		
		if gui.Button{text = "Game over"} then
			Gamestate.switch(gameover)
		end

	end
	gui.group.pop{}

	if menu_open.demo then
		gui.group.push{grow = "down", pos = {200, 80}}

		love.graphics.setFont(fonts[20])
		gui.Label{text = "Widgets"}
		love.graphics.setFont(fonts[12])
		
		gui.group.push{grow = "right"}
		gui.Button{text = "Button"}
		gui.Button{text = "Tight Button", size = {"tight"}}
		gui.Button{text = "Tight² Button", size = {"tight", "tight"}}
		gui.group.pop{}

		gui.group.push{grow = "right"}
		gui.Button{text = "", size = {2}}
		gui.Label{text = "Tight Label", size = {"tight"}}
		gui.Button{text = "", size = {2}}
		gui.Label{text = "Center Label", align = "center"}
		gui.Button{text = "", size = {2}}
		gui.Label{text = "Another Label"}
		gui.Button{text = "", size = {2}}
		gui.group.pop{}

		gui.group.push{grow = "right"}
		gui.Checkbox{info = check0, size = {"tight", "tight"}}
		gui.Checkbox{info = check1, size = {"tight"}}
		gui.Checkbox{info = check2}
		gui.group.pop{}

		gui.group.push{grow = "right"}
		gui.Label{text = "Input", size = {70}}
		gui.Input{info = input, size = {300}}
		gui.group.pop{}

		gui.group.push{grow = "right"}
		gui.Label{text = "Slider", size = {70}}
		gui.Slider{info = slider}
		gui.Label{text = ("Value: %.2f"):format(slider.value), size = {70}}
		gui.group.pop{}

		gui.Label{text = "2D Slider", pos = {nil,10}}
		gui.Slider2D{info = slider2d, size = {250, 250}}
		gui.Label{text = ("Value: %.2f, %.2f"):format(slider2d.value[1], slider2d.value[2])}

	end
end

function menu:draw()
	gui.core.draw()
end

--adieu
function menu:quit()
	
end
