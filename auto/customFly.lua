---@diagnostic disable: assign-type-mismatch
local macro = require("lib.macros")
local Spring = require("lib.spring")

local flyMacro

flyMacro = macro.new(function (events, ...)
	animations.player.armSwingRight:speed(1.7)
	animations.player.armSwingLeft:speed(1.7)
	events.ENTITY_INIT:register(function ()
		animations.player.flyForward:play():setSpeed(0)
		animations.player.flySideways:play():setSpeed(0)
	end)
	
	local spring = Spring.newVec3(1,0.2,0)
	
	local vel = vec(0,0,0)
	local lvel = vec(0,0,0)
	
	local accel = vec(0,0,0)
	
	local sway = vec(0,0,0)
	local lsway = vec(0,0,0)
	
	events.TICK:register(function()
		lvel = vel
		vel = vectors.rotateAroundAxis(player:getBodyYaw(),player:getVelocity(),vec(0,1,0))
		
		spring.vel = spring.vel + (vel - lvel) * 10 + vel
		
		lsway = sway
		sway = spring.pos
		
		if player:getSwingArm() == "MAIN_HAND" and player:getSwingTime() == 0 then
			animations.player.armSwingRight:stop():play()
		end
		
		if player:isOnGround() then
			flyMacro:setActive(false)
		end
	end)
	
	events.RENDER:register(function (delta,ctx)
		if ctx ~= "OTHER" then
			local tvel = math.lerp(lsway,sway,delta)
			animations.player.flyForward:time(tvel.z*0.5+0.5)
			animations.player.flySideways:time(tvel.x*-0.5+0.5)
		end
	end)
	
	events.ON_EXIT:register(function ()
		animations.player.flyForward:stop()
		animations.player.flySideways:stop()
	end)
end)

function pings.fly(toggle)
	flyMacro:setActive(toggle)
end

if host:isHost() then
	local wasFlying = false
	events.TICK:register(function ()
		local isFlying = host:isFlying()
		if isFlying ~= wasFlying then
			wasFlying = isFlying
			pings.fly(isFlying)
		end
	end)
end