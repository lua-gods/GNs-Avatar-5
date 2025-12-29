local GNUI = require("lib.GNUI.main")

local screen,renderer = GNUI.getScreen()

local box = GNUI.parse{
	layout = "HORIZONTAL",
	pos = vec(100,100),
	{
		{size = vec(50,50),},
		{size = vec(50,50),},
	}
}

screen:addChild(box)


events.WORLD_RENDER:register(function (delta)
	GNUI.flushUpdates()
	renderer:updateAll()
	events.WORLD_RENDER:remove("firstFrame")
end,"firstFrame")