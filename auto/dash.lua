# flags: host_only

local Sequencer = require('lib.sequencer')

local STRENGTH = 8

local dash = keybinds:newKeybind("dash","key.mouse.5")

local timer = 0

dash:onPress(function (modifiers, self)
	timer = 0
	events.TICK:register(function ()
		timer = timer + 0.1
		renderer:setFOV(1/(1+timer))
	end,"dashCharge")
end):onRelease(function (modifiers, self)
	events.TICK:remove("dashCharge")
	if player:isLoaded() then
		renderer:setFOV()
		silly:setVelocity(player:getLookDir() * STRENGTH * timer)
	end
end)