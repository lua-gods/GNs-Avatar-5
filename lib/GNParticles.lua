---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / / Name: GN PARTICLES LIBRARY v1.0.0
 / / __/  |/ /  Desc: A simple particle library
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- GNCommon > https://github.com/lua-gods/GNs-Avatar-5/blob/future/lib/GNcommon.lua
--──── OPTIMIZATIONS ────────────────────────────────────────────--
-- particles dont tick in the shadow render pass
-- model 16x scale transform is precalculated instead of applied per frame per particle
]]


local GNcommon = require("./GNcommon") ---@type GNCommon

--────  CONFIG  ────────────────────────────────────────────────────────--



---@type table<string,GN.Particle.Identity>
local IDENTITIES = {}

local SCALE = 16

local PARTICLE_WORLD = models:newPart("GNParticleWorld","WORLD"):scale(SCALE)

--──── Auto calculated configs ────────────────────────────────────────────--

local INV_SCALE = 1/SCALE

--────  Particle API  ────────────────────────────────────────────────────────--

---@class GN.ParticlesAPI
---@field identities table<string,GN.Particle.Identity>
local DustAPI = {
	identities = {}
}


--──── UTILITIES ────────────────────────────────────────────--

local i = 0
local function id() i = i + 1; return i end

local function r(a,b) return math.random() * (b - a) + a end

local function copyModel(part)
	return part:copy(id())
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
	local sprite = root:newPart("billboard","CAMERA"):newSprite("sprite")
	:texture(texture,size.x,size.y)
	:setRegion(w,h)
	:size(w,h)
	:setUVPixels(x or 0,y or 0)
	:pos(w * 0.5,h * 0.5)
	:setRenderType("CUTOUT_EMISSIVE_SOLID")
	return root,sprite
end



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
--──── Commons ────────────────────────────────────────────--

local TIME = 0
events.TICK:register(function ()
	TIME = client.getSystemTime()*0.001
end)

--──── Particle Process ────────────────────────────────────────────--

---@alias GN.Particle.ProcessMaterial (fun(Dust.Instance,pos:Vector3,vel:Vector3,scl:number):Vector3,Vector3,number?)

---Creates a new process with properties expected from a particle
---@param damping number|Vector3 # between 0 and 1, gets applied to velocity
---@param gravity Vector3 # in m/s
---@return GN.Particle.ProcessMaterial
function DustAPI.newProcessMaterial(damping, gravity)
	gravity = gravity / 20
	return function (p, pos, vel, scl)
		p.vel = (p.vel + gravity)  * damping
		p.pos = p.pos + p.vel
		return pos,vel,scl
	end
end

--──── Particle Identity ────────────────────────────────────────────--

--- this gets used when no process is giveth.
local DEFAULT_PROCESS = DustAPI.newProcessMaterial(0.95, vec(0,-1,0))



---an identity a particle can be when spawned
---@class GN.Particle.Identity
---@field id string
---@field model ModelPart
---@field duration number
---@field process GN.Particle.ProcessMaterial
---@field init GN.Particle.ProcessMaterial

---Registers a particle template to be spawned later.
---@param id string
---@param model ModelPart # The ModelPart to be displayed when a particle is spawned
---@param duration number? # (in seconds) how long the particle should last, this defaults to 1
---@param process GN.Particle.ProcessMaterial?
---@param init GN.Particle.ProcessMaterial?
function DustAPI.registerIdentity(id, model, duration, process,init)
	model:remove()
	assert(IDENTITIES[id] == nil, "Particle identity already exists: " .. id)
	assert(model, "No model provided")
	local identity = {
		id = id,
		duration = (duration or 1),
		model = model,
		process = process or DEFAULT_PROCESS,
		init = init
	}
	IDENTITIES[id] = identity
end

--──── Particle Instance ────────────────────────────────────────────--


---an physical representation of a particle
---@class GN.Particle.Instance
---@field identity GN.Particle.Identity
---@field model ModelPart
---@field lpos Vector3
---@field pos Vector3
---@field lscale number
---@field scale number
---@field vel Vector3
---@field spawnTime number
---@field age number


---@type table<GN.Particle.Identity,GN.Particle.Instance[]>
local instances = {}


---Spawns a particle.
---@param id string
---@param pos Vector3?
---@param vel Vector3?
function DustAPI.spawn(id, pos, vel)
	assert(IDENTITIES[id], "No such particle identity: " .. tostring(id))
	
	local identity = IDENTITIES[id]
	instances[identity] = instances[identity] or {}
	
	local self = {
		identity = identity,
		model = copyModel(identity.model):moveTo(PARTICLE_WORLD):scale(INV_SCALE):pos(0,-999999999,0),
		pos = pos or vec(0,0,0),
		vel = vel or vec(0,0,0),
		spawnTime = TIME,
		scale = 1,
		age = 0
	}
	if identity.init then
		local pos,vel,scl = identity.init(self,self.pos,self.vel,self.scale)
		self.pos = pos
		self.vel = vel
		self.scale = scl
	end
	if identity.process then
		local pos,vel,scl = identity.process(self,self.pos,self.vel,self.scale)
		self.pos = pos
		self.vel = vel
		self.scale = scl
	end
	instances[identity][#instances[identity]+1] = self
	return self
end


events.TICK:register(function ()
	for identity, particles in pairs(instances) do
		for i, instance in pairs(particles) do
			instance.lpos = instance.pos
			instance.lscale = instance.scale
			instance.age = (TIME - instance.spawnTime) / identity.duration
			local newPos, newVel, newScale = identity.process(instance,instance.pos,instance.vel,instance.scale)
			instance.pos = newPos or instance.pos
			instance.vel = newVel or instance.vel 
			instance.scale = (newScale) or instance.scale
			if TIME > instance.spawnTime+identity.duration then
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
				p.model
				:setPos(math.lerp(p.lpos or p.pos, p.pos, delta))
				:scale(math.lerp(p.lscale or p.scale, p.scale, delta)*INV_SCALE)
			end
		end
	end
end)


--──── Particle Spawner ────────────────────────────────────────────--

local partCache = {} ---@type table<GN.Particle.Spawner,ModelPart>
local spawners = {} ---@type table<GN.Particle.Spawner,true>
local activeSpawners = {} ---@type table<GN.Particle.Spawner,true>

---@class GN.Particle.Spawner : ModelPart
---@field identity GN.Particle.Identity # the identity of the particle to spawn
---@field private __index fun(t:table,i:string):any
---@field part ModelPart # the part that the spawner references the transform from
---@field interval number # the interval at which to spawn particles
---@field lastSpawnTime number # the last time the spawner spawned something, in ms
---@field amount integer # the amount of particles to spawn at once
---@field stock integer # the amount of particles to spawn before disabling itself, -1 for infinite
---@field extent Vector3 # The extent of the area the particles can spawn in
local DustSpawner = {}
DustSpawner.__index = function (t,i)
	return rawget(t,i) 
	or DustSpawner[i]
	or function (self,...) --TODO: find a better way to do this
		return partCache[t][i](partCache[t],...)
	end
end


---@param identity string
---@return GN.Particle.Spawner
function DustAPI.newSpawner(identity)
	local part = models:newPart("particle"..id())
	local self = {
		identity = identity,
		interval = 0.1,
		lastSpawnTime = 0,
		stock = -1,
		amount = 1,
		extent = vec(8,8,8),
		part = part,
	}
	partCache[self] = part
	spawners[self] = true
	activeSpawners[self] = true
	setmetatable(self, DustSpawner)
	return self
end

function DustSpawner:remove()
	spawners[self] = nil
	self.part:remove()
end


---@param visible boolean
---@return ModelPart
function DustSpawner:setVisible(visible)
	self.part:setVisible(visible)
	activeSpawners[self] = visible and true or nil
	return self
end


---Sets the amount to spawn before disabling itself, use `-1` for infinity, defaults to `-1`
---@param amount integer
---@return GN.Particle.Spawner
function DustSpawner:setStock(amount)
	self.stock = amount or -1
	return self
end


---Sets the amount of particles to spawn at once, defaults to `1`
---@param amount integer
---@return GN.Particle.Spawner
function DustSpawner:setAmount(amount)
	self.amount = amount or 1
	return self
end


---Sets the spawn interval in seconds, defaults to `1`
---@param interval number
---@return GN.Particle.Spawner
function DustSpawner:setInterval(interval)
	self.interval = interval or 1
	return self
end

function DustSpawner:setAreaExtent(x,y,z)
	local extent = GNcommon.vec3(x,y,z)
	self.extent = extent * 8
	return self
end


events.TICK:register(function ()
	for spawner in pairs(activeSpawners) do
		local timeSinceSpawn = TIME - spawner.lastSpawnTime
		if timeSinceSpawn > spawner.interval then
			spawner.lastSpawnTime = TIME
			for i = 1, spawner.amount, 1 do
				if spawner.stock ~= -1 then
					spawner.stock = spawner.stock - spawner.amount
					if spawner.stock <= 0 then
						spawner:setVisible(false)
					end
				end
				local mat = spawner:partToWorldMatrix()
				local e = spawner.extent
				DustAPI.spawn(spawner.identity, mat:apply(r(-e.x,e.x),r(-e.y,e.y),r(-e.z,e.z)),mat:applyDir())
			end
		end
	end
end)


return DustAPI