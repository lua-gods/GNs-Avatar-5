-- Any GNUI Box with `tooltipText` property set will display a tooltip
-- a tooltip is just a text box thats beside the cursor

local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()

local hasTooltip = false

local tooltip = screen:parse{
	style="opaque",
	text="Text",
	captureInput = false,
}


screen.CHILDREN_ORDER_CHANGED:register(function ()
	tooltip:setChildIndex(99999)
end)

screen.CURSOR_MOVED:register(function (pos, vel)
	tooltip:setPos(pos:floor() + vec(10,0))
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