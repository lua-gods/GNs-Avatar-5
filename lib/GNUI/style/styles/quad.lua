local SpriteStyle = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local gnutil = require("../../../gnutil") ---@type GNUtil
local util = require("../../utils") ---@type GNUI.utils
local config = require("../../config") ---@type GNUI.config
local Render = require("../../"..config.RENDER) ---@type GNUI.RenderAPI

---@class GNUI.Sprite.Quad.StyleAPI
local StyleAPI = {}


---@class GNUI.Sprite.Quad.Style : GNUI.Sprite.Style
---@field texture string
---@field uv Vector4
local Style = {}
Style.__index = gnutil.makeIndex{Style,SpriteStyle}


function StyleAPI.getIndex()
	return Style.__index
end


---@return GNUI.Sprite.Quad.Style
function StyleAPI.new()
	local self = SpriteStyle.new()
	---@cast self GNUI.Sprite.Quad.Style
	self.texture = ""
	self.uv = gnutil.vec4(0,0,0,0)
	setmetatable(self,Style)
	return self
end


---@generic self
---@param self self
---@return self
function Style:setTexture(path)
	---@cast self GNUI.Sprite.Quad.Style
	self.texture = path
	local size = util.getTextureSize(path)
	self.uv = vec(0,0,size.x,size.y)
	return self
end


---@overload fun(self: GNUI.Sprite.Quad.Style, xy1: Vector2, xy2: Vector2): self
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@generic self
---@param self self
---@return self
function Style:setUV(x1,y1,x2,y2)
	---@cast self GNUI.Sprite.Quad.Style
	self.uv = gnutil.vec4(x1,y1,x2,y2)
	return self
end


return StyleAPI
