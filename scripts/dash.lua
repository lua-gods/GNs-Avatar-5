#host

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

local colors = {
   vectors.hexToRGB("#d3fc7e"),
   vectors.hexToRGB("#99e65f"),
   vectors.hexToRGB("#5ac54f"),
   vectors.hexToRGB("#33984b"),
   vectors.hexToRGB("#1e6f50"),
   vectors.hexToRGB("#134c4c"),
   vectors.hexToRGB("#0c2e44"),
}
function pings.DASH(x,y,z)
   if player:isLoaded() then
      local pos = player:getPos():add(0,1,0)
      sounds["minecraft:entity.illusioner.mirror_move"]:setSubtitle("Player Dashes"):pitch(0.9):pos(pos):play()
      particles:newParticle("minecraft:flash",pos):setColor(0.5,1,0.4)
      local dir = vec(x,y,z)
      for i = 1, 200, 1 do
         local v = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*math.random()*0.2 + (dir) * math.random()
         particles:newParticle("minecraft:end_rod",pos):setVelocity(v):color(colors[math.random(1,#colors)])
      end
      if host:isHost() then
         silly:setVelocity(dir)
      end
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
		pings.DASH((player:getLookDir() * STRENGTH * timer):unpack())
	end
end)