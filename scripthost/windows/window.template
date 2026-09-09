local Macro = require("lib.GNMacros")

local Window = require("lib.GNUI-WindowManager.widgets.window")
local Event = require("lib.GNEvent")


local myApp

myApp = Macro.new(function (events, screen, GNUI)
	local Window = Window.new(screen)
	Window.ON_CLOSE:register(function ()
		myApp:setActive(false)
	end)
	
	events.ON_EXIT:register(function ()
		Window:free()
	end)
end)

return myApp