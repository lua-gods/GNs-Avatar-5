if true then return end

local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()


local container = screen:parse{
	pos=vec(50,50),
	size=vec(300,0),
	sizing={"FIXED","FIT"},
	layout="HORIZONTAL_WRAP",
	style="opaque"
}

for i = 1, 50, 1 do
	container:parse{
		type="dropdown",
		size = vec(60,0),
		entries={"bazinga","bazinga","bazinga","bazinga"}
	}
end