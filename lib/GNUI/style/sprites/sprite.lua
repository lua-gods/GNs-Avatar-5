local Style = require("../styles/quad") ---@type GNUI.Sprite.StyleAPI
local util = require("../../../gnutil") ---@type GNUtil


---@class GNUI.SpriteAPI
local SpriteAPI = {}


---@return GNUI.Sprite.Style
function SpriteAPI.newStyle()
	local self = {
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0)
	}
	setmetatable(self,Style)
	return self
end


---A base class for all sprites for boxes
---@class GNUI.Sprite
---@field pos Vector2
---@field size Vector2
---@field style GNUI.Sprite.Style
local Sprite = {}
Sprite.__index = Sprite


function SpriteAPI.getIndex()
	return Sprite.__index
end


---@return GNUI.Sprite
function SpriteAPI.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0)
	}
	return self
end


---@return GNUI.Sprite.Style
function SpriteAPI.newStyle()
	return Style.new()
end


---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Sprite:setPos(x,y)
	---@cast self GNUI.Sprite
	self.pos = vec(x,y)
	return self
end


---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Sprite:setSize(x,y)
	---@cast self GNUI.Sprite
	self.size = util.vec2(x,y)
	return self
end

return Sprite