local Quad = require("../sprites/quad") ---@type GNUI.Sprite.QuadAPI
local Sprite = require("../sprites/sprite") ---@type GNUI.SpriteAPI

---@type GNUI.Theme
return {
	box={
		default={
			normal = Quad.newStyle():setTexture("avatar"),
		}
	}
}