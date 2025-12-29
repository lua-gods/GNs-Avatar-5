---A base class for all sprites for boxes
---@class GNUI.Render.Sprite
---@field pos Vector3
---@field size Vector2
local Sprite = {}
Sprite.__index = Sprite


---@return GNUI.Render.Sprite
function Sprite.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0)
	}
	return self
end


return Sprite