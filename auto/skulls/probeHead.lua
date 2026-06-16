local ModelUtils = require("lib.modelUtils")

local SKullAPI = require("lib.GNskull")


local MODEL = models.plushie
MODEL:setVisible(false)



SKullAPI.newIdentity({
	id = "probe",
	init = function (skull, cfg)
		if skull.ctx ~= "BLOCK" then
			skull.model:newBlock("block")
			:block("minecraft:redstone_lamp[lit=true]")
			:light(15,0)
			:pos(-4,0,-4)
			:scale(0.5,0.5,0.5)
		end
	end,
})

