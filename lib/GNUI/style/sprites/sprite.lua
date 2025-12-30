--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite Module
/ /_/ / /|  /  desc: base class for all sprites
\____/_/ |_/ source: link ]]
local Style = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local util = require("../../../gnutil") ---@type GNUtil


---@class GNUI.SpriteAPI
local SpriteAPI = {}


---A base class for all sprites for boxes
---@class GNUI.Sprite
---@field color Vector3
---@field style GNUI.Sprite.Style
local Sprite = {}
Sprite.__index = Sprite


function SpriteAPI.index(i)
	return Sprite[i]
end


---@param box GNUI.Box
---@return GNUI.Sprite
function SpriteAPI.new(box)
	assert(box,"no GNUI.Box given")
	local self = {
		size = vec(0,0),
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0)
	}
	setmetatable(self, Sprite)
	box:setSprite(self)
	return self
end


Style.setInstancer(SpriteAPI.new)


---@return GNUI.Sprite.Style
function SpriteAPI.newStyle()
	return Style.new()
end


---Creates a new instance of the sprite with the style
---@param box GNUI.Box
---@return GNUI.Sprite
function Sprite:newInstance(box)
	return SpriteAPI.new(box):setStyle(self)
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


---@generic self
---@param self self
---@return self
function Sprite:setStyle(style)
	---@cast self GNUI.Sprite
	self.style = style
	return self
end


return SpriteAPI