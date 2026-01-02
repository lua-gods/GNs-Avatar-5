
local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.parse(screen,{
	layout = "HORIZONTAL",
	size = vec(250,50),
	{ -- children
		{
			size = vec(50,50), -- fixed size
		},
		{
			name="amogus",
			sizing="FILL",
		},
		{
			name="ee",
			size = vec(300,50),
			sizing="FILL",
		},
	}
})

screen:addChild(box)


function events.WORLD_RENDER(delta)
	
	local t = world.getTime()+delta
	box:setSize((math.sin(t/5)*0.5+0.5)*250+200,50)
	GNUI.flushUpdates()
end