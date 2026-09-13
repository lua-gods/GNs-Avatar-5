local OPACITY_FROM = 0.05
local OPACITY_TO = 0.5
local FADE_DURATION = 20

local fade = 0

local lastBlock
local color

events.TICK:register(function ()
	local block = player:getTargetedBlock(true,5)
	if (not lastBlock) or (lastBlock:getPos() ~= block:getPos()) then
		color = block:getMapColor()
		fade = FADE_DURATION
		lastBlock = block
	end
	local t = math.clamp(fade/FADE_DURATION,0,1)
	renderer
	:setBlockOutlineColor((1-color):augmented(math.lerp(OPACITY_FROM,OPACITY_TO,t)))
	if fade > 0 then
		fade = fade - 1
	end
end)