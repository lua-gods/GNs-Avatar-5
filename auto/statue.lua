local modelUtils = require("lib.modelUtils")

local statue = modelUtils.deepCopy(models.player)

statue.Base.Torso.Waist.Chest.Head.Face.Leye.LPupil:setUVPixels(-0.6,0)
statue.Base.Torso.Waist.Chest.Head.Face.Reye.RPupil:setUVPixels(0.6,0)


modelUtils.apply(statue, function (modelPart)
	modelPart:setParentType("None"):setRot(0,0,0):setPos(0,0,0)
end)

statue:scale(math.playerScale)
return statue