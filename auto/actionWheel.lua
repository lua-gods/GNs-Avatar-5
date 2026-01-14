
-- I dont have an action wheel, I override the key to unlock my cursor instead.

local KEY_ACTION_WHEEL = keybinds:fromVanilla("figura.config.action_wheel_button")
local KEY_ESCAPE = keybinds:newKeybind("escape","key.keyboard.escape")

local unlocked = false

KEY_ACTION_WHEEL:gui(true)
KEY_ESCAPE:gui(true)

KEY_ESCAPE.press = function ()
	if unlocked then
		unlocked = false
		host.unlockCursor = unlocked
		return true
	end
end

KEY_ACTION_WHEEL.press = function ()
	unlocked = not unlocked
	host.unlockCursor = unlocked
	return true
end