local config = require("../config")

local Core = require("../"..config.CORE) ---@type GNUI.CoreAPI
local Style = require("../style/style") ---@type GNUI.StyleAPI

---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field size Vector2?
---@field pos Vector2?
---@field layout GNUI.Box.LayoutMode?
---@field variant string?
---
---@field [1] table<integer,GNUI.Layout>?


---@param layout GNUI.Layout
local function parseLayout(layout)
	local box = Core.newBox()
	if layout.size then box:setSize(layout.size.x,layout.size.y) end
	if layout.pos then box:setPos(layout.pos.x,layout.pos.y) end
	if layout.layout then box:setLayout(layout.layout) end
	if layout.variant then -- Quad Sprite
		local style = Style.getStyle(box,layout.variant,"normal")
		if style then
			box:setSprite(style:newInstance())
		end
	end
	
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