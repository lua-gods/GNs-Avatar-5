---@diagnostic disable: param-type-mismatch, assign-type-mismatch
--[[______   __
  / ____/ | / / Name: GN SPRING LIBRARY v1.0.1
 / / __/  |/ /  Desc: an implementation of a 2nd-order spring system
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0 ]]
-- 2nd-order system spring library
-- this library is a reimplementation of: https://www.youtube.com/watch?v=KPoeNZZ6H4s


---@class SpringAPI
local SpringAPI = {}


---@class GN.Spring<T>
---@field id integer
---@field target T
---@field gravity T
---
---@field vel T
---
---@field pos T
---@field accel T
---
---@field lpos T
---@field ltarget T
---
---@field responseSpeed T
---@field dampingCoeficient T
---@field initialResponseStrength T
---
---@field guardrailRadius T
local Spring = {}
Spring.__index = Spring



local springs = {}

local TAU = math.pi * 2
local PI = math.pi

local nID = 0

---@generic T
---@param responseSpeed T?
---@param dampingCoeficient T?
---@param initialResponseStrength T?
---@param zero T?
---@return GN.Spring<T>
function SpringAPI.new(responseSpeed, dampingCoeficient, initialResponseStrength, zero)
	zero = zero or 0
	local s = {
		pos = zero,
		vel = zero,
		responseSpeed = responseSpeed or 1,
		dampingCoeficient = dampingCoeficient or 0.05,
		initialResponseStrength = initialResponseStrength or 0,
		target = zero,
		ltarget = zero,
		accel = zero,
		gravity = zero
	}
	-- compute constraints
	s.k1 = s.dampingCoeficient / (PI * s.responseSpeed)
	s.k2 = 1 / ((2 * PI * s.responseSpeed) * (TAU * s.responseSpeed))
	s.k3 = s.initialResponseStrength * s.dampingCoeficient / (TAU * s.responseSpeed)

	setmetatable(s, Spring)
	s.id = nID
	springs[nID] = s
	nID = nID + 1
	return s
end

---@param responseSpeed Vector2|number
---@param dampingCoeficient Vector2|number
---@param initialResponseStrength Vector2|number
---@return GN.Spring<Vector2>
function SpringAPI.newVec2(responseSpeed, dampingCoeficient, initialResponseStrength)
	return SpringAPI.new(responseSpeed, dampingCoeficient, initialResponseStrength,vec(0,0))
end


---@param responseSpeed Vector3|number
---@param dampingCoeficient Vector3|number
---@param initialResponseStrength Vector3|number
---@return GN.Spring<Vector3>
function SpringAPI.newVec3(responseSpeed, dampingCoeficient, initialResponseStrength)
	return SpringAPI.new(responseSpeed, dampingCoeficient, initialResponseStrength,vec(0,0,0))
end


---@generic T
---@param self GN.Spring<T>
---@param delta number?
---@return T
function Spring:samplePos(delta)
	return math.lerp(self.lpos or self.pos, self.pos, delta or 1)
end

---@generic T
---@param self GN.Spring<T>
---@param delta number?
---@return T
function Spring:sampleTarget(delta)
	return math.lerp(self.ltarget or self.target, self.target, delta or 1)
end

---@generic T
---@param self GN.Spring<T>
---@param pos T
---@return GN.Spring<T>
function Spring:setPos(pos)
	self.pos = pos
	self.vel = pos * 0
	return self
end

---@generic T
---@param self GN.Spring<T>
---@param pos T
---@return GN.Spring<T>
function Spring:setTarget(pos)
	self.target = pos
	return self
end

---@generic T
---@param self GN.Spring<T>
---@param radius number
---@return GN.Spring<T>
function Spring:setGuardrailRadius(radius)
	self.guardrailRadius = radius
	return self
end


---@generic T
---@param self GN.Spring<T>
---@param gravity T
---@return GN.Spring<T>
function Spring:setGravity(gravity)
	self.gravity = gravity
	return self
end

function Spring:free()
	springs[self.id] = nil
end

---@generic T
---@param self GN.Spring<T>
---@param x T
---@return GN.Spring<T>
function Spring:impulse(x)
	---@cast self GN.Spring<any>
	self.vel = self.vel + x
	return self
end



local DELTA = 0.05
events.TICK:register(function ()
	for i, s in pairs(springs) do
		local pos, vel, target, gravity = s.pos, s.vel, s.target, s.gravity
		local k1, k2, k3, ltarget = s.k1, s.k2, s.k3, s.ltarget
		local gr = s.guardrailRadius
		
		local taccel = (target - ltarget) / DELTA
		s.ltarget = target
		s.lpos = pos

		pos = pos + DELTA * vel
		local accel = (target + k3 * taccel - pos - 2 * k1 * vel) / k2 + gravity
		vel = vel + DELTA * accel

		if gr then
			local dir = pos - target
			if type(dir) == "number" then
				pos = math.clamp(pos, target - gr, target + gr)
			else
				pos = target + dir:clamped(0, gr)
			end
		end

		s.pos, s.vel = pos, vel
	end
end)

return SpringAPI
