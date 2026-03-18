---@diagnostic disable: param-type-mismatch
local Skull = require("lib.skull")
local Color = require("lib.color")


---@type SkullIdentity|{}
local identity = {
	name = "print",
	id = {"print"},
	modelBlock = models.skull.plushie.block,
	modelHat = models.skull.plushie.hat,
	modelHud = Skull.toIcon(models.skull.plushie.icon),
	modelEntity = models.skull.plushie.entity,
}

local ogPrint = _G.print
local MAX_LOGS = 50
local SACLE = 0.25


identity.processBlock = {
	ON_INIT = function (skull, model)
		skull.t = 0
		skull.label = model:newText("Logs")
		:setBackgroundColor(0,0,0,0.5)
		:scale(SACLE)
		local logs = {}
		_G.print = function (...)
			if skull.t == 0 then
				table.insert(logs, table.concat({...}, " "))
				skull.label:setText(table.concat(logs, "\n"))
				if #logs > MAX_LOGS then
					table.remove(logs, 1)
				else
					skull.label:setPos(-8,(#logs-1)*10*SACLE+2,0)
				end
			else
				logs = {}
				skull.t = 0
			end
		end
	end,
	ON_PROCESS = function (skull, model, deltaFrame, deltaTick)
		skull.t = skull.t + 1
	end,
	ON_EXIT = function (skull, model)
		_G.print = ogPrint
	end
}



Skull.registerIdentity(identity)
