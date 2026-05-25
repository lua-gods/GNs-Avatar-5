local dontyoulecturemewithyour30dollarhaircut = require("lib.dontyoulecturemewithyour30dollarhaircut")
events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
	if path and id == "minecraft:entity.wind_charge.wind_burst" then
		dontyoulecturemewithyour30dollarhaircut.playRandom(pos)
		return true
	end
end)

