local RANDOM_PITCH = 0.1

local SWORD_PATH = models.player.Base.Torso.Waist.Chest.CrystalSword.CSHandle.Mesh

local ANIM_IDLE = animations.player.sword
local ANIM_ATTACK = animations.player.swordAttack1:setBlendDuration(0.1)
local ANIM_ATTACK_TWO = animations.player.swordAttack2:setBlendDuration(0.1)

SWORD_PATH:setPrimaryRenderType("EMISSIVE_SOLID")

models.player.VFX:setVisible(true)
models.player.VFX.Smear1.Smear1Spin:setPrimaryRenderType("EYES"):setColor(0.8,0.8,0.8)

local alternate = false

local current
local function setAnimation(anim)
	if current ~= anim then
		if current then current:stop() end
		current = anim:play()
	end
end

setAnimation(ANIM_IDLE)

events.TICK:register(function ()
	local heldItem = player:getHeldItem()
	local isHoldingSword = heldItem.id:find("_sword$")
	if isHoldingSword and player:getSwingArm() and player:getSwingTime() == 0 then
		setAnimation(alternate and ANIM_ATTACK_TWO or ANIM_ATTACK)
		alternate = not alternate
		sounds["sounds.swing"]:pitch(math.lerp(1-RANDOM_PITCH,1+RANDOM_PITCH,math.random())):pos(player:getPos()):play()
	end
	models.player.Roll:setPos(0,0,player:isCrouching() and 5 or 0)
end)