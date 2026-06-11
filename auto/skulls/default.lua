local ModelUtils = require("lib.modelUtils")

local MODEL = models.plushie
MODEL:setVisible(false)

---@type GN.Skull.Identity
return {
	id = "default",
	init = function (skull, cfg)
		local plushie = ModelUtils.deepCopy(MODEL):setVisible(true)
		local scale = cfg.scale or 1
		plushie:setScale(scale)
		skull.model:addChild(plushie)
	end,
	frame = function (skull, dt, df)
	end,
	tick = function (skull)
		
	end,
	exit = function (skull)
		print("exit")
	end
}