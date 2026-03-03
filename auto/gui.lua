# flags: host_only

if false then
	return
end

local GNUI = require("lib.GNUI.init")
GNUI.setup()

local screen = GNUI.getScreen()

-- creates a new box with children
local box = GNUI.parse(screen,{
	
	layout = "VERTICAL",
	size = vec(200,-1),
	childAlign = vec(-1,0),
	sizing = {"FIXED","FIT"},
	padding = vec(2,2,2,2),
	gap = 0,
	
	{ -- children
		{
			variant="primary",
			type="button",
			text="One Two Three Four",
			sizing={"FILL","FIT"},
			size = vec(0,30),
		},
		{
			variant="secondary",
			type="button",
			text="One Two Three Four",
			sizing={"FILL","FIT"},
			size = vec(0,30),
		},
		{
			variant="bevel",
			type="button",
			text="Bevel",
			sizing={"FILL","FIT"},
			size = vec(0,30),
		},
		{
			text="Five Six Seven Eight Nine Ten",
			sizing={"FILL","FIT"},
		},
		{
			type="textField",
			sizing={"FILL","FIT"},
			multiline=true
		},
	}
})

screen:addChild(box)

box:setPos(10,10)
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

host:setClipboard(toJson({mapmap,keymap}))

events.CHAR_TYPED:register(function (char, modifiers, codepoint) screen:inputChar(char) end)
events.MOUSE_PRESS:register(function (button, state) screen:inputMouse(button, state) end)
events.MOUSE_SCROLL:register(function (amount) screen:inputMouse(0,amount)end)