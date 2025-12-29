--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Utility Module
/ /_/ / /|  /  desc: meant to be refactored to the given environment
\____/_/ |_/ source: link ]]

---@class GNUI.utils
local util = {}

---@param path string
---@return Vector2
function util.getTextureSize(path)
	if textures[path] then
		return textures[path]:getDimensions()
	else
		return vec(0,0)
	end
end


---@return Vector2
function util.getScreenSize()
	return client:getWindowSize()/client:getGuiScale()
end


---@param path string
---@return string[]
function util.listFiles(path)
	return listFiles(path)
end


return util