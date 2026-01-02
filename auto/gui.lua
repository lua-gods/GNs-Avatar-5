
local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.parse(screen,{
	layout = "HORIZONTAL",
	{ -- children
		{
			name="amogus",
			size = vec(50,50), -- fixed size
		},
		{
			name="lel",
			size = vec(50,50),
		},
	}
})

screen:addChild(box)

function events.WORLD_RENDER(delta)
	
	local t = world.getTime()+delta
	box.amogus:setSize((math.sin(t/5)*0.5+0.5)*50,25)
	GNUI.flushUpdates()
end