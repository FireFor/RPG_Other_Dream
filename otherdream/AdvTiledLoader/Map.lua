---------------------------------------------------------------------------------------------------
-- -= Map =-
---------------------------------------------------------------------------------------------------
-- Setup

-- Import the other classes
TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Mm]ap$", "") .. '.'
local Tile = require( TILED_LOADER_PATH .. "Tile")
local TileSet = require( TILED_LOADER_PATH .. "TileSet")
local TileLayer = require( TILED_LOADER_PATH .. "TileLayer")
local Object = require( TILED_LOADER_PATH .. "Object")
local ObjectLayer = require( TILED_LOADER_PATH .. "ObjectLayer")

-- Localize some functions so they are faster
local pairs = pairs
local ipairs = ipairs 
local assert = assert
local love = love
local table = table
local ceil = math.ceil
local floor = math.floor

-- Make our map class
local Map = {class = "Map"}
Map.__index = Map

---------------------------------------------------------------------------------------------------
-- Returns a new map
function Map:new(name, width, height, tileWidth, tileHeight, orientation, properties)

	-- Our map
	local map = setmetatable({}, Map)
	
	-- Public:
	map.name = name or "Unnamed Nap"				-- Name of the map
	map.width = width or 0							-- Width of the map in tiles
	map.height = height or 0						-- Height of the map in tiles
	map.tileWidth = tileWidth or 0					-- Width in pixels of each tile
	map.tileHeight = tileHeight or 0				-- Height in pixels of each tile
	map.orientation = orientation or "orthogonal"	-- Type of map. "orthogonal" or "isometric"
	map.properties = properties or {}				-- Properties of the map set by Tiled
	map.useSpriteBatch = true						-- If true then TileLayers use sprite batches.
	map.visible = true								-- If false then the map will not be drawn
	
	map.layers  = {}				-- Layers of the map indexed by name
	map.tilesets = {}				-- Tilesets indexed by name
	map.tiles = {}					-- Tiles indexed by id
	
	map.layerOrder = {}				-- The order of the layers. Callbacks are called in this order.				
	map.drawObjects = true			-- If true then object layers will be drawn
	map.drawRange = {}				-- Limits the drawing of tiles and objects. 
									-- [1]:x [2]:y [3]:width [4]:height
	
	-- Private:
	map._widestTile = 0				-- The widest tile on the map.
	map._highestTile = 0			-- The tallest tile on the map.
	map._tileRange = {}				-- The range of drawn tiles. [1]:x [2]:y [3]:width [4]:height
	map._previousTileRange = {}		-- The previous _tileRange. If this changed then we redraw sprite batches.
	map._redraw = true				-- If true then the map needs to redraw sprite batches.
	map._forceRedraw = false		-- If true then the next redraw is forced
	map._previousUseSpriteBatch = false   -- The previous useSpiteBatch. If this changed then we redraw sprite batches.
	map._tileClipboard	=	nil		-- The value that stored for TileLayer:tileCopy() and TileLayer:tilePaste()
	
	-- Return the new map
	return map
end

---------------------------------------------------------------------------------------------------
-- Creates a new tileset and adds it to the map. The map will then auto-update its tiles.
function Map:newTileSet(img, name, tilew, tileh, width, height, firstgid, space, marg, tprop)
	assert(name, "Map:newTileSet - The name parameter is invalid")
	self.tilesets[name] = TileSet:new(img, name, tilew, tileh, width, height, firstgid, space, marg, tprop)
	self:updateTiles()
	return self.tilesets[name]
end

---------------------------------------------------------------------------------------------------
-- Creates a new TileLayer and adds it to the map. The position parameter is the position to insert
-- the layer into the layerOrder.
function Map:newTileLayer(name, opacity, properties, position)
	if self.layers[name] then 
		error( string.format("Map:newTileLayer - The layer name \"%s\" already exists.", name) )
	end
	self.layers[name] = TileLayer:new(self, name, opacity, properties)
	table.insert(self.layerOrder, position or #self.layerOrder + 1, self.layers[name])
	return self.layers[name]
end

---------------------------------------------------------------------------------------------------
-- Creates a new ObjectLayer and inserts it into the map
function Map:newObjectLayer(name, color, opacity, properties, position)
	if self.layers[name] then 
		error( string.format("Map:newObjectLayer - The layer name \"%s\" already exists.", name) )
	end
	self.layers[name] = ObjectLayer:new(self, name, color, opacity, properties)
	table.insert(self.layerOrder, position or #self.layerOrder + 1, self.layers[name])
	return self.layers[name]
end

---------------------------------------------------------------------------------------------------
-- Add a custom layer to the map. You can include a predefined layer table or one will be created.
function Map:newCustomLayer(name, position, layer)
	if self.layers[name] then 
		error( string.format("Map:newCustomLayer - The layer name \"%s\" already exists.", name) )
	end
	self.layers[name] = layer or {name=name}
	self.layers[name].class = "CustomLayer"
	table.insert(self.layerOrder, position or #self.layerOrder + 1, self.layers[name])
	return self.layers[name]
end

---------------------------------------------------------------------------------------------------
-- Cuts tiles out of tilesets and stores them in the tiles tables under their id
-- Call this after the tilesets are set up
function Map:updateTiles()
	self.tiles = {}
	self._widestTile = 0
	self._highestTile = 0
	for _, ts in pairs(self.tilesets) do
		if ts.tileWidth > self._widestTile then self._widestTile = ts.tileWidth end
		if ts.tileHeight > self._highestTile then self._highestTile = ts.tileHeight end
		for id, val in pairs(ts:getTiles()) do
			self.tiles[id] = val
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Forces the map to redraw the sprite batches.
function Map:forceRedraw()
	self._redraw = true
	self._forceRedraw = true
end

---------------------------------------------------------------------------------------------------
-- Performs a callback on all map layers.
local layer
function Map:callback(cb, ...)
	if cb == "draw" then self:_updateTileRange() end
	for i = 1, #self.layerOrder do
		layer = self.layerOrder[i]
		if layer[cb] then layer[cb](layer, ...) end
	end
end

---------------------------------------------------------------------------------------------------
-- Draw the map.
function Map:draw()
	if self.visible then self:callback("draw") end
end

---------------------------------------------------------------------------------------------------
-- Returns the position of the layer inside the map's layerOrder. Can be the layer name or table.
function Map:layerPosition(layer)
	if type(layer) == "string" then layer = self.layers[layer] end
	for i = 1,#self.layerOrder do
		if self.layerOrder[i] == layer then return i end
	end
end

---------------------------------------------------------------------------------------------------
-- Returns the position of the layer inside the map's layerOrder. The passed layers can be the 
-- layer name, the layer tables themselves, or the layer positions.
function Map:swapLayers(layer1, layer2)
	if type(layer1) ~= "number" then layer1 = self:layerPosition(layer1) end
	if type(layer2) ~= "number" then layer2 = self:layerPosition(layer2) end
	local bubble = self.layers[layer1]
	self.layers[layer1] = self.layers[layer2]
	self.layers[layer2] = bubble
end

---------------------------------------------------------------------------------------------------
-- Removes a layer from the map
function Map:removeLayer(layer)
	if type(layer) ~= "number" then layer = self:layerPosition(layer) end
	layer = table.remove(self.layerOrder, layer)
	self.layers[layer.name] = nil
	return layer
end

---------------------------------------------------------------------------------------------------
-- Turns an isometric location into a world location. The unit length for isometric tiles is always
-- the map's tileHeight. This is both for width and height.
local h, tw, th
function Map:fromIso(x, y)
	h, tw, th = self.height, self.tileWidth, self.tileHeight
	return ((x-y)/th + h - 1)*tw/2, (x+y)/2
end

---------------------------------------------------------------------------------------------------
-- Turns a world location into an isometric location
local ix, iy
function Map:toIso(a, b)
	a, b = a or 0, b or 0
	h, tw, th = self.height, self.tileWidth, self.tileHeight
	ix = b - (h-1)*th/2 + (a*th)/tw 
	iy = 2*b - ix
	return ix, iy
end

---------------------------------------------------------------------------------------------------
-- Sets the draw range
function Map:setDrawRange(x,y,w,h)
	self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4] = x, y, w, h
end

---------------------------------------------------------------------------------------------------
-- Gets the draw range
function Map:getDrawRange()
	return self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4]
end

---------------------------------------------------------------------------------------------------
-- Automatically sets the draw range to fit the display
function Map:autoDrawRange(tx, ty, scale, pad)
	tx, ty, scale, pad = tx or 0, ty or 0, scale or 1, pad or 0
	if scale > 0.001 then
		self:setDrawRange(-tx-pad,-ty-pad,love.graphics.getWidth()/scale+pad*2,
						  love.graphics.getHeight()/scale+pad*2)
	end
end

----------------------------------------------------------------------------------------------------
-- Private Functions
----------------------------------------------------------------------------------------------------
-- This is an internal function used to update the map's _tileRange, _previousTileRange, and 
-- _specialRedraw
local x1, y1, x2, y2, highOffset, widthOffset, tr, ptr
function Map:_updateTileRange()
	
	-- Offset to make sure we can always draw the highest and widest tile
	heightOffset = self._highestTile - self.tileHeight
	widthOffset = self._widestTile - self.tileWidth
	
	-- Set the previous tile range
	for i=1,4 do self._previousTileRange[i] = self._tileRange[i] end
	
	-- Get the draw range. We will replace these values with the tile range.
	x1, y1, x2, y2 = self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4]
	
	-- Calculate the _tileRange for orthogonal tiles
	if self.orientation == "orthogonal" then
	
		-- Limit the drawing range. We must make sure we can draw the tiles that are bigger
		-- than the self's tileWidth and tileHeight.
		if x1 and y1 and x2 and y2 then
			x2 = ceil(x2/self.tileWidth)
			y2 = ceil((y2+heightOffset)/self.tileHeight)
			x1 = floor((x1-widthOffset)/self.tileWidth)
			y1 = floor(y1/self.tileHeight)
		
			-- Make sure that we stay within the boundry of the map
			x1 = x1 > 0 and x1 or 0
			y1 = y1 > 0 and y1 or 0
			x2 = x2 < self.width and x2 or self.width - 1
			y2 = y2 < self.height and y2 or self.height - 1
		
		else
			-- If the drawing range isn't defined then we draw all the tiles
			x1, y1, x2, y2 = 0, 0, self.width-1, self.height-1
		end
		
	-- Calculate the _tileRange for isometric tiles.
	else
		-- If the drawRange is set
		if x1 and y1 and x2 and y2 then
			x1, y1 = self:toIso(x1-self._widestTile,y1)
			x1, y1 = ceil(x1/self.tileHeight), ceil(y1/self.tileHeight)-1
			x2 = ceil((x2+self._widestTile)/self.tileWidth)
			y2 = ceil((y2+heightOffset)/self.tileHeight)
		-- else draw everything
		else
			x1 = 0
			y1 = 0
			x2 = self.width - 1
			y2 = self.height - 1
		end
	end
	
	-- Assign the new values to the tile range
	tr, ptr = self._tileRange, self._previousTileRange
	tr[1], tr[2], tr[3], tr[4] = x1, y1, x2, y2
	
	-- If the tile range or useSpriteBatch is different than the last frame then we need to 
	-- update sprite batches.
	self._redraw = self.useSpriteBatch ~= self._previousUseSpriteBatch or self._forceRedraw or
						  tr[1] ~= ptr[1] or 
						  tr[2] ~= ptr[2] or 
						  tr[3] ~= ptr[3] or 
						  tr[4] ~= ptr[4]
						  
	-- Set the previous useSpritebatch
	self._previousUseSpriteBatch = self.useSpriteBatch
						  
	-- Reset the forced special redraw
	self._forceRedraw = false
end

---------------------------------------------------------------------------------------------------
-- Calling the map as a function will return the layer
function Map:__call(layerName)
	return self.layers[layerName]
end

---------------------------------------------------------------------------------------------------
-- Returns the Map class
return Map


--[[Copyright (c) 2011-2012 Casey Baxter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.--]]