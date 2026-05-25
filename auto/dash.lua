# flags: host_only

local Sequencer = require('lib.sequencer')

local STRENGTH = 8

local dash = keybinds:newKeybind("dash","key.mouse.5")

local timer = 0

---@type Sound[]
local playingSounds = {}

---@param id Minecraft.soundID
---@param pitch number?
---@param volume number?
local function sound(id,pitch,volume)
	if player:isLoaded() then
		playingSounds[#playingSounds+1] = sounds:playSound(id,player:getPos(),volume or 1,pitch or 1)
	end
end

events.TICK:register(function ()
	local pos = player:getPos()
	for index, sound in ipairs(playingSounds) do
		if not sound:isPlaying() then
			table.remove(playingSounds,index)
		else
			sound:setPos(pos)
		end
	end
end)

dash:onPress(function (modifiers, self)
	timer = 0
	events.TICK:register(function ()
		timer = timer + 0.1
		renderer:setFOV(1/(1+timer))
	end,"dashCharge")
end):onRelease(function (modifiers, self)
	events.TICK:remove("dashCharge")
	if player:isLoaded() then
		renderer:setFOV()
		--sound("minecraft:entity.evoker.prepare_attack",1)
		--sound("minecraft:entity.illusioner.prepare_mirror",1)
		--sound("minecraft:entity.illusioner.prepare_blindness"	,1)
		
		--sound("minecraft:entity.player.attack.nodamage",0.5)
		--sound("minecraft:entity.player.attack.nodamage",0.05)
		silly:setVelocity(player:getLookDir() * STRENGTH * timer)
	end
end)