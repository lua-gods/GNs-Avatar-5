local ModelUtils = require("lib.modelUtils")

local SKullAPI = require("lib.GNskull")


local MODEL = models.plushie
MODEL:setVisible(false)

local DATA = {}

function SKullAPI:onDataLoad()
	
end


SKullAPI.newIdentity({
	id = "data",
	init = function (skull, cfg)
		if cfg.ctx == "BLOCK" then
			DATA[cfg.name] = DATA[cfg.name] or {name = cfg.name,count = cfg.count}
			DATA[cfg.name][cfg.id] = skull.binary
		end
	end,
	frame = function (skull, dt, df)
	end,
	tick = function (skull)
	end,
	exit = function (skull)
		print("exit")
	end
})

