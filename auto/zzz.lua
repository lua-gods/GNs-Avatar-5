local GNParticles = require("lib.GNparticles")

local zzzSpawner = GNParticles.registerIdentity(
	"zzz",
	GNParticles.newBillboardTexture(textures.particles,9,1,7,7),
	50,function (dust)
		dust.vel = vec(0,0.05,0)
		dust.pos = dust.pos + dust.vel
		local t = dust.age * 0.1
		dust.pos.x = dust.pos.x + math.sin(t) * 0.05
		dust.pos.z = dust.pos.z + math.cos(t) * 0.05
	end
)

--TODO: add scale property
--TODO: add init callback to identity

zzzSpawner:spawn(vec(0,0,0))