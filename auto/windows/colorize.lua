local Macro = require("lib.GNMacros")

local ColorPickerWindow = require("auto.windows.utils.colorPicker")

local colorMacro

colorMacro = Macro.new(function (events, screen, GNUI)
	local ColorPicker = ColorPickerWindow(screen, GNUI)
	ColorPicker.COLOR_CHANGED:register(function (color)
	end)
	ColorPicker.ON_CLOSE:register(function ()
		colorMacro:setActive(false)
	end)
	
	events.ON_EXIT:register(function ()
		ColorPicker:free()
	end)
end)

return colorMacro