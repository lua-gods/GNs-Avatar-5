--[[______   __
  / ____/ | / / Name: GN LOCAL CHECKER SERVICE v1.0.0
 / / __/  |/ /  Desc: a simple script to check if your avatar is local on non host clients.
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- GNEvent > https://github.com/lua-gods/GNs-Avatar-5/blob/future/lib/GNEvent.lua
]]

local Event = require("lib.GNEvent")


--- how many ticks to wait before checking if your avatar is local
-- defaults to 60 ticks (3 second)
local INTERVAL = 60
--- the number of ticks in advance to send a heartbeat to avoid desync gaps.
-- defaults to 20 ticks (1 second ahead)
local ADVANCE = 20


local LocalCheckerAPI = {
	changed = Event.new(),
	isLocal = false,
}

local life = INTERVAL
function pings.gnlocalcheckerheartbeat() life = INTERVAL end

events.WORLD_TICK:register(function ()
	life = life - 1
	if life <= 0 then
		if not LocalCheckerAPI.isLocal then
			LocalCheckerAPI.isLocal = true
			LocalCheckerAPI.changed:invoke(true)
		end
	else
		if LocalCheckerAPI.isLocal then
			LocalCheckerAPI.isLocal = false
			LocalCheckerAPI.changed:invoke(false)
		end
	end
end)

if not host:isHost() then return LocalCheckerAPI end

events.WORLD_TICK:register(function ()
	if life < ADVANCE then
		pings.gnlocalcheckerheartbeat()
	end
end)

return LocalCheckerAPI