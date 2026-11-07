-- fuck the action wheel WOOOO!!
local key = keybinds:fromVanilla("figura.config.action_wheel_button")

key.press = function (modifiers, self)
	host.unlockCursor = true
	return true
end

key.release = function (modifiers, self)
	host.unlockCursor = false
	return true
end