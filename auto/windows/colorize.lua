local Macro = require("lib.GNMacros")

local ColorPickerWindow = require("auto.windows.utils.colorPicker")

local colorMacro

colorMacro = Macro.new(function (events, screen, GNUI)
	print("A")
	local ColorPicker = ColorPickerWindow(screen, GNUI)
	ColorPicker.COLOR_CHANGED:register(function (color)
	end)
	ColorPicker.ON_CLOSE:register(function ()
		print("E")
		colorMacro:setActive(false)
	end)
end)

return colorMacro