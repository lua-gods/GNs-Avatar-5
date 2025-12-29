local util = require("../../../gnutil") ---@type GNUtil

---@class GNUI.Sprite.StyleAPI
local StyleAPI = {}

---@class GNUI.Sprite.Style
---@field padding Vector4
---@field margin Vector4
local Style = {}
Style.__index = Style


function StyleAPI.getIndex()
	return Style.__index
end


---@return GNUI.Sprite.Style
function StyleAPI.new()
	local self = {
		padding = util.vec4(0,0,0,0),
		margin = util.vec4(0,0,0,0)
	}
	setmetatable(self,Style)
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
function Style:setPadding(x,y,z,w)
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
function Style:setMargin(x,y,z,w)
	---@cast self GNUI.Sprite
	self.margin = util.vec4(x,y,z,w)
	return self
end


return StyleAPI