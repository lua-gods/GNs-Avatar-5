local BLINK_RANGE = vec(1, 5) * 20
local HEAD_ANIM_X = animations.player.headHorizontal
local HEAD_ANIM_Y = animations.player.headVertical

local MOVE_RANGE = vec(0.4, 2) * 20
local VARIANCE = 0.02
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

local lastTargetRot = vec(0, 0)
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
	
	lastTargetRot = targetRot
	targetRot = player:getRot() - vec(0, player:getVehicle() and player:getVehicle():getRot().y or player:getBodyYaw())
	targetRot.y = ((targetRot.y + 180) % 360 - 180) / -50
	targetRot.x = targetRot.x / -90
end)

animations.player.breathing:speed(0.3):play()

events.RENDER:register(function(delta, ctx)
	MODEL_HEAD:setPos(0, player:isCrouching() and -4 or 0)
	local rot = math.lerp(lastTargetRot, targetRot, delta)
	
	HEAD_ANIM_X:setTime(rot.y * 0.5 + 1)
	HEAD_ANIM_Y:setTime(rot.x * 0.5 + 1)
end)
