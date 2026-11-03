-- Any GNUI Box with `tooltipText` property set will display a tooltip
-- a tooltip is just a text box thats beside the cursor

if false then return end

local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()

local hasTooltip = false

local OFFSET = vec(10,0)

local tooltip = screen:parse{
	style="opaque",
	text="Text",
	captureInput = false,
}


screen.CHILDREN_ORDER_CHANGED:register(function ()
	tooltip:setChildIndex(99999)
end)

screen.CURSOR_MOVED:register(function (pos, vel)
	tooltip:forceUpdate()
	local size = tooltip:getFinalSize()
	local screenSize = screen:getFinalSize()
	tooltip:setPos(
	math.clamp(math.floor(pos.x) + OFFSET.x,0,screenSize.x-size.x),
	math.clamp(math.floor(pos.y) + OFFSET.y,0,screenSize.y-size.y-40)
	)
end)


events.WORLD_TICK:register(function ()
	local isCursorUnlocked = (host:isCursorUnlocked() or host:isChatOpen())and hasTooltip
	tooltip:setVisible(isCursorUnlocked)
end)

screen.HOVERED_BOX_CHANGED:register(function (new)
	if new and new.tooltipText then
		tooltip:setText(new.tooltipText)
		hasTooltip = true
	else
		hasTooltip = false
	end
end)