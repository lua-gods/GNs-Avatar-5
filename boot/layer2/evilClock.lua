local Event = require("lib.GNEvent")
local ID = "minecraft:entity.zombie.attack_iron_door"

BOOT_CLOCK = Event.new()

local function boot_clock()
	sounds:playSound(ID,client:getCameraPos(),0,1000)
end
local END_BOOT
local boot_process = function (id)
	if id == ID then
		BOOT_CLOCK:invoke()
	end
	if BOOT_CLOCK:getRegisteredCount() == 0 then
		END_BOOT()
	end
end

events.WORLD_TICK:register(boot_clock)
events.ON_PLAY_SOUND:register(boot_process)

function END_BOOT()
	events.WORLD_TICK:remove(boot_clock)
	events.ON_PLAY_SOUND:remove(boot_process)
end