---@diagnostic disable: param-type-mismatch
local config = require("../config")

local Core = require("../" .. config.CORE) ---@type GNUI.CoreAPI
local Style = require("../style/style") ---@type GNUI.StyleAPI

---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field name string?
---@field size Vector2?
---@field minSize Vector2?
---@field sizing ({[1]:GNUI.Box.SizingMode,[2]:GNUI.Box.SizingMode}|GNUI.Box.SizingMode)?
---@field pos Vector2?
---@field gap number?
---@field layout GNUI.Box.LayoutMode?
---@field text string?
---@field textAlign (-1|0|1)?
---@field wrap boolean?
---@field variant string?
---
---@field [1] GNUI.Layout[]?


---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
local function parseEntry(canvas, layout)
	assert(layout, "No layout given")
	assert(canvas, "No canvas given")
	local box = Core.newBox(canvas)
	
	local hasSizeX, hasSizeY = false, false
	if layout.size then
		box:setSize(layout.size.x, layout.size.y)
		hasSizeX = layout.size.x ~= -1
		hasSizeY = layout.size.y ~= -1
	end
	if layout.minSize then box:setMinimumSize(layout.minSize.x, layout.minSize.y) end
	if layout.sizing then
		if type(layout.sizing) == "string" then
			box:setSizing(layout.sizing, layout.sizing)
		else
			box:setSizing(layout.sizing[1], layout.sizing[2])
		end
	else
		if box.text then
			box:setSizing("FILL","FIT")
		else
			box:setSizing(hasSizeX and "FIXED" or "FIT", hasSizeY and "FIXED" or "FIT")
		end
	end
	if layout.pos then box:setPos(layout.pos.x, layout.pos.y) end
	if layout.layout then box:setLayout(layout.layout) end

	if layout.gap then box:setChildGap(layout.gap) end
	
	local style = Style.getStyle(box, layout.variant or "default", "normal")
	if style then
		box:setSprite(style:newInstance(box))
	end

	if layout.text then box:setText(layout.text) end
	if layout.textAlign then box:setTextAlignment(layout.textAlign) end
	
	if layout.wrap then box:setWrapText(layout.wrap) end

	if layout.name then
		box:setName(layout.name)
		box.name = layout.name
	end

	if layout[1] then
		assert(layout[1][1], "Common mistake, children entry should be an array, not an box entry")
		for index, childLayout in ipairs(layout[1]) do
			box:addChild(parseEntry(canvas, childLayout))
		end
	end
	return box
end


---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
---@return GNUI.Box
function LayoutAPI.parse(canvas, layout)
	return parseEntry(canvas, layout)
end

return LayoutAPI
