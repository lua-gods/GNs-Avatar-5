local Sprite = require("./sprite")
local gnutil = require("../../../gnutil") ---@type GNUtil
local Style = require("../styles/quad") ---@type GNUI.Sprite.Quad.StyleAPI


---@class GNUI.Sprite.QuadAPI
local QuadAPI = {}




---@class GNUI.Sprite.Quad : GNUI.Sprite
---@field style GNUI.Sprite.Quad.Style
local Quad = {}
Quad.__index = gnutil.makeIndex{Quad,Sprite}


function QuadAPI.getIndex() return Quad.__index end


---A representation of a quad that will get drawn
---@return GNUI.Sprite.Quad
function QuadAPI.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
	}
	setmetatable(self, Quad)
	return self
end


---@return GNUI.Sprite.Quad.Style
function QuadAPI.newStyle()
	return Style.new()
end


---Sets the position of the sprite
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Quad:setPos(x,y)
	---@cast self GNUI.Sprite.Quad
	self.pos = vec(x,y)
	return self
end


---@return Vector2
function Quad:getPos()
	return self.pos
end


function Quad:setTexture(path)
	self.texture = path
end


---Sets the size of the sprite
---@overload fun(self:GNUI.Sprite.Quad,xy:Vector2):GNUI.Sprite.Quad
---@param x number
---@param y number
---@generic self
---@param self GNUI.Sprite.Quad
---@return self
function Quad:setSize(x,y)
	self.size = vec(x,y)
	return self
end


---@return Vector2
function Quad:getSize()
	return self.size
end


return QuadAPI