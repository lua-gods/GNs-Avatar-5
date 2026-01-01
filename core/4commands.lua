
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


function mapArea()
	
	local SKIP = 40
	local INTERVAL = 20 * 4
	local STEP_SIZE = 16 * 12 * 2
	
	local x = 0
	local z = 0
	
	local origin = player:getPos()
	
	local rangex = vec(-1,1)
	local rangez = vec(-1,1)
	
	local axis = false
	local flipx = false
	local flipz = false
	
	local g = keybinds:newKeybind("skip","key.keyboard.g",true)
	local timer = 0
	
	events.WORLD_TICK:register(function ()
		if timer < 0 or g:isPressed() then
			timer = INTERVAL
			if axis then
				if flipz then
					z = z - 1
					if rangez.x > z then
						rangez.x = rangez.x - 1
						flipz = false
						axis = not axis
					end
				else
					z = z + 1
					if rangez.y < z then
						rangez.y = rangez.y + 1
						flipz = true
						axis = not axis
					end
				end
			else
				if flipx then
					x = x - 1
					if rangex.x > x then
						rangex.x = rangex.x - 1
						flipx = false
						axis = not axis
					end
				else
					x = x + 1
					if rangex.y < x then
						rangex.y = rangex.y + 1
						flipx = true
						axis = not axis
					end
				end
			end
			host:sendChatCommand(("/tp %s %s %s"):format(origin.x + x * STEP_SIZE, origin.y, origin.z + z * STEP_SIZE))
		else
			timer = timer - 1
		end
		step = 1
	end,"mapArea")
	function back()
		host:sendChatCommand(("/tp %s %s %s"):format(origin.x, origin.y, origin.z))
		back = nil
		events.WORLD_TICK:remove("mapArea")
	end
end
