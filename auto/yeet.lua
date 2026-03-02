
local existing = {}

local dontyoulecturemewithyour30dollarhaircut = require("lib.dontyoulecturemewithyour30dollarhaircut")

local i = 0

if host:isHost() and false then
	events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
		if path then
			if id =="minecraft:item.trident.throw" then
				sounds:playSound("sounds.throw"..math.random(1,2),pos,1,1)
				return true
			end
			if id == "minecraft:entity.player.attack.nodamage" then
				i = i + 1
				pings.s(i,math.floor(pos.x)+0.5,math.floor(pos.y)+0.5,math.floor(pos.z)+0.5)
				return true
			end
		end
	end)
end
