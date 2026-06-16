local ModelUtils = require("lib.modelUtils")

local SKullAPI = require("lib.GNskull")
local NBS = require("lib.nbs")

local MODEL = models.skull.sunflower
MODEL:setVisible(false)

animations["skull.sunflower"].sunflower:speed(0.5):play()

local track = NBS.loadFromPath("lawn")
track.loop = true
SKullAPI.newIdentity({
	id = "sunflower",
	init = function (skull, cfg)
		local model = MODEL:copy("sun"):setVisible(true)
		model:scale(0.5)
		cfg.squish = 0
		skull.model:addChild(model)
		if skull.ctx:find("HAND") or skull.ctx == "BLOCK" then
			cfg.musicPlayer = NBS.newMusicPlayer(track)
			cfg.musicPlayer:play():setAttenuation(0.5):setVolume(0.5)
			cfg.musicPlayer.NOTE_PLAYED:register(function (cnote) 
				cfg.squish = math.max(cnote.volume, cfg.squish)
			end)
		end
		if skull.ctx == "HEAD" then
			model:pos(0,7,0)
		elseif skull.ctx:find("FIRST_PERSON") then
			model:pos(0,7,0)
		else
			model:pos(0,1,0)
		end
		if skull.block then
			cfg.musicPlayer:setPos(skull.block:getPos():add(0.5,0.5,0.5))
		end
	end,
	frame = function (skull,cfg, dt, df)
		cfg.squish = cfg.squish * 0.9
		local s = 1-cfg.squish
		skull.model
		:scale(1/s,s,1/s)
	end,
	tick = function (skull,cfg)
		if cfg.musicPlayer then
			if skull.entity then
				local speed = 1 + skull.entity:getVelocity().xz:length()
				cfg.musicPlayer:speed(speed):pitch(speed)
				cfg.musicPlayer:setPos(skull.entity:getPos())
			end
		end
	end,
	exit = function (skull, cfg)
		if cfg.musicPlayer then
			cfg.musicPlayer:stop()
		end
	end
})

