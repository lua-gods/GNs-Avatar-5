
-- dumps analyticsl data about which scripts use the most nanoseconds
-- data gets dumped into `mermaid.md`, view with mermaid markdown extension
-- requires figura silly plugin to work
local DUMP_ANALYTICS = false


local scripts = listFiles("scripts")
local model = models:newPart("loader", "WORLD")

local function dumpAnalytics(analytics)
	local fileAccess = file:openWriteStream("mermaid.md")
	local buffer = data:createBuffer()

	buffer:writeString("```mermaid\n")
	buffer:writeString("pie title Performance\n")

	for index, value in ipairs(analytics) do
		buffer:writeString(('"%s" : %s\n'):format(value.path, value.time))
	end
	buffer:writeString("```\n")
	model:remove()
	buffer:setPosition(0)
	buffer:writeToStream(fileAccess)
	fileAccess:close()
end


local analytics = {}

local i = 1
model.postRender = function(delta, context, part)
	local path = scripts[i]
	if not path then
		if DUMP_ANALYTICS then
			table.sort(analytics,function (a, b) return a.time > b.time end)
			dumpAnalytics(analytics)
		end
		return
	end
	local benchmarkTime = silly:getNanoTime()
	local benchmark = avatar:getCurrentInstructions()
	require(path)
	local instructions = avatar:getCurrentInstructions() - benchmark
	local time = (silly:getNanoTime() - benchmarkTime)

	if DUMP_ANALYTICS then
		analytics[#analytics + 1] = { path = path, time = time, instructions = instructions }
	end
	i = i + 1
end

