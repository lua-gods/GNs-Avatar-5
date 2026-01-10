local uuid = "Just_Ghasty"

local RADIUS = 10
local SPEED = 0.1


events.WORLD_RENDER:register(function ()
	local players = world.getPlayers()
	local player = players[uuid]
	local t = client:getSystemTime() / 1000 * SPEED
	if player and player:isLoaded() then
		host:setPos(player:getPos() + vec(math.sin(t),math.sin(t)*0.25,math.cos(t))*RADIUS)
		--host:setRot(0.5,(math.deg(-t)+180) % 360)
	end
end)