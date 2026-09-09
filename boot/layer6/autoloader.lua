local scripts = listFiles("scripts")
local display = require("libhost.debug.debugLog")


local model = models:newPart("loader","WORLD")

local i = 1
model.postRender = function (delta, context, part)
	local path = scripts[i]
	if not path then
		model:remove()
		return
	end
	local benchmarkTime = silly:getNanoTime()
	local benchmark = avatar:getCurrentInstructions()
	require(path)
	local ticks = avatar:getCurrentInstructions()-benchmark
	local time = (silly:getNanoTime()-benchmarkTime)
	display.print(path,ticks,time.."ms")
	i = i + 1
end