local Event = require("lib.event")

local api = {
	changed = Event.new(),
	isLocal = false,
}

local INTERVAL = 3 * 20
local DELAY = 20

local life = INTERVAL

function pings.pulse()
	life = INTERVAL
end


events.WORLD_TICK:register(function ()
	life = life - 1
	if life <= 0 then
		if not api.isLocal then
			api.isLocal = true
			api.changed:invoke(true)
		end
	else
		if api.isLocal then
			api.isLocal = false
			api.changed:invoke(false)
		end
	end
end)

if not host:isHost() then return api end

events.WORLD_TICK:register(function ()
	if life < DELAY then
		pings.pulse()
	end
end)

return api