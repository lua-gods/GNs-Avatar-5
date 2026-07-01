---@diagnostic disable: assign-type-mismatch
local Sync = require("lib.GNSync")
local Macros = require("lib.GNMacros")
local Spring = require("lib.GNSpring")
local Parts = require("auto.parts")


local VELOCITY_INTENSITY = 1
local ACCELERATION_INTENSITY = 10

if silly and host:isHost() then
	silly:setFly(true)
end

local flyMacro

flyMacro = Macros.new(function(events, ...)
	events.ENTITY_INIT:register(function()
		animations.player.flyForward:play():pause()
		animations.player.flySideways:play():pause()
	end)

	local spring = Spring.newVec3(1, 0.2, 0)

	local vel = vec(0, 0, 0)
	local lvel = vec(0, 0, 0)

	local sway = vec(0, 0, 0)
	local lsway = vec(0, 0, 0)

	events.TICK:register(function()
		lvel = vel
		vel = player:getVelocity()
		vel = vectors.rotateAroundAxis(player:getBodyYaw(), vel, vec(0, 1, 0))

		
		spring.vel = spring.vel + (vel - lvel) * ACCELERATION_INTENSITY + vel * VELOCITY_INTENSITY

		lsway = sway
		sway = spring.pos


		if player:isOnGround() then
			flyMacro:setActive(false)
		end
	end)

	events.RENDER:register(function(delta, ctx)
		delta = client:getFrameTime()
		if ctx ~= "OTHER" then
			-- arm fix
			local isUsingItem = player:isUsingItem()
			Parts.RIGHT_ARM:setRot(isUsingItem and vanilla_model.RIGHT_ARM:getOriginRot() or nil)
			Parts.LEFT_ARM:setRot(isUsingItem and vanilla_model.LEFT_ARM:getOriginRot() or nil)

			local swingArm = player:getSwingArm()
			if swingArm then
				if swingArm == "MAIN_HAND" then
					Parts.RIGHT_ARM:setRot(vanilla_model.RIGHT_ARM:getOriginRot())
				else
					Parts.LEFT_ARM:setRot(vanilla_model.LEFT_ARM:getOriginRot())
				end
			end

			local tvel = math.lerp(lsway, sway, delta)
			animations.player.flyForward:time(tvel.z * 0.5 + 0.5)
			animations.player.flySideways:time(tvel.x * -0.5 + 0.5)
		end
	end)

	events.ON_EXIT:register(function()
		animations.player.flyForward:stop()
		animations.player.flySideways:stop()
	end)
end)

Sync.changes.isFlying:register(function(state)
	flyMacro:setActive(state)
end)

if host:isHost() then
	events.TICK:register(function()
		Sync.isFlying = host:isFlying()
	end)
end
