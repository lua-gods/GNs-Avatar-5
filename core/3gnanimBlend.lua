

local ogIndex = figuraMetatables.Animation.__index

local ENABLED = false

local DEFAULT_DURATION = 0.2
local DEFAULT_BLEND_CALLBACK = function (t)
	return  math.cos(t* math.pi) * -0.5 + 0.5
end

local invDuration = 1/DEFAULT_DURATION
local durationTime = {}
local trueBlend = {}
local activeTime = {} ---@type table<Animation,number>
local active = {} ---@type table<Animation,boolean>

---@class Animation
local Animation = {}

figuraMetatables.Animation.__index = function(self, key)
	return Animation[key] or ogIndex(self,key)
end


function Animation:play()
	if durationTime[self] == 0 or not player:isLoaded() then
		ogIndex(self,"play")(self)
		return self
	end
	trueBlend[self] = trueBlend[self] or (ogIndex(self,"getBlend")(self) or 1)
	activeTime[self] = activeTime[self] or 0
	active[self] = true
	ogIndex(self,"play")(self)
	return self
end


function Animation:stop()
	if durationTime[self] == 0 or not player:isLoaded() then
		ogIndex(self,"stop")(self)
		return self
	end
	activeTime[self] = activeTime[self] or 1
	active[self] = false
	return self
end


---Sets how fast the duration of the transition when the animation is played or stopped.
---@param duration number
---@return Animation
function Animation:setBlendDuration(duration)
	durationTime[self] = duration == 0 and 0 or duration and (1/duration)
	return self
end


function Animation:blend(blend)
	if active[self] then
		trueBlend[self] = blend
	else
		ogIndex(self,"blend")(self,blend)
	end
	return self
end

local allowProcess = true
events.WORLD_RENDER:register(function (delta)
	allowProcess = true
end)

local lastTime = client:getSystemTime()
events.RENDER:register(function (delta, ctx, matrix)
	
	if allowProcess and ctx ~= "OTHER" then
		allowProcess = false
		local time = client:getSystemTime()
		local deltaFrame = (time - lastTime) / 1000
		lastTime = time
		
		for self, mode in pairs(active) do
			ogIndex(self,"blend")(self,DEFAULT_BLEND_CALLBACK(activeTime[self]) * (trueBlend[self] or 1))
			activeTime[self] = activeTime[self] + deltaFrame * (mode and 1 or -1) * (durationTime[self] or invDuration)
			if mode then
				if activeTime[self] > 1 then
					activeTime[self] = nil
					ogIndex(self,"blend")(self, trueBlend[self])
					active[self] = nil
				end
			else
				if activeTime[self] < 0 then
					activeTime[self] = nil
					ogIndex(self,"blend")(self,1)
					ogIndex(self,"stop")(self)
					trueBlend[self] = nil
					active[self] = nil
				end
			end
		end
	end
end)