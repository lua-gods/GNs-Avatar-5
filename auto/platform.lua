if not host:isHost() then return end


local DECAY_START = 20
local DECAY_MULTIPLIER = 0.9


local diff = vec(0, 0, 0)
local lastPos
local entity

local wasOnGround = false
local decay = 0

events.TICK:register(function()
	local ppos = player:getPos()
	local vel = vec(table.unpack(player:getNbt().Motion))

	local isOnGround = player:isOnGround()
	if wasOnGround ~= isOnGround then
		wasOnGround = isOnGround
		if isOnGround then
			local ppos = player:getPos()
			local range = player:getBoundingBox().x * 0.5
			for i = 1, 100, 1 do
				local o = vec(math.lerp(-range, range, math.random()), 0,
					math.lerp(-range, range, math.random()))
				entity = raycast:entity(ppos + o - vec(0, 0.1, 0), ppos + o - vec(0, 0.2, 0))
				if entity then
					break
				end
			end
			if not entity then
				if diff then
					silly:setVelocity(vel + diff)
				end
			end
		end
	end
	if entity then
		if lastPos then
			local pos = entity:getPos()
			diff = pos - lastPos
		end
		lastPos = entity:getPos()

		if isOnGround then
			decay = DECAY_START
		else
			decay = decay - 1
			if decay < 0 then
				entity = nil
				lastPos = nil
			end
		end
	else
		diff = diff * DECAY_MULTIPLIER
		entity = nil
		lastPos = nil
	end

	if diff then
		silly:setPos(ppos + diff)
	end
end)
