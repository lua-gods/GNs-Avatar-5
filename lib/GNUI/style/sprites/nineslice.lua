--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Nineslice Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local gncommon = require("lib.gncommon") ---@type GNCommon
local Style = require("../styles/nineslice") ---@type GNUI.Sprite.Nineslice.StyleAPI
local config = require("../../config") ---@type GNUI.config

local Sprite = require("./sprite") ---@type GNUI.SpriteAPI
local Quad = require("./quad") ---@type GNUI.Sprite.QuadAPI

---@class GNUI.Sprite.NinesliceAPI
local NinesliceAPI = {}


---@class GNUI.Sprite.Nineslice : GNUI.Sprite.Quad
---@field style GNUI.Sprite.Nineslice.Style 
---
---@field idTopLeft integer
---@field idTop integer
---@field idTopRight integer
---
---@field idLeft integer
---@field id integer
---@field idRight integer
---
---@field idBottomRight integer
---@field idBottom integer
---@field idBottomLeft integer
local Nineslice = {}
Nineslice.__index = function (t,i)
	return rawget(t,i) or Nineslice[i] or Quad.index(i) or Sprite.index(i)
end


function NinesliceAPI.getIndex() return Nineslice.__index end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Nineslice
function NinesliceAPI.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Nineslice
	
	self.idTopLeft = self.render:newVisualQuad()
	self.idTop = self.render:newVisualQuad()
	self.idTopRight = self.render:newVisualQuad()
	
	self.idLeft = self.render:newVisualQuad()
	self.id = self.render:newVisualQuad()
	self.idRight = self.render:newVisualQuad()
	
	self.idBottomRight = self.render:newVisualQuad()
	self.idBottom = self.render:newVisualQuad()
	self.idBottomLeft = self.render:newVisualQuad()
	
	setmetatable(self, Nineslice)
	return self
end


Style.setInstancer(NinesliceAPI.new)
---@return GNUI.Sprite.Nineslice.Style
function NinesliceAPI.newStyle()
	return Style.new()
end


--────────────────────────-< API >-────────────────────────--


---@param path string
---@generic self
---@param self self
---@return self
function Nineslice:setTexture(path)
	---@cast self GNUI.Sprite.Nineslice
	self.texture_path = path
	self.render:setTexture(self.idTopLeft,self.texture_path)
	self.render:setTexture(self.idTop,self.texture_path)
	self.render:setTexture(self.idTopRight,self.texture_path)
	
	self.render:setTexture(self.idLeft,self.texture_path)
	self.render:setTexture(self.id,self.texture_path)
	self.render:setTexture(self.idRight,self.texture_path)
	
	self.render:setTexture(self.idBottomLeft,self.texture_path)
	self.render:setTexture(self.idBottom,self.texture_path)
	self.render:setTexture(self.idBottomRight,self.texture_path)
	return self
end


function Nineslice:updateAll()
	if self.style then
		local style = self.style
		self:setTexture(style.texture_path)
		self.render:setUV(self.id,style.uv.x,style.uv.y,style.uv.z,style.uv.w)
	end
end



---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Sprite:setPos(x,y)
	---@cast self GNUI.Sprite
	self.pos = gncommon.vec2(x,y)
	self.render:setPos(self.id, self.pos.x, self.pos.y)
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
	self.size = gncommon.vec2(x,y)
	self.render:setSize(self.id, self.size.x, self.size.y)
	return self
end




return NinesliceAPI