
--────────────────────────-< DEPENDENCIES >-────────────────────────--
local Nameplate = require("auto.nameplate")
local sync = require('lib.GNSync')
local LocalChecker = require("lib.localChecker")

if avatar:getMaxTickCount() <= 8192 then return end

--────────────────────────-< CONFIG >-────────────────────────--

local IDLE_EMOTE = animations["models.player"].eyeCloseSit
local TIME_OFFSET = 1773733683856

--────────────────────────-< END OF CONFIG >-────────────────────────--

IDLE_EMOTE
:setBlendDuration(0.2)
:setOverride(true)
:setPriority(1)

local isLocal = false
local lastStatus
local function updateStatus()
	local status = sync.status
	local time = sync.timeSince and ((sync.timeSince) * 1000) + TIME_OFFSET
	if isLocal then
		status = 3
	end
	if status == 1 then -- idle
		Nameplate.setStatus("Unfocused",time)
		if lastStatus ~= 1 then
			IDLE_EMOTE:stop():play()
		end
	elseif status == 2 then -- typing
		Nameplate.setStatus("typing..",time)
	elseif status == 3 then -- local
		Nameplate.setStatus("in Local",time)
	else
		Nameplate.setStatus()
		if lastStatus == 1 then
			if IDLE_EMOTE then
				IDLE_EMOTE:stop()
			end
		end
	end
	if lastStatus ~= status then
		lastStatus = status
	end
end

--────────────────────────-< Update Listeners >-────────────────────────--

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

--────────────────────────-< Host Stuff >-────────────────────────--
if not host:isHost() then return end

-- the part that tells what state the host is in.
events.TICK:register(function ()
	if not client:isWindowFocused() then
		sync.status = 1 -- idle
	else
		if sync.status ~= 1 then
			if host:isChatOpen() then
				sync.status = 2 -- typing
			else
				sync.status = 0 -- focursed
			end
		else
			if not host:isChatOpen() then
				sync.status = 0 -- focused
			end
		end
	end
end)
