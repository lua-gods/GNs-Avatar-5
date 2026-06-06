---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's Particle Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

local i = 0

local function id()
	i = i + 1
	return i
end


---@type table<GN.Particles.Identity,GNDust.Instance[]>
local instances = {}

---@type table<string,GN.Particles.Identity>
local IDENTITIES = {}

local function copyModel(part)
	return part:copy(id())
end


---@class GN.ParticlesAPI
---@field identities table<string,GN.Particles.Identity>
local DustAPI = {
	identities = {}
}

---an identity a particle can be when spawned
---@class GN.Particles.Identity
---@field id string
---@field model ModelPart
---@field duration number
---@field process fun(Dust.Instance)

---an physical representation of a particle
---@class GNDust.Instance
---@field identity GN.Particles.Identity
---@field model ModelPart
---@field lpos Vector3
---@field pos Vector3
---@field vel Vector3
---@field age number


---Creates a new process with properties expected from a particle
---@param damping number|Vector3 # between 0 and 1, gets applied to velocity
---@param gravity Vector3 # in m/s
---@return fun(Dust.Instance)
function DustAPI.newProcessMaterial(damping, gravity)
	gravity = gravity / 20
	return function (p)
		p.vel = (p.vel + gravity)  * damping
		p.pos = p.pos + p.vel
	end
end


---@class GNDust.Spawner
---@field private __index table
---@field identity GN.Particles.Identity
local DustSpawner = {}
DustSpawner.__index = DustSpawner

local SPAWNER_LINK = {}

---@param identity string
---@return GNDust.Spawner
function DustAPI.newSpawner(identity)
	local self = setmetatable({identity = identity}, DustSpawner)
	return self
end

function DustSpawner:spawn(pos,vel)
	return DustAPI.spawn(self.identity,pos, vel)
end


---@param texture Texture
---@param x number?
---@param y number?
---@param w number?
---@param h number?
function DustAPI.newBillboardTexture(texture,x,y,w,h)
	local size = texture:getDimensions()
	w,h = w or size.x, h or size.y
	local root = models:newPart("gndust"..id())
	root:setParentType("WORLD")
	root:newPart("billboard","CAMERA")
	:newSprite("sprite")
	:texture(texture,size.x,size.y)
	:setRegion(w,h)
	:size(w,h)
	:setUVPixels(x or 0,y or 0)
	:pos(w * 0.5,h * 0.5)
	:setRenderType("CUTOUT_EMISSIVE_SOLID")
	return root
end


--- this gets used when no process is giveth.
local DEFAULT_PROCESS = DustAPI.newProcessMaterial(0.95, vec(0,-1,0))


---Registers a particle template to be spawned later.
---@param id string
---@param model ModelPart # The ModelPart to be displayed when a particle is spawned
---@param duration number? # (in seconds) how long the particle should last, this defaults to 1
---@param process fun(dust: GNDust.Instance)?
function DustAPI.registerIdentity(id, model, duration, process)
	model:remove()
	assert(IDENTITIES[id] == nil, "Particle identity already exists: " .. id)
	assert(model, "No model provided")
	local identity = {
		id = id,
		duration = (duration or 1) * 20,
		model = model,
		process = process or DEFAULT_PROCESS,
	}
	IDENTITIES[id] = identity
	return DustAPI.newSpawner(id)
end


---Spawns a particle.
---@param id string
---@param pos Vector3?
---@param vel Vector3?
function DustAPI.spawn(id, pos, vel)
	assert(IDENTITIES[id], "No such particle identity: " .. tostring(id))
	local identity = IDENTITIES[id]
	instances[identity] = instances[identity] or {}
	
	local instance = {
		identity = identity,
		model = copyModel(identity.model):setParentType("WORLD"):moveTo(models),
		pos = pos or vec(0,0,0),
		vel = vel or vec(0,0,0),
		age = 0,
	}

	instances[identity][#instances[identity]+1] = instance
	return instance
end


events.TICK:register(function ()
	for identity, particles in pairs(instances) do
		for i, instance in pairs(particles) do
			instance.lpos = instance.pos
			identity.process(instance)
			instance.age = instance.age + 1
			if instance.age > identity.duration then
				instance.model:remove()
				particles[i] = nil
			end
		end
	end
end)

events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" or ctx == "FIRST_PERSON" then
		for identity, particles in pairs(instances) do
			for i, p in pairs(particles) do
				p.model:setPos(math.lerp(p.lpos or p.pos, p.pos, delta) * 16)
			end
		end
	end
end)

--[────────────────────────-< Utility Functions >-────────────────────────]--

local UP = vec(0,1,0)

---@overload fun(dir: Vector3, spreadAngle: number): Vector3
---@param x number
---@param y number
---@param z number
---@param spreadAngle number
---@return Vector3
function DustAPI.dirRandom(x,y,z,spreadAngle)
	local dir
	local spread
	if type(x) == "Vector3" then
		dir = x
		spread = y
	else
		dir = vec(x,y,z)
		spread = spreadAngle
	end
	
	local localFinal = vectors.angleToDir(vec(math.random()*spread+90,math.random()*360))
	
	if math.abs(dir.x*dir.z) < 0.0001 then
		return localFinal * -dir.y
	end
	return vectors.rotateAroundAxis(math.deg(math.asin(dir:normalized().y))+90,localFinal,dir:copy():cross(UP))*dir:length()
end

return DustAPI