local Nineslice = require("../sprites/nineslice") ---@type GNUI.Sprite.NinesliceAPI
local Quad = require("../sprites/quad") ---@type GNUI.Sprite.QuadAPI
local Sprite = require("../sprites/sprite") ---@type GNUI.SpriteAPI


local atlas = nil ---@type string
if figuraMetatables then -- is Figura lmao
	atlas = (...):gsub("/",".") ..".ore"
end


---@type GNUI.Theme
return {
	box={
		default={
			normal = Quad.newStyle()
			:setTexture(atlas)
			:setUV(1/64,0,6/64,7/64)
			,
		},
		test={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			--:setUV(1/64,0,6/64,7/64)
			,
		}
	}
}