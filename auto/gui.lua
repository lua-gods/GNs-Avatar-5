local GNUI = require("lib.GNUI.main")

local box = GNUI.parse{
	size = vec(100,100),
	pos = vec(100,100),
	{
		{
			size = vec(50,50),
			pos = vec(25,25),
		}
	}
}

--printTable(box,2)