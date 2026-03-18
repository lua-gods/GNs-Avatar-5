local Nameplate = require("auto.nameplate")
local sync = require('lib.sync')
local LocalChecker = require("lib.localChecker")


local IDLE_EMOTE = animations["models.player"].FallOverSolid
local TIME_OFFSET = 1773733683856

local isLocal = false
local lastStatus
local function updateStatus()
	local status = sync.status
	local time = sync.timeSince and ((sync.timeSince) * 1000) + TIME_OFFSET
	if isLocal then
		status = 3
	end
	if status == 1 then -- idle
		Nameplate.setStatus("Idle",time)
		if lastStatus == 0 then
			IDLE_EMOTE:speed(1):setBlendDuration(0):play():setLoop("HOLD")
		end
	elseif status == 3 then -- local
		Nameplate.setStatus("Editing",time)
	else
		Nameplate.setStatus()
		if lastStatus == 1 or lastStatus == 3 then
			IDLE_EMOTE:speed(-1):setBlendDuration(0):play():setLoop("ONCE")
		end
	end
	if lastStatus ~= status then
		lastStatus = status
	end
end


LocalChecker.changed:register(function (value)
	isLocal = value
	sync.timeSince = math.floor((client:getSystemTime() - TIME_OFFSET) / 1000)
	updateStatus()
end)

sync.changes.status:register(function (value)
	updateStatus()
	if host:isHost() then
		sync.timeSince = math.floor((client:getSystemTime() - TIME_OFFSET) / 1000)
	end
end)

sync.changes.timeSince:register(function (value)
	updateStatus()
end)

if not host:isHost() then return end

events.TICK:register(function ()
	if not client:isWindowFocused() then
		sync.status = 1
	else
		sync.status = 0
	end
end)
