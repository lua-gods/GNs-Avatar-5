--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Quad Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local Sprite = require("./sprite") ---@type GNUI.SpriteAPI
local gnutil = require("../../../gnutil") ---@type GNUtil
local Style = require("../styles/quad") ---@type GNUI.Sprite.Quad.StyleAPI
local config = require("../../config") ---@type GNUI.config
local Render = require("../../"..config.RENDER) ---@type GNUI.RenderAPI


---@class GNUI.Sprite.QuadAPI
local QuadAPI = {}





---@class GNUI.Sprite.Quad : GNUI.Sprite
---@field style GNUI.Sprite.Quad.Style
---@field visualID integer?
local Quad = {}
Quad.__index = function (t,i)
	return rawget(t,i) or Quad[i] or Sprite.index(i)
end


function QuadAPI.getIndex() return Quad.__index end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Quad
function QuadAPI.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Quad
	box.canvas.render:newVisualQuad(box.id)
	setmetatable(self, Quad)
	return self
end
Style.setInstancer(QuadAPI.new)


---@return GNUI.Sprite.Quad.Style
function QuadAPI.newStyle()
	return Style.new()
end


---Creates a new instance of the sprite wddith the given style
---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Quad:newInstance(box)
	local self = QuadAPI.new(box):setStyle(self)
	return self
end


function Quad:setTexture(path)
	self.texture = path
end


return QuadAPI