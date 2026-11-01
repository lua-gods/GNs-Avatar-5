local OPACITY_FROM = 0.5
local OPACITY_TO = 0.05
local FADE_DURATION = 20

local fade = 0

local lastBlock
local color

local ltime = client:getSystemTime()
events.WORLD_RENDER:register(function ()
	local time = client:getSystemTime() / 1000
	local delta = (time-ltime)
	ltime = time
	local block = player:getTargetedBlock(true,5)
	if (not lastBlock) or (lastBlock:getPos() ~= block:getPos()) then
		color = vec(1,1,1)
		fade = FADE_DURATION
		lastBlock = block
	end
	local t = math.clamp(fade/FADE_DURATION,0,1)
	
	renderer:setBlockOutlineColor(color:augmented(math.lerp(OPACITY_TO,OPACITY_FROM,t)))
	if fade > 0 then
		fade = fade - delta * 20
	end
end)