--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN Sync Service Library
/ /_/ / /|  /  desc: automatically syncs data
\____/_/ |_/ source: link ]]

local Event = require("lib.event")


--TODO: add support for chunked package sending for super long string pings.

--────────────────────────-< CONFIG >-────────────────────────--

-- the maximum ping size you have per second, default value is maximum possible
local MAX_SIZE_LIMIT = 1024 - 100

-- the maximum amount of pings per second, default value is maximum possible
local MAX_COUNT_LIMIT = 10

-- the timer to slow the syncer down
-- setting this to 0 means it attempts to sync data per frame
local PASSIVE_TIMER_INTERVAL = 0 -- 0 for fast asf

-- the maximum amount of items a batch can have
local MAX_ITEMS_PER_BATCH = 10

-- function that compresses data into a string from a table
local PACKER = toJson

-- function that decompresses data from a string to a table
local UNPACKER = parseJson

-- function that tells how many bytes a string has as a ping.
local PING_SIZE_CHECKER = function (string)
	return #string
end

--────────-< Debug Options >-────────--

-- shows the data that is being synced beside the player
local DEBUG_SHOW_DATA = false

--────────────────────────-< END OF CONFIG >-────────────────────────--

local realData = {}
local syncData = {} -- actual data
local syncListeners = {} ---@type table<string,Event>
local name2listener = {} ---@type table<string,string>

local syncInterface = {} --- proxy table
_G.SYNC = syncInterface


function pings.syncPayload(package)
	local payload = UNPACKER(package)
	for key, value in pairs(payload) do
		if syncData[key] ~= value then
			syncData[key] = value
			local listenerName = name2listener[key]
			if listenerName then
				syncListeners[listenerName]:invoke(value)
			end
		end
	end
end

if DEBUG_SHOW_DATA then
	local SCALE = 0.25
	
	local label = models:newPart("panel")
	:newText("")
	
	:scale(SCALE,SCALE,SCALE)
	:setBackground(true)
	
	events.WORLD_RENDER:register(function (delta)
		local text = printTable(syncData,9,true)
		
		local lineCount = 1
		text:gsub("\n",function ()
			lineCount = lineCount + 1
			return "\n"
		end)
		
		label
		:setText(text)
		:setPos(-10,lineCount*10*SCALE,0)
	end)
	
end

if not host:isHost() then return end


setmetatable(syncInterface,{
	__index = function(t,k)
		k = tostring(k)
		return realData[k] or syncListeners[k]
	end,
	__newindex = function(t,k,v)
		k = tostring(k)
		realData[k] = v
		local listenerName = k:upper().."_CHANGED"
		syncListeners[listenerName] = Event.new()
		name2listener[k] = listenerName
	end
})


local availableSize = MAX_SIZE_LIMIT
local availableCount = MAX_COUNT_LIMIT


local payload = {}
local function sendPayload()
	availableSize = availableSize - #payload
	availableCount = availableCount - 1
	local package = PACKER(payload)
	payload = {}
	pings.syncPayload(package)
end

local passiveTimer = 0

local index
local lastTime = client:getSystemTime()
events.WORLD_RENDER:register(function ()
	local time = client:getSystemTime()
	local delta = (time - lastTime) / 1000
	
	availableSize = math.min(availableSize + delta * MAX_SIZE_LIMIT, MAX_SIZE_LIMIT)
	availableCount = math.min(availableCount + delta * MAX_COUNT_LIMIT, MAX_COUNT_LIMIT)
	lastTime = time

	passiveTimer = passiveTimer - delta
	if passiveTimer > 0 then return end
	passiveTimer = PASSIVE_TIMER_INTERVAL
	
	for i = 1, MAX_ITEMS_PER_BATCH, 1 do
		if availableCount > 1 then
			index = next(realData,index)
			if index then
				local value = realData[index]
				payload[index] = value
				local package = toJson(payload)
				if PING_SIZE_CHECKER(package) > availableSize then
					payload[index] = nil -- temporarily remove it as it is too big
					sendPayload()
					payload[index] = value
					break
				end
			else -- reached the end
				sendPayload()
				break
			end
		else
			break
		end
	end
end)

--────────────────────────-< Test Sandbox >-────────────────────────--