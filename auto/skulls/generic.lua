local ModelUtils = require("lib.modelUtils")


---@type GN.Skull.Identity
return {
	id = "generic",
	init = function (skull, cfg)
		skull.model:scale(cfg.scale or 1)
	end,
	frame = function (skull, dt, df)
	end,
	tick = function (skull)
		
	end,
	exit = function (skull)
		print("exit")
	end
}