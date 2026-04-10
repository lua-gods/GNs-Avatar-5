local Macro = require("lib.macros")
local Tween = require("lib.tween")

local function blink(invert,speed)
	Tween.new{
		from=invert and 1 or 0,
		to=invert and 0 or 1,
		duration=0.25/speed,
		tick=function (v,t)
			models:setColor(1,v,v)
		end,
		id="blockway"
	}
end


local macro = Macro.new(function (events, speed)
	local sound = sounds["sounds.blockway"]:loop(true):pitch(speed):play()
	
	local timer = 0
	local invert = false
	events.TICK:register(function ()
		sound:pos(player:getPos())
		timer = timer + speed
		if timer > 3.95*20 then
			timer = 0
			invert = not invert
			
			local v = invert and 0 or 1
			models:setColor(1,v,v)
		end
		if timer == 3.5*20 then blink(invert,speed) end
		if timer == 3*20 then blink(invert,speed) end
		if timer == 2.5*20 then blink(invert,speed) end
	end)
	
	events.ON_EXIT:register(function ()
		sound:stop()
		models:setColor()
	end)
end)



local isBlockway = false

function blockway(speed)
	speed = speed or 1
	pings.blockway(speed)
end

function pings.blockway(speed)
	isBlockway = speed
	macro:setActive(false)
	macro:setActive(speed ~= 0,speed)
end