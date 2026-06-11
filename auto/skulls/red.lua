local ModelUtils = require("lib.modelUtils")

local MODEL = models.plushie
MODEL:setVisible(false)

---@type GN.Skull.Identity
return {
	id = "red",
	init = function (skull)
		local model = ModelUtils.deepCopy(MODEL):setVisible(true)
		model:setColor(1,0,0):rot(45,0,0)
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