local Spring = require("lib.spring")

local BLINK_RANGE = vec(0.5, 3) * 20
local HEAD_ANIM_X = animations.player.headHorizontal
local HEAD_ANIM_Y = animations.player.headVertical

local MOVE_RANGE = vec(0.2, 0.8) * 20
local VARIANCE = 0.03
local EYES_ANIM_X = animations.player.eyeHorizontal
local EYES_ANIM_Y = animations.player.eyeVertical

local ANIM_BLINK = animations.player.eyeBlink
ANIM_BLINK:setBlendDuration(0)

local MODEL_HEAD = models.player.Base.Torso.Waist.Chest.Head
MODEL_HEAD:setParentType("None")

HEAD_ANIM_X:pause()
HEAD_ANIM_Y:pause()

EYES_ANIM_X:pause()
EYES_ANIM_Y:pause()

local blinkTime = 0
local eyeMoveTime = 0

local headSpring = Spring.newVec2(2, vec(0.35, 0.4), 0.2)
local targetRot = vec(0, 0)

events.TICK:register(function()
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x, BLINK_RANGE.y)
		ANIM_BLINK:stop():play()
		eyeMoveTime = -69
	end
	eyeMoveTime = eyeMoveTime - 1
	if eyeMoveTime <= 0 then
		eyeMoveTime = math.lerp(MOVE_RANGE.x, MOVE_RANGE.y, math.random())
		EYES_ANIM_X:setTime(targetRot.y * 0.25 + 1 + (math.random() - 0.5) * 2 * VARIANCE)
		EYES_ANIM_Y:setTime(targetRot.x * 0.5 + 1)
	end
	
	if math.abs(headSpring.pos.x) > 4 or math.abs(headSpring.pos.y) > 4 then
		headSpring.pos = headSpring.target
	end
end)


events.RENDER:register(function(delta, ctx)
	MODEL_HEAD:setPos(0, player:isCrouching() and -4 or 0)
	targetRot = player:getRot(delta) - vec(0, player:getBodyYaw(delta))
	targetRot.y = ((targetRot.y + 180) % 360 - 180) / -50
	targetRot.x = targetRot.x / -90
	---@cast targetRot Vector2

	headSpring.target = targetRot

	HEAD_ANIM_X:setTime(headSpring.pos.y * 0.5 + 1)
	HEAD_ANIM_Y:setTime(headSpring.pos.x * 0.5 + 1)
end)
