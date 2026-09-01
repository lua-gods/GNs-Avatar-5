local Spring = require("lib.GNSpring")
local Parts = require("auto.parts")

local BLINK_RANGE = vec(1, 5) * 20
local ANIM_BLINK = animations.player.eyeBlink
ANIM_BLINK:setBlendDuration(0)

local MODEL_HEAD = models.player.Base.Torso.Waist.Chest.Head
MODEL_HEAD:setParentType("None")


local EYES_ANIM_X = animations.player.eyeHorizontal
local EYES_ANIM_Y = animations.player.eyeVertical
EYES_ANIM_X:pause()
EYES_ANIM_Y:pause()


local springHead = Spring.newVec2(1.5,vec(0.4,0.2),1.2)
local springBody = Spring.newVec2(0.8,vec(0.25,0.3),0)




local blinkTime = 0
local targetRot = vec(0, 0)

events.TICK:register(function()
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x, BLINK_RANGE.y)
		ANIM_BLINK:stop():play()
	end
	
	EYES_ANIM_X:setTime(((targetRot.y-springHead.pos.y) / 45) * 1 + 1)
	EYES_ANIM_Y:setTime((targetRot.x / 90) * 0.5 + 1)
	
	targetRot = player:getRot() - vec(0, player:getVehicle() and player:getVehicle():getRot().y or player:getBodyYaw())
	targetRot.y = ((-targetRot.y + 180) % 360 - 180)
	targetRot.x = -targetRot.x
	
	springHead.target = targetRot * vec(0.8, 0.5)
	springBody.target = targetRot * vec(0.2, 0.5)
end)

animations.player.breathing:speed(0.3):play()

events.RENDER:register(function(delta, ctx)
	if ctx ~= "PAPERDOLL" then
		MODEL_HEAD:setPos(0, player:isCrouching() and -4 or 0)
		
		local headRot = springHead.pos
		Parts.HEAD:setRot(springHead.pos:unpack())
		Parts.TORSO:setRot(springBody.pos:unpack())
	end
end)
