---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / / Name: GN SPRING LIBRARY v1.1.0
 / / __/  |/ /  Desc: an implementation of a 2nd-order system spring
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0 ]]
-- source: https://www.youtube.com/watch?v=KPoeNZZ6H4s



---@class SpringRegion
---@field springs Spring[]
---@field model ModelPart
local SpringRegion = {}
SpringRegion.__type = "SpringRegion"
setmetatable(SpringRegion, {
	__type = "SpringRegion",
})

SpringRegion.__index = function (t,i)
	return rawget(t,i) or SpringRegion[i]
end


local function getProcess(springs)
	local lastTime = client:getSystemTime()
	return function ()
		local time = client:getSystemTime()
		local delta = (time - lastTime) / 1000
		lastTime = time
		delta = math.clamp(delta, 0.01,1)
		
		for i,s in pairs(springs) do
			local taccel = 0
			if not s.ltarget then
				taccel = (s.target - s.ltarget) / delta
			end
			s.ltarget = s.target
			
			s.pos = s.pos + delta * s.vel
			s.vel = s.vel + delta * (s.target + s.k3*taccel - s.pos - s.k1*s.vel - s.k1*s.vel) / s.k2
		end
	end
end


local nextID = 0
---@return SpringRegion
function SpringRegion.newSpringRegion()
	local self = {}
	local springs = {}
	nextID = nextID + 1
	
	local lastTime = client:getSystemTime()
	local model = models:newPart("SpringRegion"..nextID,"WORLD")
	model.midRender = getProcess(springs)
	
	self.springs = springs
	setmetatable(self, SpringRegion)
	return self
end


function SpringRegion:setActive(active)
	self.model.midRender = active and getProcess(self.springs) or nil
end



local defaultRegion = SpringRegion.newSpringRegion()



---@class Spring
---@field id integer
---
---@field vel number
---@field pos number
---
---@field accel number
---@field target number
---
---@field lpos number
---@field ltarget number
---
---@field responseSpeed number
---@field dampingCoeficient number
---@field initialResponseStrength number
---
---@field k1 number
---@field k2 number
---@field k3 number
local Spring = {}
Spring.__index = Spring


---@class Spring2D : Spring
---@field vel Vector2
---@field pos Vector2
---
---@field accel Vector2
---@field target Vector2
---
---@field lpos Vector2
---@field ltarget Vector2
---
---@field responseSpeed Vector2
---@field dampingCoeficient Vector2
---@field initialResponseStrength Vector2


---@class Spring3D : Spring
---@field vel Vector3
---@field pos Vector3
---
---@field accel Vector3
---@field target Vector3
---
---@field lpos Vector3
---@field ltarget Vector3
---
---@field responseSpeed Vector3
---@field dampingCoeficient Vector3
---@field initialResponseStrength Vector3



local springs = {}

local TAU = math.pi*2
local PI = math.pi


---@overload fun(responseSpeed: Vector2?, dampingCoeficient: Vector2?, initialResponseStrength: Vector2?): Spring2D
---@overload fun(responseSpeed: Vector3?, dampingCoeficient: Vector3?, initialResponseStrength: Vector3?): Spring3D
---@param responseSpeed number?
---@param dampingCoeficient number?
---@param initialResponseStrength number?
---@return Spring
function SpringRegion:new(responseSpeed,dampingCoeficient,initialResponseStrength)
	assert(type(self)=="SpringRegion","use : not . when instantiating springs")
	local spring = {
		pos = 0,
		vel = 0,
		responseSpeed = responseSpeed or 1,
		dampingCoeficient = dampingCoeficient or 0.05,
		initialResponseStrength = initialResponseStrength or 0,
		target = 0,
		ltarget = 0,
		accel = 0,
	}
	-- compute constraints
	spring.k1 = spring.dampingCoeficient / (PI * spring.responseSpeed)
	spring.k2 = 1 / ((2 * PI * spring.responseSpeed) * (TAU * spring.responseSpeed))
	spring.k3 = spring.initialResponseStrength * spring.dampingCoeficient / (TAU * spring.responseSpeed)
	
	setmetatable(spring, Spring)
	local id = #springs + 1
	spring.id = id
	self.springs[id] = spring
	return spring
end


---@param responseSpeed number|Vector3?
---@param dampingCoeficient number|Vector3?
---@param initialResponseStrength number|Vector3?
---@return Spring3D
function SpringRegion:newVec3(responseSpeed,dampingCoeficient,initialResponseStrength)
	local spring = self:new(responseSpeed,dampingCoeficient,initialResponseStrength)
	---@cast spring Spring3D
	spring.pos = vec(0,0,0)
	spring.vel = vec(0,0,0)
	spring.target = vec(0,0,0)
	spring.ltarget = vec(0,0,0)
	spring.accel = vec(0,0,0)
	return spring
end

---@param responseSpeed number|Vector2?
---@param dampingCoeficient number|Vector2?
---@param initialResponseStrength number|Vector2?
---@return Spring2D
function SpringRegion:newVec2(responseSpeed,dampingCoeficient,initialResponseStrength)
	local spring = self:new(responseSpeed,dampingCoeficient,initialResponseStrength)
	---@cast spring Spring2D
	spring.pos = vec(0,0)
	spring.vel = vec(0,0)
	spring.target = vec(0,0)
	spring.ltarget = vec(0,0)
	spring.accel = vec(0,0)
	return spring
end


function Spring:addVel(x)
	self.vel = self.vel + x
end


function Spring:free()
	table.remove(springs, self.id)
end



local lastTime = client:getSystemTime()
models:newPart("SpringProcessor","WORLD").midRender = function (_, context, part)
	local time = client:getSystemTime()
	local delta = (time - lastTime) / 1000
	lastTime = time
	delta = math.min(delta, 0.1)
	for i,s in pairs(springs) do
		local taccel = 0
		if not s.ltarget then
			taccel = (s.target - s.ltarget) / delta
		end
		s.ltarget = s.target
		
		s.pos = s.pos + delta * s.vel
		s.vel = s.vel + delta * (s.target + s.k3*taccel - s.pos - s.k1*s.vel - s.k1*s.vel) / s.k2
	end
end

return defaultRegion