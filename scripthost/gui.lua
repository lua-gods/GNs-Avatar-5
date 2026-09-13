local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()
local Event = require("lib.GNEvent")


for key, value in pairs(listFiles("scripthost.ui")) do
	require(value)
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


screen.display:setParentType("HUD")
screen.PRE_RENDER = Event.new()
events.WORLD_RENDER:register(function (delta)
	screen:setVisible(client:isHudEnabled())
	local screenID = host:getScreen()
	if (action_wheel:isEnabled())
	or (screenID and not screenID == "net.minecraft.class_408") then -- move mouse away if theres already UI open
		screen:setCursorPos(-1000, -1000)
	else
		screen:setCursorPos(client:getMousePos() *
			(client:getScaledWindowSize() / client:getWindowSize()))
	end
	screen.PRE_RENDER:invoke(delta)
	screen:flushUpdates()
	
		--screen:draw(graphics)
end)