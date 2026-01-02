---@diagnostic disable: param-type-mismatch
local config = require("../config")

local Core = require("../"..config.CORE) ---@type GNUI.CoreAPI
local Style = require("../style/style") ---@type GNUI.StyleAPI

---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field name string?
---@field size Vector2?
---@field minSize Vector2?
---@field sizing ({[1]:GNUI.Box.SizingMode,[2]:GNUI.Box.SizingMode}|GNUI.Box.SizingMode)?
---@field pos Vector2?
---@field layout GNUI.Box.LayoutMode?
---@field variant string?
---
---@field [1] table<integer,GNUI.Layout>?


---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
local function parseEntry(canvas,layout)
	assert(layout,"No layout given")
	assert(canvas,"No canvas given")
	local box = Core.newBox(canvas)
	local hasSize = false
	if layout.size then box:setSize(layout.size.x,layout.size.y) hasSize = true end
	if layout.minSize then box:setSize(layout.minSize.x,layout.minSize.y) end
	if layout.sizing then
		if type(layout.sizing) == "string" then
			box:setSizing(layout.sizing,layout.sizing)
		else
			box:setSizing(layout.sizing[1],layout.sizing[2])
		end
	else
		if hasSize then
			box:setSizing("FIXED","FIXED")
		else
			box:setSizing("FIT","FIT")
		end
	end
	if layout.pos then box:setPos(layout.pos.x,layout.pos.y) end
	if layout.layout then box:setLayout(layout.layout) end
	
	local style = Style.getStyle(box,layout.variant or "default","normal")
	if style then
		box:setSprite(style:newInstance(box))
	end
	
	if layout.name then box:setName(layout.name) box.name = layout.name end
	
	if layout[1] then
		for index, childLayout in ipairs(layout[1]) do
			box:addChild(parseEntry(canvas,childLayout))
		end
	end
	return box
end


---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
---@return GNUI.Box
function LayoutAPI.parse(canvas,layout)
	return parseEntry(canvas,layout)
end


return LayoutAPI