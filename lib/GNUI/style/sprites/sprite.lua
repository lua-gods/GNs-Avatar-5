--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite Module
/ /_/ / /|  /  desc: base class for all sprites
\____/_/ |_/ source: link ]]
local Style = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local gncommon = require("lib.gncommon") ---@type GNCommon


---@class GNUI.SpriteAPI
local SpriteAPI = {}


---A base class for all sprites for boxes
---@class GNUI.Sprite
---@field style GNUI.Sprite.Style
---@field box GNUI.Box?
---
---@field color Vector3
---@field pos Vector2
---@field size Vector2
---@field padding Vector4
---@field margin Vector4
---
---@field render GNUI.RenderInstance
---@field id integer?
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
		margin = vec(0,0,0,0),
		
		render = box.canvas.render,
		id = box.canvas.render:newQuadVisual()
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


--────────────────────────-< API >-────────────────────────--

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


---@overload fun(self: GNUI.Sprite, ltrb: Vector4): self
---@overload fun(self: GNUI.Sprite, lt: Vector2, rn: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function Sprite:setMargin(left,top,right,bottom)
	---@cast self GNUI.Sprite
	self.margin = gncommon.vec4(left,top,right,bottom)
	self.box:update()
	return self
end



---@return Vector4
function Sprite:getMargin()
	local margin = self.margin
	if self.style then
		local style = self.style
		margin = vec(
			math.max(margin.x, style.margin.x),
			math.max(margin.y, style.margin.y),
			math.max(margin.z, style.margin.z),
			math.max(margin.w, style.margin.w)
		)
	end
	return margin
end


---@overload fun(self: GNUI.Sprite, ltrb: Vector4): self
---@overload fun(self: GNUI.Sprite, lt: Vector2, rn: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function Sprite:setPadding(left,top,right,bottom)
	---@cast self GNUI.Sprite
	self.padding = gncommon.vec4(left,top,right,bottom)
	self.box:update()
	return self
end


---@return Vector4
function Sprite:getPadding()
	local padding = self.padding
	if self.style then
		local style = self.style
		padding = vec(
			math.max(padding.x, style.padding.x),
			math.max(padding.y, style.padding.y),
			math.max(padding.z, style.padding.z),
			math.max(padding.w, style.padding.w)
		)
	end
	return padding
end


---@param style GNUI.Sprite.Style
---@generic self
---@param self self
---@return self
function Sprite:setStyle(style)
	---@cast self GNUI.Sprite
	
	if self.style ~= style then
		self.style = style
		self:updateAll()
	end
	return self
end


function Sprite:updateAll()
end


---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Sprite:setBox(box)
	---@cast self GNUI.Sprite
	self.box = box
	if self.box then
		self:setStyle(self.style)
	end
	return self
end

return SpriteAPI