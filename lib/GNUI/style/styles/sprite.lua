local util = require("../../../gnutil") ---@type GNUtil

---@class GNUI.Sprite.StyleAPI
local SpriteSTyleAPI = {}

---@class GNUI.Sprite.Style
---@field padding Vector4
---@field margin Vector4
local SpriteStyle = {}
SpriteStyle.__index = SpriteStyle

local newInstance

function SpriteSTyleAPI.index(i)
	return SpriteStyle[i]
end


function SpriteSTyleAPI.setInstancer(new)
	newInstance = new
end


---@return GNUI.Sprite
function SpriteStyle:newInstance()
	return newInstance():setStyle(self)
end


---@return GNUI.Sprite.Style
function SpriteSTyleAPI.new()
	local self = {
		padding = util.vec4(0,0,0,0),
		margin = util.vec4(0,0,0,0)
	}
	setmetatable(self,SpriteStyle)
	return self
end


---@overload fun(self: GNUI.Sprite, xyzw: Vector4): self
---@overload fun(self: GNUI.Sprite, xy: Vector2, zw: Vector2): self
---@param x number
---@param y number
---@param z number
---@param w number
---@generic self
---@param self self
---@return self
function SpriteStyle:setPadding(x,y,z,w)
	---@cast self GNUI.Sprite
	self.padding = util.vec4(x,y,z,w)
	return self
end


---@overload fun(self: GNUI.Sprite, xyzw: Vector4): self
---@overload fun(self: GNUI.Sprite, xy: Vector2, zw: Vector2): self
---@param x number
---@param y number
---@param z number
---@param w number
---@generic self
---@param self self
---@return self
function SpriteStyle:setMargin(x,y,z,w)
	---@cast self GNUI.Sprite
	self.margin = util.vec4(x,y,z,w)
	return self
end


return SpriteSTyleAPI