local ModelUtils = require("lib.modelUtils")

local MODEL = models.plushie
MODEL:setVisible(false)

---@type GN.Skull.Identity
return {
	id = "blue",
	init = function (skull)
		local model = ModelUtils.deepCopy(MODEL):setVisible(true)
		model:setColor(0,0,1):rot(0,0,45)
		skull.model:addChild(model)
	end,
	frame = function (skull, dt, df)
	end,
	tick = function (skull)
		
	end,
	exit = function (skull)
		print("exit")
	end
}