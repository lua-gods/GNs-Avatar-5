
--────────────────────────-< DEPENDENCIES >-────────────────────────--
local Nameplate = require("auto.nameplate")
local Sync = require('lib.GNSync')
local LocalChecker = require("lib.localChecker")

if avatar:getMaxTickCount() <= 8192 then return end

--────────────────────────-< CONFIG >-────────────────────────--

local IDLE_EMOTE = animations["models.player"].eyeCloseSit
local IDLE_EMOTE2 = animations["models.player"].FallOverSolid:setBlendDuration(0)
local TIME_OFFSET = 1780386870274

--──── ZZZ ────────────────────────────────────────────--

local GNParticles = require("lib.GNParticles")
local Easings = require("lib.GNEasings")

GNParticles.registerIdentity(
	"zzz",
	GNParticles.newBillboardTexture(textures.particles,9,1,7,7),
	3,
	function (dust,pos,vel,scl)
		
		pos = pos + vel
		local t = dust.age * 5
		pos.x = pos.x + math.sin(t) * 0.02
		pos.z = pos.z + math.cos(t) * 0.02
		scl = math.clamp((0.5-math.abs(dust.age-0.5))*3,0,1)
		scl = Easings.outSine(scl) * 0.5
		return pos,vel,scl
	end,
	function (dust,pos,vel,scl)
		vel = vec(0,0.02,0)
		return pos,vel,scl
	end
)

--TODO: add scale property
--TODO: add init callback to identity

local zzzSpawner = GNParticles.newSpawner("zzz")
:setInterval(0.75)


zzzSpawner:moveTo(models.player.Base.Torso.Waist.Chest.Head)
:pos(0,32,0)
zzzSpawner:setVisible(false)
--────────────────────────-< END OF CONFIG >-────────────────────────--

IDLE_EMOTE
:setBlendDuration(0.2)
:setOverride(true)
:setPriority(1)

local isLocal = false
local lastStatus
local function updateStatus()
	local status = Sync.status
	local time = Sync.timeSince and ((Sync.timeSince) * 1000) + TIME_OFFSET
	if isLocal then
		status = 3
	end
	if status == 1 then -- idle
		Nameplate.setStatus(":zzz:",time)
		if lastStatus ~= 1 then
			IDLE_EMOTE:stop():play()
			IDLE_EMOTE2:stop():play()
			zzzSpawner:setVisible(true)
		end
	elseif status == 2 then -- typing
		Nameplate.setStatus(":typing_animated:",time)
	elseif status == 3 then -- local
		Nameplate.setStatus(":cloud::back::no_entry:",time)
	elseif status == 4 then -- typing command
		Nameplate.setStatus(":typing_command:",time)
	elseif status == 5 then -- inventory
		Nameplate.setStatus(":mcb_chest:",time)
	else
		Nameplate.setStatus()
		if lastStatus == 1 then
			if IDLE_EMOTE then
				IDLE_EMOTE:stop()
				IDLE_EMOTE2:stop()
				zzzSpawner:setVisible(false)
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
	Sync.timeSince = math.floor((client:getSystemTime() - TIME_OFFSET) / 1000)
	updateStatus()
end)

Sync.changes.status:register(function (value)
	updateStatus()
	if host:isHost() then
		Sync.timeSince = math.floor((client:getSystemTime() - TIME_OFFSET) / 1000)
	end
end)

Sync.changes.timeSince:register(function (value)
	updateStatus()
end)

--────────────────────────-< Host Stuff >-────────────────────────--
if not host:isHost() then return end

-- the part that tells what state the host is in.
events.TICK:register(function ()
	if not client:isWindowFocused() then
		Sync.status = 1 -- idle
	else
		-- only swap to typing if status is not idle
		if Sync.status ~= 1 then 
			local screen = host:getScreen()
			if host:isChatOpen() then
				if host:getChatText():find("^/") then
					Sync.status = 4 -- typing command
				else
					Sync.status = 2 -- typing
				end
			elseif screen == "net.minecraft.class_490" then
				Sync.status = 5 -- inventory
			elseif screen == "net.minecraft.class_433" then
				Sync.status = 0 -- pause menu
			end
		end
		if not host:getScreen() then
			Sync.status = 0 -- focused
		end
	end
end)
