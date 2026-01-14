# flags: host_only


local alivePos
local aliveRot

events.TICK:register(function ()
	if player:getPermissionLevel() >= 2 then
		if	 player:getHealth() == 0 and player:getGamemode() == "CREATIVE" then
			host:sendChatCommand(("tp @s %s %s %s %s %s"):format(alivePos.x,alivePos.y,alivePos.z,aliveRot.y,aliveRot.x))
		else
			alivePos = player:getPos()
			aliveRot = player:getRot()
		end
	end
end)
--events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
--	if player:isLoaded() and path then
--		if id == "minecraft:entity.player.death" or id == "minecraft:entity.player.hurt" and (pos-player:getPos()):length() < 0.1 then
--			return true
--		end
--	end
--end)