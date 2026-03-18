--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Nameplate Generator
/ /_/ / /|  /  desc: not a library
\____/_/ |_/ source: link ]]


local NAME = "GNanimates"


local NameplateAPI = {}
local CLR_FROM = vectors.hexToRGB("#d3fc7e")
local CLR_TO = vectors.hexToRGB("#33984b")

local CLR_STATUS = vectors.hexToRGB("#aaaaaa")
local CLR_STATUS_UPDATE = vectors.hexToRGB("#d3fc7e")


--────────────────────────-< Nameplate Name >-────────────────────────--

local nameComponent = {
	{text="${badges}:@gn:"},
	{text=":back::@gn_band:",color="#"..vectors.rgbToHex(CLR_FROM)},
}

local nameLength = #NAME
for i = 1, nameLength, 1 do
	local w = i/nameLength
	nameComponent[#nameComponent+1] = {
		color="#"..vectors.rgbToHex(math.lerp(CLR_FROM,CLR_TO,w)),
		text=NAME:sub(i,i),
	}
end

---@cast nameComponent string
nameComponent = toJson(nameComponent)

--────────────────────────-< Nameplate Status >-────────────────────────--

local status
local statusTime

local function updateStatus()
	local final = '['
	final=final .. '{"text":"","extra":['..nameComponent..']}'
	
	if status then
		final=final .. ',{"text":"\n"}'
		final=final .. ',{"text":"['..status..'","color":"gray"}'
		
		if statusTime then
			final=final .. ',{"text":" : ","color":"gray"}'
			
			local time = client:getSystemTime()
			local timeSince = math.floor((time - statusTime) / 1000)
			
			local second = timeSince%60
			local minute = math.floor(timeSince/60)
			local hour = math.floor(minute/60)
			minute = minute%60
			
			if hour > 0 then
				final=final .. ',{"text":"'..hour..'","color":"gray"}'
				final=final .. ',{"text":":","color":"gray"}'
			end
			
			final=final .. ',{"text":"'..minute..'","color":"gray"}'
			
			final=final .. ',{"text":":","color":"gray"}'
			
			final=final .. ',{"text":"'..(string.format("%02d", second))..'","color":"gray"}'
		end
		final=final .. ',{"text":"]","color":"gray"}'
	end
	
	final=final .. ']'
	nameplate.ALL:setText(final)
	nameplate.CHAT:setText(nameComponent)
end

--────────────────────────-< Update Status >-────────────────────────--

function NameplateAPI.setStatus(title,time)
	status = title
	statusTime = time
	events.WORLD_RENDER:remove("nameplateStatus")
	if status then
		local time = client:getSystemTime()
		events.WORLD_RENDER:register(function ()
			local currentTime = client:getSystemTime()
			if currentTime-time > 1000  then
				time = currentTime
				updateStatus()
			end
		end,"nameplateStatus")
	end
	updateStatus()
end



--────────────────────────-< Bootstrap >-────────────────────────--

nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)
updateStatus()

return NameplateAPI