--[[______   __
  / ____/ | / / Name: GN ANIM BLEND LIBRARY v2.1.0
 / / __/  |/ /  Desc: a lightweight animation blending service library
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]
local ogIndex = figuraMetatables.Animation.__index

local DD = 0.2
local DBC = function(t)
	return math.cos(t * math.pi) * -0.5 + 0.5
end

local ind = 1 / DD
local timeStart = {}
local timeEnd = {}
local table = {}
local currentTime = {} ---@type table<Animation,number>
local animation = {} ---@type table<Animation,boolean>

---@class Animation
local Animation = {}

figuraMetatables.Animation.__index = function(self, key)
	return Animation[key] or ogIndex(self, key)
end


function Animation:play()
	if timeStart[self] == 0 or not player:isLoaded() then
		ogIndex(self, "play")(self)
		return self
	end
	table[self] = table[self] or (ogIndex(self, "getBlend")(self) or 1)
	currentTime[self] = currentTime[self] or 0
	animation[self] = true
	if self:getLoop() ~= "LOOP" then -- makes it so animations that usually stop when done will reset back to start when requested as it is playing.
		ogIndex(self, "stop")(self)
	end
	ogIndex(self, "blend")(self, currentTime[self]) -- fixes the single frame flicker when blending
	ogIndex(self, "play")(self)
	return self
end

function Animation:stop()
	if timeStart[self] == 0 or not player:isLoaded() then
		ogIndex(self, "stop")(self)
		return self
	end
	currentTime[self] = currentTime[self] or 1
	animation[self] = false
	return self
end

function Animation:setPlaying(state)
	if state then
		if not self:isPlaying() then
			self:play()
		end
	else
		if self:isPlaying() then
			self:stop()
		end
	end
	return self
end

---Sets how fast the duration of the transition when the animation is played or stopped.
---@param duration number
---@return Animation
function Animation:setBlendDuration(duration,endDuration)
	endDuration = endDuration or duration
	timeStart[self] = duration == 0 and 0 or duration and (1 / duration)
	timeEnd[self] = endDuration == 0 and 0 or endDuration and (1 / endDuration)
	return self
end

function Animation:getStartBlendDuration()
	return timeStart[self] == 0 and 0 or 1 / timeStart[self]
end

function Animation:getEndBlendDuration()
	return timeEnd[self] == 0 and 0 or 1 / timeEnd[self]
end

function Animation:blend(weight)
	if table[self] ~= weight then
		table[self] = weight
		if not animation[self] then
			ogIndex(self, "blend")(self, weight)
		end
	end
	return self
end

function Animation:setBlend(weight)
	return self:blend(weight)
end

local allowProcess = true
events.WORLD_RENDER:register(function(delta)
	allowProcess = true
end)

local lastTime = client:getSystemTime()
events.RENDER:register(function(delta, ctx, matrix)
	if allowProcess and ctx ~= "OTHER" then
		allowProcess = false
		local time = client:getSystemTime()
		local deltaFrame = (time - lastTime) / 1000
		lastTime = time

		for self, mode in pairs(animation) do
			ogIndex(self, "blend")(self,
				DBC(currentTime[self]) * (table[self] or 1))
			currentTime[self] = currentTime[self] +
				 deltaFrame * (mode and (timeStart[self] or ind) or -(timeEnd[self] or ind))
			if mode then
				if currentTime[self] > 1 then
					currentTime[self] = 1
					ogIndex(self, "blend")(self, table[self])
					animation[self] = nil
				end
			else
				if currentTime[self] < 0 then
					currentTime[self] = 0
					ogIndex(self, "blend")(self, 1)
					ogIndex(self, "stop")(self)
					animation[self] = nil
				end
			end
		end
	end
end)
