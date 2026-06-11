# flags: host_only
local Sync = require "lib.GNSync"



local GNUI = require("lib.GNUI.init")
local screen = GNUI.getScreen()



local ENTRIES = {
	{
		name = "Color Picker",
		path = "colorize",
		icon = ":palette:"
	},
	{
		name = "Orthographic Projection",
		path = "orthographic",
		icon = ":camera:"
	},
	--{
	--	name = "Face Expression",
	--	path = "expression",
	--	icon = ":smile:"
	--},
}


local toolbar = screen:parse{
	layout="HORIZONTAL",
	style="opaque",
	pos = vec(5,5),
	name="toolbar"
}


local tooltip = screen:parse{
	style="opaque",
	text="Text",
	captureInput = false,
	name="tooltip"
}


local HAS_TOOLTIP = false


for index, entry in ipairs(ENTRIES) do
	local btn = toolbar:parse{
		--name = entry.name,
		type = "button",
		minSize = vec(10,10),
		text = entry.icon,
		wrapText = false,
		toggle=true
	}
	local macro = require("auto.windows."..entry.path)
	entry.macro = macro
	---@cast btn GNUI.Widget.Button
	
	btn.BUTTON_DOWN:register(function ()
		entry.macro:setActive(true,screen,GNUI)
	end)
	
	btn.BUTTON_UP:register(function ()
		entry.macro:setActive(false,screen,GNUI)
	end)
	
	btn.CURSOR_PRESENCE_CHANGED:register(function (inside)
		if inside then
			HAS_TOOLTIP = true
			tooltip:setText(entry.name)
		else
			HAS_TOOLTIP = false
		end
	end)
end


--ENTRIES[3].macro:setActive(true,screen,GNUI)

screen.CHILDREN_ORDER_CHANGED:register(function ()
	tooltip:setChildIndex(99999)
end)

screen.CURSOR_MOVED:register(function (pos, vel)
	tooltip:setPos(pos:floor() + vec(10,0))
end)



screen.SIZE_CHANGED:register(function (size)
	toolbar:setPos(
		size.x * 0.5 - 91.25,
		size.y - 55.1
	)
end)


events.WORLD_TICK:register(function ()
	local isCursorUnlocked = (host:isCursorUnlocked() or host:isChatOpen())and HAS_TOOLTIP
	tooltip:setVisible(isCursorUnlocked)
	--screen:printTree()
end)


--────────────────────────────────────────-< GNUI Boilerplate >-────────────────────────────────────────--
-- TODO: make all this boilerplate code a loadable preset instead
events.KEY_PRESS:register(function(key, state)
	local cancel = screen:inputKey(key, state)
	if cancel then
		host:setChatText("")
	end
	return cancel
end)

events.CHAR_TYPED:register(function(char, modifiers, codepoint) screen:inputChar(char) end)
events.MOUSE_PRESS:register(function(button, state) screen:inputMouse(button, state) end)
events.MOUSE_SCROLL:register(function(amount) screen:inputScroll(amount, 0) end)


function events.WORLD_RENDER()
	screen:setVisible(client:isHudEnabled())
	local screenID = host:getScreen()
	if (action_wheel:isEnabled())
	or (screenID and not screenID == "net.minecraft.class_408") then -- move mouse away if theres already UI open
		screen:setCursorPos(-1000, -1000)
	else
		screen:setCursorPos(client:getMousePos() *
			(client:getScaledWindowSize() / client:getWindowSize()))
	end
	screen:flushUpdates()
end

screen.display:setParentType("HUD")