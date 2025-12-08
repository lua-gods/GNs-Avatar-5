local Skull = require("lib.skull")

local ratio = 2*math.playerScale
local invRatio = 1/ratio


local identity = Skull.registerIdentity{
	name = "miki",
	id = "miki",
	modelHat = models.miki,
	
	processHat = {
		---@param skull SkullInstanceBlock
		---@param model ModelPart
		ON_READY = function (skull, model)
			model:play("models.miki.test")
			model:setPos(0,(-24-3)*invRatio,0)
			model:scale(invRatio,invRatio,invRatio)
		end,
	
		---@param skull SkullInstanceBlock
		---@param model ModelPart
		ON_PROCESS = function (skull, model,delta)
			
		end,
		
		---@param skull SkullInstanceBlock
		---@param model ModelPart
		ON_EXIT = function (skull, model)
			
		end},
}

