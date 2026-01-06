local GNUI = require("lib.GNUI.main")
local screen = GNUI.getScreen()

-- creates a new box with children
local box = GNUI.parse(screen,{
	layout = "HORIZONTAL",
	size = vec(200,-1),
	sizing = {"FIXED","FIT"},
	variant="test",
	padding = vec(2,2,2,2),
	gap = 5,
	
	{ -- children
		{
			text="One Two Three Four",
			sizing={"FILL","FIT"},
			variant="test",
		},
		{
			sizing={"FIXED","FILL"},
			size=vec(30,-1),
			variant="test",
		},
		{
			text="Five Six Seven Eight Nine Ten",
			sizing={"FILL","FIT"},
			variant="test",
		}
	}
})

screen:addChild(box)

box:setPos(10,10)

-- can be any event
function events.WORLD_RENDER(delta)
	local t = client.getSystemTime()/50
	box:setSize((math.sin(t/8)*0.5+0.5)*45+140,-1)
	
	screen:setCursorPos(client:getMousePos()/client:getGuiScale())
	-- tells GNUI to update, might not be needed in the final version
	screen:flushUpdates()
end

events.KEY_PRESS:register(function (key, state)
	screen:inputKey(key, state)
end)

events.MOUSE_PRESS:register(function (button, state)
	screen:inputMouse(button, state)
end)

events.MOUSE_SCROLL:register(function (amount)
	screen:inputMouse(0,amount)
end)