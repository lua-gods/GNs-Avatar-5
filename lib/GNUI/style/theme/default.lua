local Quad = require("../sprites/quad") ---@type GNUI.Sprite.QuadAPI

---@type GNUI.Theme
return {
	box={
		default={
			normal = Quad.newStyle():setTexture("avatar"),
		}
	}
}