# flags: host_only
local Sync = require "lib.GNSync"



local GNUI = require("lib.GNUI.init")
local screen = GNUI.getScreen()


local entries = listFiles("auto/windows/apps")


local tooltip = screen:parse{
	type = "button",
	text="text"
}

screen.CHILDREN_ORDER_CHANGED:register(function ()
	tooltip:setChildIndex(99)
end)

local toolbar = screen:parse{
	layout="HORIZONTAL",
	style="opaque",
	pos = vec(5,5),
	{
		{
			type = "button",
			name = "colorPicker",
			text = ":palette:",
			wrapText = false,
		}
	}
}

events.TICK:register(function ()
	tooltip:setChildIndex(99)
end)

local function loadWindow(name)
	local WindowFactory = require("auto.windows."..name)
	return WindowFactory(screen,GNUI)
end



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