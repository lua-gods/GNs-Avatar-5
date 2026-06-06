local GNParticles = require("lib.GNparticles")

local zzzSpawner = GNParticles.registerIdentity(
	"zzz",
	GNParticles.newBillboardTexture(textures.particles,9,1,7,7),
	50,function (dust)
		dust.pos = dust.pos + dust.vel
		dust.
	end
)

zzzSpawner:spawn(vec(0,0,0),vec(0,0.1,0))