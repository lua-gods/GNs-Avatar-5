local Macros = require("lib.GNMacros")

local instance = Macros.new(function(events)
	print("init")
	events.TICK:register(function ()
		print("ticky")
	end)
	events.ON_EXIT:register(function ()
		print("exit")
	end)
end)


events.TICK:register(function()
	local is = player:isSneaking()
	instance:setActive(is)
end)