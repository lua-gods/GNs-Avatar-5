local ModelUtils = require("lib.modelUtils")

local SKullAPI = require("lib.GNskull")


local MODEL = models.skull.disco
MODEL:setVisible(false)

SKullAPI.newIdentity({
	id = "disco",
	init = function (skull, cfg)
		if skull.ctx ~= "OTHER" then
			cfg.count = cfg.count or 10
			local beams = {}
			for i = 1, cfg.count, 1 do
				local beam = MODEL.Beam:copy("beam#"..i):setColor(math.random(),math.random(),math.random())
				beams[i] = beam
				local rot = vec(math.random(0,360),math.random(0,360),math.random(0,360))
				beam:setRot(rot)
				beam:setPrimaryRenderType("EYES")
				skull.model:addChild(beam)
			end
			skull.model:scale(cfg.scale or 5)
			skull.beams = beams
		else
			skull.model:newBlock("block")
			:block("minecraft:pearlescent_froglight")
			:light(15,0)
			:pos(-4,0,-4)
			:scale(0.5,0.5,0.5)
		end
	end,
	frame = function (skull, cfg, dt, df)
		if skull.ctx ~= "OTHER" then
			local t = world.getTime(dt) % 360
			MODEL.Beam.Motor:setRot(t*16,0,0)
		end
	end,
	tick = function (skull)
		
	end,
	exit = function (skull)
	end
})

