--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's User Interface Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

local Core = require("./core/core") ---@type GNUI.CoreAPI
local Layout = require("./layout/layout") ---@type GNUI.LayoutAPI
local Render = require("./render/render") ---@type GNUI.RenderAPI

---@class GNUIAPI
local GNUIAPI = {}


---@param data GNUI.Layout
---@return GNUI.Box
function GNUIAPI.parse(data)
	return Layout.parse(data)
end

local screen = Core.newCanvas()
local renderer = Render.new({canvas = screen})

function GNUIAPI.getScreen()
	return screen,renderer
end


return GNUIAPI