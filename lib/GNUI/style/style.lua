local Quad = require("./sprites/quad") ---@type GNUI.Sprite.QuadAPI
local Sprite = require("./sprites/sprite") ---@type GNUI.Sprite
local util =  require("../utils") ---@type GNUI.utils

---@alias GNUI.Theme table<string,table<string,table<string,GNUI.Sprite.Style>>>

---@type GNUI.Theme
local Theme = {}

---@class GNUI.StyleAPI
local StyleAPI = {}


--────────────────────────-< Theme Loader >-────────────────────────--
for index, path in ipairs(util.listFiles("./theme")) do
	local package = require(path)
	for keyClass, class in pairs(package) do
		if not Theme[keyClass] then
			Theme[keyClass] = {}
		end
		
		for keyVariant, variant in pairs(class) do
			if not Theme[keyClass][keyVariant] then
				Theme[keyClass][keyVariant] = {}
			end
			
			for keyType, type in pairs(variant) do
				Theme[keyClass][keyVariant][keyType] = type
			end
		end
	end
end



---@return GNUI.Sprite.Quad
function StyleAPI.newQuad()
	return Quad.new()
end


return StyleAPI