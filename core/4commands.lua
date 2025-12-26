
---@param model ModelPart
---@param indent integer
local function _showModelTree(model,indent)
	if model:getType() == "GROUP" then
		print((" "):rep(indent) .. model:getName())
		for _, v in ipairs(model:getChildren()) do
			_showModelTree(v,indent + 1)
		end
	end
end

function showModelTree(model)
	model = model or models
	_showModelTree(model,0)
end


local F = vec(1998584, 36, 1999125)
local T = vec(1998587, 36, -1999128)

function flip()
	local p = player:getPos()
	local f = p.z > 0
	host:sendChatCommand(string.format("/tp @s %s %s %s %s ~",
		f and math.map(p.x, F.x, F.x+1, T.x, T.x-1) or math.map(p.x, T.x, T.x+1, F.x, F.x-1) ,p.y,
		f and math.map(p.z, F.z, F.z+1, T.z, T.z+1) or math.map(p.z, T.z, T.z+1, F.z, F.z+1),
		(-user:getRot().y)
	))
end

