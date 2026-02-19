
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


function divisible(x)
	local out = {}
	for i = x, 1, -1 do
		local div = x / i
		if div == math.floor(div) then -- is divisible
			out[#out+1] = i
		end
	end
	print(x.." is disvisible by "..table.concat(out,", "))
end


function mapArea()
	
	local SKIP = 40
	local INTERVAL = 20 * 10
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

local PRECISION_MS = 50 -- 0.01
local FRAMES_TO_AVERAGE = 500
local MS_MARGIN = 10
local SEARCH_SPEED = 100000
local BIAS = 0.1682 -- precalculated, can be calculated by benchmarking nothing

---@param fun fun()
function benchmark(fun)
	renderer:setCameraPos(300000,0,0)
	local repeats = 10
	local timer = 0
	local searchSpeed = SEARCH_SPEED
	local lastTime,time,msTook,msTookMin,msTookMax
	
	events.WORLD_RENDER:register(function (delta)
		lastTime = client:getSystemTime()
		for i = 1, repeats, 1 do
			fun()
		end
		time = client:getSystemTime()
		msTook = (time - lastTime)
		if PRECISION_MS > msTook then
			repeats = repeats + math.floor((searchSpeed/math.max(1, msTook)))
		else
			repeats = math.floor(repeats / math.max(1, msTook-PRECISION_MS))
		end
		if msTook == 1 then searchSpeed = searchSpeed / 2 end
		host:setActionbar("optimal repeats: "..repeats.." ms: "..msTook.." fps: "..math.floor(1000/msTook))
	
		if PRECISION_MS < msTook and PRECISION_MS + MS_MARGIN > msTook then
			
			timer = 0
			print("optimal repeats: ",repeats,"for:",PRECISION_MS,"ms")
			
			events.WORLD_RENDER:remove("benchmark_stage_1")
			msTookMin = math.huge
			msTookMax = 0
			local msTrack = {}
			events.WORLD_RENDER:register(function (delta)
				lastTime = client:getSystemTime()
				for i = 1, repeats, 1 do
					fun()
				end
				time = client:getSystemTime()
				msTook = (time - lastTime)
				timer = timer + 1
				msTrack[#msTrack+1] = msTook
				msTookMin = math.min(msTook,msTookMin)
				msTookMax = math.max(msTook,msTookMax)
				host:setActionbar("ms: "..msTook.." fps: "..math.floor(1000/msTook))
				
				if timer > FRAMES_TO_AVERAGE then
					local msAvg = 0
					for index, record in ipairs(msTrack) do
						msAvg = msAvg + record
					end
					msAvg = msAvg / #msTrack
					print("μsMin",msTookMin/repeats/.001-BIAS,"μsMax",msTookMax/repeats/.001-BIAS,"μsAvg",(msAvg/repeats/.001)-BIAS)
					events.WORLD_RENDER:remove("benchmark_stage_2")
					renderer:setCameraPos()
				end
			end,"benchmark_stage_2")
		end
	end,"benchmark_stage_1")
end

function checkPing()
	if player:isLoaded() then
		local time = client:getSystemTime()
		local hash = math.random(100000000,1000000000)
		host:sendChatCommand("msg GNUI PING"..hash)
		events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
			if message == player:getName().." whispers to you: PING"..hash then
				local newTime = client:getSystemTime()
				print("ping: ",(newTime-time).."ms")
				host:setChatMessage(1,nil)
				events.CHAT_RECEIVE_MESSAGE:remove("pingCheck")
				return false
			end
		end,"pingCheck")
	else
		warn("Player isnt loaded, try again")
	end
end


function giveItem(item,count)
	count = count or 1
	local newItem = world.newItem(item,count)
	local itemString = newItem:toStackString()
	for i = 0, 35, 1 do -- all player slots
		local slotItem = host:getSlot(i)
		if slotItem:toStackString() == itemString
		or slotItem.id == "minecraft:air" then
			local currentCount = slotItem:getCount()
			local amountToAdd = math.min(count,slotItem:getMaxCount() - slotItem:getCount())
			host:setSlot(i, world.newItem(item, currentCount + amountToAdd))
			count = count - amountToAdd
		end
		if count <= 0 then
			sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,2)
			return
		end
	end
	warn("Unable to give item, inventory full")
end


function queryItems(query)
	local items = {}
	if query:sub(1,1) == "#" then -- tags query
		for i, name in ipairs(client.getRegistry("minecraft:item")) do
			for index, tag in ipairs(world.newItem(name):getTags()) do
				if tag:find(query:sub(2,-1)) then
					items[#items+1] = name
					break
				end
			end
		end
	end
	for i, name in ipairs(client.getRegistry("minecraft:item")) do
		if name:find(query) then
			items[#items+1] = name
		end
	end
	
	local pack = ""
	for _, name in ipairs(items) do
		pack = pack .. '{Count:1b,id:"'..name..'"},'
	end
	local bundle = ([[bundle{display:{Name:'[{"text":"","italic":false},{"translate":"item.minecraft.bundle"},{"text":%s}]'},Items:[%s]}]])
	:format(toJson(" of "..query),pack)
	host:setClipboard(bundle)
	giveItem(bundle,1)
end