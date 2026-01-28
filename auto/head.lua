
local BLINK_RANGE = vec(0.5,5) * 20
local ANIM_X = animations.player.eyeHorizontal
local ANIM_Y = animations.player.eyeVertical
local ANIM_BLINK = animations.player.eyeBlink
ANIM_BLINK:setBlendDuration(0)

local MODEL_HEAD = models.player.Base.Torso.Waist.Chest.Head
MODEL_HEAD:setParentType("None")

ANIM_X:speed(0):play()
ANIM_Y:speed(0):play()
local blinkTime = 0

events.TICK:register(function ()
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x,BLINK_RANGE.y)
		ANIM_BLINK:stop():play()
	end
end)

local hasRender = false
if host:isHost() then
	events.WORLD_RENDER:register(function (delta)
		hasRender = false
	end)
end

events.RENDER:register(function (delta, ctx)
	MODEL_HEAD:setPos(0,player:isCrouching() and -4 or 0)
	if ctx == "RENDER" then
		hasRender = true
	end
	if ctx == "PAPERDOLL" then delta = client:getFrameTime() end
	-- avoid recalculating in the shadow pass
	if ctx == "OTHER" or ctx == "FIRST_PERSON" then return end 
	if hasRender and ctx == "PAPERDOLL" then return end
	local rot 
	rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
	rot.y = ((rot.y + 180) % 360 - 180) / -50
	rot.x = rot.x / -90
	---@cast rot Vector2
	ANIM_X:setTime(rot.y*0.5+0.5)
	ANIM_Y:setTime(rot.x*0.5+0.5)
end)


