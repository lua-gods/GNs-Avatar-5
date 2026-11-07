if true then return end

local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()

local SIZE = 300

local container = screen:parse({
	type = "container",
	pos = vec(10, 10),
	size = vec(SIZE, SIZE),
	sizing = { "FIXED", "FIXED" },
	layout = "FIXED",
	style = "opaque",
	clipChildren = true,
})

local a = 10
local clr
local function randomColor()
	clr = vec(math.random(),math.random(),math.random())
end

randomColor()
local nextContainer
for c = 1, a, 1 do
	local s = SIZE * 0.75
	for i = 0, 2, 1 do
		for y = 0, 2, 1 do
			if i == 1 and y == 1 then
				nextContainer = container:parse({
					type = "container",
					pos = vec(s, s),
					size = vec(s, s),
					sizing = { "FIXED", "FIXED" },
					layout = "FIXED",
					style = "opaque",
					clipChildren = true,
				})
			else
				container:parse({
					type = "button",
					color = clr,
					pos = vec(i, y) * s,
					size = vec(s, s),
				})
			end
		end
	end
	randomColor()
	container = nextContainer
	SIZE = SIZE - 50
end
