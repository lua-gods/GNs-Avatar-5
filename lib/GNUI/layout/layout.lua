local Core = require("../core/core") ---@type GNUI.CoreAPI


---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field size Vector2
---@field pos Vector2
---@field [1] table<integer,GNUI.Layout>?


---@param layout GNUI.Layout
local function parseLayout(layout)
	local box = Core.newBox()
	box:setSize(layout.size.x,layout.size.y)
	box:setPos(layout.pos.x,layout.pos.y)
	if layout[1] then
		for index, childLayout in ipairs(layout[1]) do
			box:addChild(parseLayout(childLayout))
		end
	end
	return box
end


---@param data GNUI.Layout
---@return GNUI.Box
function LayoutAPI.parse(data)
	return parseLayout(data)
end


return LayoutAPI