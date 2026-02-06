---@diagnostic disable: param-type-mismatch
local Skull = require("lib.skull")
local Color = require("lib.color")


local MODEL = models.skull.hdhat
:copy("hdhatt")
:setPrimaryRenderType("BLURRY")
:rot(0,-20,0)
:scale(0.5)

for index, value in ipairs(MODEL.half:getAllVertices()["textures.endesga2"]) do
	value:setNormal(0,1,0)
end

MODEL:addChild(MODEL.half:copy("otherHalf"):rot(0,180,0))

---@type SkullIdentity|{}
local identity = {
	name = "HD Hat",
	id = {"hdhat"},
	modelBlock = MODEL,
	modelHat = MODEL,
	modelHud = MODEL,
	modelEntity = MODEL,
}



Skull.registerIdentity(identity)
