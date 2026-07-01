local UP = vec(0, 1, 0)

local WALK = animations.player.walk
local SPRINT = animations.player.run
local DROP = animations.player.drop
local IDLE = animations.player.idle
local SNEAK = animations.player.sneak

local SLIDE = animations.player.slide


SLIDE:setSpeed(0)
:setBlendDuration(0.5)

local animLayers = {}
local function set(anim,layer)
	layer = layer or 1
	local lanim = animLayers[layer]
	if lanim ~= anim then
		if lanim then
			lanim:stop()
		end
		animLayers[layer] = anim
		if anim then
			anim:play()
		end
	end
end

local parts = require("auto.parts")

for key, part in pairs(parts) do
	part:setParentType("NONE")
end

local llvel = vec(0, 0, 0)
local lvel = vec(0, 0, 0)
local accel = vec(0, 0, 0)
local onGround = false
events.TICK:register(function()
	local byaw = player:getBodyYaw()
	llvel = lvel
	lvel = vectors.rotateAroundAxis(byaw, player:getVelocity(), UP)
	accel = lvel - llvel
	local nowOnGround = player:isOnGround()
	
	
	if onGround ~= nowOnGround then
		if nowOnGround then
			DROP:stop():play():blend(math.min(-lvel.y*5,1))
		end
		onGround = nowOnGround
	end
end)

events.RENDER:register(function(delta, ctx, matrix)
	local sneak = player:isCrouching()
	parts.BASE:setPos(0,(sneak and 2.14 or 0),0)
	
	delta = client:getFrameTime()
	if not (ctx == "RENDER" or ctx == "FIRST_PERSON") then return end
	local vel = math.lerp(llvel, lvel, delta)
	local walkSpeed = math.abs(vel.z)
	if player:isOnGround() then
		if accel.z > -0.01 then
			if walkSpeed > 0.02 then
				if player:isSprinting() or walkSpeed > 0.3 then
					set(SPRINT)
					SPRINT:blend(math.min(math.abs(vel.z * 7), 1))
					SPRINT:speed(vel.z * 7)
				else
					set(WALK)
					WALK:blend(math.min(math.abs(vel.z * 7), 1))
					WALK:speed(math.max(math.abs(vel.z) * 7,1) * math.sign(vel.z))
				end
			else
				set(IDLE)
			end
		else
			set(SLIDE)
			SLIDE:setBlend(math.min(vel.z*7,1))
			--SLIDE:setTime((player:getBodyYaw(delta)/360) % 1)
		end
	else
		set(IDLE)
	end
	
	if player:isSneaking() then
		set(SNEAK,2)
	else
		set(nil,2)
	end
end)
