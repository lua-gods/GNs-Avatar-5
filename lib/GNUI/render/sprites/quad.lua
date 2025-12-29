local Sprite = require("./sprite")
local gnutil = require("../../gnutil") ---@type GNUtil

---@class GNUI.Render.Sprite.Quad : GNUI.Render.Sprite
---@field texture string # Path to the texture
local Quad = {}
Quad.__index = gnutil.makeIndex{Quad,Sprite}


---A representation of a quad that will get drawn
---@return GNUI.Render.Sprite.Quad
function Quad.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		texture = nil
	}
	setmetatable(self, Quad)
	return self
end


---Sets the position of the sprite
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Quad:setPos(x,y)
	---@cast self GNUI.Render.Sprite.Quad
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
---@overload fun(self:GNUI.Render.Sprite.Quad,xy:Vector2):GNUI.Render.Sprite.Quad
---@param x number
---@param y number
---@generic self
---@param self GNUI.Render.Sprite.Quad
---@return self
function Quad:setSize(x,y)
	self.size = vec(x,y)
	return self
end


---@return Vector2
function Quad:getSize()
	return self.size
end


return Quad