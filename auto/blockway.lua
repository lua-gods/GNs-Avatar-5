local Macro = require("lib.macros")
local Tween = require("lib.tween")

local function blink(invert)
	Tween.new{
		from=invert and 1 or 0,
		to=invert and 0 or 1,
		duration=0.25,
		tick=function (v,t)
			models:setColor(1-v,0,v)
		end,
		id="blockway"
	}
end


local macro = Macro.new(function (events, ...)
	models:setColor(0,0,1)
	local sound = sounds["sounds.blockway"]:loop(true):play()
	
	local timer = 0
	local invert = false
	events.TICK:register(function ()
		sound:pos(player:getPos())
		timer = timer + 1
		if timer > 3.95*20 then
			timer = 0
			invert = not invert
			
			local v = invert and 0 or 1
			models:setColor(1-v,0,v)
		end
		if timer == 3.5*20 then blink(invert) end
		if timer == 3*20 then blink(invert) end
		if timer == 2.5*20 then blink(invert) end
	end)
	
	events.ON_EXIT:register(function ()
		sound:stop()
		models:setColor()
	end)
end)



local isBlockway = false

function blockway()
	pings.blockway(not isBlockway)
end

function pings.blockway(is)
	isBlockway = is
	macro:setActive(is)
end