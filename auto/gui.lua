
local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.parse(screen,{
	layout = "HORIZONTAL",
	pos = vec(100,100),
	variant="default",
	{
		{
			variant="default",
			size = vec(50,50),
		},
		{
			variant="default",
			size = vec(50,50),
		},
	}
})

screen:addChild(box)


events.WORLD_RENDER:register(function (delta)
	GNUI.flushUpdates()
	screen.render:updateAll()
	events.WORLD_RENDER:remove("firstFrame")
end,"firstFrame")