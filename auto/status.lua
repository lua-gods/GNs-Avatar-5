local StatusManager = require("lib.statusManager")
local Nameplate = require("auto.nameplate")

local emote = animations["models.player"].FallOverSolid


StatusManager.STATUS_CHANGED:register(function (state,lastState)
	if state == 1 then
		emote:stop():speed(1):play()
		:setLoop("HOLD")
		Nameplate.setStatus("Idle",true)
	elseif state == 0 then
		if lastState == 1 then
			emote:stop():speed(-2):play()
			:setLoop("ONCE")
		end
		Nameplate.setStatus()
	elseif state == 2 then
		Nameplate.setStatus("Typing",true)
	end
end)