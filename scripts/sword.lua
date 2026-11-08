local Particles = require("lib.GNParticles")

local RANDOM_PITCH = 0.15

local ANIM_IDLE = animations.player.sword
local ANIM_ATTACK = animations.player.swordAttack1:setBlendDuration(0.1)
local ANIM_ATTACK_TWO = animations.player.swordAttack2:setBlendDuration(0.1)

local SMEAR = models.player.VFX.Smear1

local alternate = false
models.player.VFX:setVisible(true)
models.player.Roll.Sword.glow:setPrimaryRenderType("EMISSIVE_SOLID")
models.player.Roll.Sword.glow:setPrimaryRenderType("EMISSIVE_SOLID")
SMEAR:setPrimaryRenderType("EYES")
:setLight(15,15)

models.player.Roll:setVisible(true)

ANIM_IDLE:setBlendDuration(0)
ANIM_ATTACK:setBlendDuration(0,1)
ANIM_ATTACK_TWO:setBlendDuration(0,1)

--[[ BLOOM TOGGLE
local function getFibonacciAreaPoints(cx, cy, radius, numPoints)
    local points = {}
    -- The golden angle in radians
    local goldenAngle = math.pi * (3 - math.sqrt(5)) 
    
    for i = 0, numPoints - 1 do
        -- Uniform radial distribution
        local r = radius * math.sqrt(i / numPoints)
        local theta = i * goldenAngle
        
        local x = cx + r * math.cos(theta)
        local y = cy + r * math.sin(theta)
        
        table.insert(points, vec(x,y))
    end
    return points
end

local N = 64
local cube = SMEAR.Smear1Spin.cube
for index, value in ipairs(getFibonacciAreaPoints(0,0,4,64)) do
	local len = value:length() ^ 2
	local dir = value:normalized()
	cube:copy(index)
	:setPos(dir.x * len,-1,dir.y * len)
	:moveTo(SMEAR)
	:setOpacity(1/N)
	:setPrimaryRenderType("EMISSIVE")
end

SMEAR:setPrimaryRenderType("CUTOUT_CULL")
--]]

--────  SWORD SMEAR PARTICLE  ────────────────────────────────────────────────────────--
local bb = 1/16

local EXPO = 3

Particles.registerIdentity("sword.smear",SMEAR,0.5,function (p)
	p.pos = p.pos + p.vel
	p.vel = p.vel * 0.7
end,function (p)
	p.flip = math.random(2) * 2 - 3
	p.model:setRot(
		0,
		-math.deg(math.atan2(p.vel.z,p.vel.x)),
		(math.random()-0.5) * 45)
	end,function (p)
	local a = 1-p.age
	p.model.Smear1Spin
	:setRot(0,(EXPO/(p.age)-EXPO)*p.flip)
	p.model.Smear1Spin.Tip:scale(1*math.min(a^1.4,1),1,1/(math.lerp(0.8,1,a)))
end)


--────  SWORD ANIMATIONS  ────────────────────────────────────────────────────────--

local current
local function setAnimation(anim)
	if current ~= anim then
		if current then current:stop() end
		current = anim:play()
	end
end

--setAnimation(ANIM_IDLE)

local hasAttack = false

events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
	if not player:isLoaded() then return end
	if id:find("^minecraft:entity%.player%.attack.") and (pos-player:getPos()):lengthSquared() < 1 then
		hasAttack = true
		return true
	end
end)

events.TICK:register(function ()
	local heldItem = player:getHeldItem()
	local isHoldingSword = heldItem.id:find("_sword$")
	if isHoldingSword and hasAttack then
		local e = (alternate and ANIM_ATTACK_TWO or ANIM_ATTACK)
		e:stop()
		local dir = player:getLookDir().x_z:normalize()
		---@cast dir Vector3
		Particles.spawn("sword.smear",player:getPos():add(0,1.5,0) - dir,dir)
		alternate = not alternate
		setAnimation(alternate and ANIM_ATTACK_TWO or ANIM_ATTACK)
		sounds["sounds.swing"]:pitch(math.lerp(1-RANDOM_PITCH,1+RANDOM_PITCH,math.random())):pos(player:getPos()):play()
	end
	hasAttack = false
	models.player.Roll:setPos(0,0,player:isCrouching() and 5 or 0)
end)