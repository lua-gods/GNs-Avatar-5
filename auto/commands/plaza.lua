# flags: host_only

local Sequence = require("lib.sequencer")


events.ENTITY_INIT:register(function()
	if player:getPermissionLevel() <= 1 then
		events.CHAT_SEND_MESSAGE:register(function(message)
			if message and message:find("^/tp ") then
				local x, y, z = message:match("^/tp ([%d-%.]+) ([%d-%.]+) ([%d-%.]+)")
				host:appendChatHistory(message)
				tpSilly(x, y + 1, z)
				return
			end
			return message
		end)
	end
end)



---@param x number
---@param y number
---@param z number
function tpSilly(x, y, z)
	local pos = player:getPos()
	Sequence.new()
		 :add(0, function()
			 silly:setPos(pos.x, 1000, pos.z)
			 silly:setVelocity(0, 0, 0)
		 end)
		 :add(2, function()
			 silly:setPos(x, 1000, z)
			 silly:setVelocity(0, 0, 0)
		 end)
		 :add(4, function()
			 silly:setPos(x, y, z)
			 silly:setVelocity(0, 0, 0)
		 end)
		 :add(6, function()
			if player:getPos().y > 900 then
				silly:setPos(x, y+1, z)
				silly:setVelocity(0, 0, 0)
			end
		 end)
		 :start(events.TICK)
end

function tpSillyCam()
	tpSilly(client:getCameraPos():unpack())
end

function tpSillyTargetBlock()
	local block, hit = raycast:block(
		client:getCameraPos(),
		client:getCameraPos() + client:getCameraDir() * 100
	)
	if block.id ~= "minecraft:air" then
		tpSilly(hit.x, hit.y, hit.z)
	end
end
