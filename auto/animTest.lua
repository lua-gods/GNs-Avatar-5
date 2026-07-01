local GNanim = require("lib.GNanim")

local UP = vec(0, 1, 0)

local WALK = animations.player.walk
local SPRINT = animations.player.run
local DROP = animations.player.drop
local IDLE = animations.player.idle
local SNEAK = animations.player.sneak

local SLIDE = animations.player.slide
local JUMP1 = animations.player.jump1
local JUMP2 = animations.player.jump2

JUMP1:speed(0)
:setBlendDuration(0.15)
JUMP2:speed(0)
:setBlendDuration(0.15)
SLIDE:setSpeed(0)
:setBlendDuration(0.5)

local JUMP = GNanim.newGroup("ROUND_ROBIN",JUMP1,JUMP2)

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
local accel = 0
local onGround = false
events.TICK:register(function()
	local byaw = player:getBodyYaw()
	llvel = lvel
	lvel = vectors.rotateAroundAxis(byaw, player:getVelocity(), UP)
	accel = lvel.xz:length() - llvel.xz:length()
	local nowOnGround = player:isOnGround()
	
	
	if onGround ~= nowOnGround then
		if nowOnGround then
			DROP:stop():play():blend(math.clamp(-lvel.y*5,0,1))
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
		if accel > -0.015 then
			if walkSpeed > 0.02 then
				if player:isSprinting() or walkSpeed > 0.3 then
					set(SPRINT)
					SPRINT:blend(math.min(math.abs(vel.z * 7), 1))
					SPRINT:speed(vel.xz:length() * 7)
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
			SLIDE:blend(math.clamp(vel.xz:length()*7,0,1))
			SLIDE:setTime(((math.deg(math.atan2(-vel.x, vel.z)))/360) % 1)
		end
	else
		set(JUMP)
		JUMP
		:setTime(0.5 + -vel.y)
		--:blend(0.5 + math.min(math.abs(vel.z* 2),1))
	end
	
	if player:isSneaking() then
		set(SNEAK,2)
	else
		set(nil,2)
	end
end)
