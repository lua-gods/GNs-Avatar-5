# flags: host_only

if false then
	return
end

local GNUI = require("lib.GNUI.init")
GNUI.setup()

local screen = GNUI.getScreen()

--- parent box to hold all the columns
local classColumns = GNUI.parse(screen, {
	variant = "empty",
	layout = "HORIZONTAL",
	sizing = { "FIT", "FIT" },
	gap = 5,
})

-- loop for each class with a given style
for _, className in ipairs(GNUI.Theme.getClassNames()) do
	-- create a column container for each widget
	local variantColumn = GNUI.parse(screen, {
		layout = "VERTICAL",
		sizing = { "FIT", "FIT" },
		minSize = vec(80, 0),
		variant = "empty",
	})
	classColumns:addChild(variantColumn)

	-- create the class header
	local classHeader = GNUI.parse(screen, {
		sizing = { "FILL", "FIT" },
		minSize = vec(0, 15),
		variant = "empty",
		text = className,
	})
	variantColumn:addChild(classHeader)

	-- loop for each class variant
	for _, variantName in ipairs(GNUI.Theme.getVariantNames(className)) do
		
		-- create that given widget with the given variant
		local widget = GNUI.parse(screen, {
			type = className,
			sizing = { "FILL", "FIT" },
			minSize = vec(0, 15),
			variant = variantName,
			text = variantName,
		})
		variantColumn:addChild(widget)
	end
end
classColumns:setPos(5, 5)
screen:addChild(classColumns)


--screen:addChild(box)

screen.display:setParentType("HUD")


-- can be any event
function events.WORLD_RENDER(delta)
	local t = client.getSystemTime()/50
	--box:setSize((math.sin(t/8)*0.5+0.5)*45+140,-1)
	
	screen:setCursorPos(client:getMousePos()/client:getGuiScale())
	-- tells GNUI to update, might not be needed in the final version
	screen:flushUpdates()
end

local key = keybinds:newKeybind("balls","key.keyboard.h")

key.press = function ()
	screen[1][1]:setColor(math.random(),math.random(),math.random())
end

--────────────────────────────────────────-< GNUI Boilerplate >-────────────────────────────────────────--

events.KEY_PRESS:register(function (key, state)
	local allow = screen:inputKey(key, state)
	if not allow then
		host:setChatText("")
	end
	return not allow
end)

local keymap = {}
local mapmap = {}
local key = keybinds:newKeybind("GNUU","key.keyboard.a")
for _, keyString in ipairs(client.getEnum("keybinds")) do
	key:setKey(keyString)
	mapmap[string.lower(key:getKeyName())] = key:getKey()
	keymap[string.lower(key:getKeyName())] = key:getID()
end


events.CHAR_TYPED:register(function (char, modifiers, codepoint) screen:inputChar(char) end)
events.MOUSE_PRESS:register(function (button, state) screen:inputMouse(button, state) end)
events.MOUSE_SCROLL:register(function (amount) screen:inputMouse(0,amount)end)