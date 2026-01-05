local GNUI = require("lib.GNUI.main")
local screen = GNUI.getScreen()

-- creates a new box with children
local box = GNUI.parse(screen,{
	layout = "HORIZONTAL",
	size = vec(200,10),
	variant="test",
	
	{ -- children
		{
			text="One Two Three Four",
			sizing={"FILL","FIT"},
			variant="test",
		},
		{
			sizing="FIXED",
			size=vec(30,30),
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


-- can be any event
function events.WORLD_RENDER(delta)
	local t = client.getSystemTime()/50
	box:setSize((math.sin(t/8)*0.5+0.5)*25+50,30)
	--:setPos(math.random(1,10),0)
	-- tells GNUI to update, might not be needed in the final version
	screen:flushUpdates()
end