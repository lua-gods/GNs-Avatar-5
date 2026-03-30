local Sequence = require("lib.sequencer")



---@param x number
---@param y number
---@param z number
function tpSilly(x,y,z)
	local pos = player:getPos()
	Sequence.new()
	:add(0,function () silly:setPos(pos.x,1000,pos.z) end)
	:add(10,function () silly:setPos(x,1000,z) end)
	:add(20,function () silly:setPos(x,y,z) end)
	:start(events.TICK)
end

function tpSillyCam()
	tpSilly(client:getCameraPos():unpack())
end

function tpSillyTargetBlock()
	local block,hit = raycast:block(
		client:getCameraPos(),
		client:getCameraPos()+client:getCameraDir()*100
	)
	if block.id ~= "minecraft:air" then
		tpSilly(hit.x,hit.y,hit.z)
	end
end