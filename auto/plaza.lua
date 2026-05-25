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
	x,z = math.floor(x)+0.5, math.floor(z)+0.5
	local pos = player:getPos()
	silly:setPos(pos.x, 1000, pos.z,true)
	silly:setPos(x, 1000, z,true)
	silly:setPos(x, y+0.2, z,true)
	silly:setPos(x, y+0.2, z)
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
