---@type Vector3?
local handle
local handleDist = 1
local keybind = keybinds:fromVanilla("key.use")

keybind.release = function()
   handle = nil
end

function events.mouse_scroll(dir)
   if not player:isLoaded() then return end
   if not handle then return end
   handleDist = math.clamp(handleDist + dir * -0.5, 1, host:getReachDistance())
   return true
end

function events.tick()
   if not handle then
		if keybind:isPressed() then
			local block, hitPos = player:getTargetedBlock(true)
				local blockPos = block:getPos()
				local eyePos = player:getPos():add(0, player:getEyeHeight(), 0)
				local dist = (eyePos - hitPos):length()
				if block.id == "minecraft:chain" and dist <= host:getReachDistance() then
				   handle = blockPos + 0.5
				   handleDist = 2
				end
		end
      return
   end
   local eyePos = player:getPos():add(0, player:getEyeHeight(), 0)
   local vel = vec(table.unpack(player:getNbt().Motion))
   local target = player:getLookDir() * -handleDist + handle
   local offset = target - eyePos
   vel = vel * 0.1 + offset * 0.3
   silly:setVelocity(vel)
end