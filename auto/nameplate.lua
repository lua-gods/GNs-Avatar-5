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

local function component(text,color)
	return ',{"text":"'..tostring(text)..'","color":"'..(color and "#"..vectors.rgbToHex(color) or "gray")..'"}'
end

local status
local statusTime

local function updateStatus()
	local final = '['
	final=final .. '{"text":"","extra":['..nameComponent..']}'
	
	if status then
		final=final .. ',{"text":"\n"}'
		final=final .. component("[")
		
		if statusTime then
			
			
			local time = client:getSystemTime()
			local timeSince = ((time - statusTime) / 1000)
			
			local second = timeSince%60
			local minute = math.floor(timeSince/60)
			local hour = math.floor(minute/60)
			minute = minute%60
			
			final=final .. component(status.." ")
			
			if hour > 0 then
				final=final .. component(hour)
				final=final .. component(":")
			end
			final=final .. component(minute,math.lerp(CLR_STATUS_UPDATE,CLR_STATUS,math.clamp(second,0,1)))
			
			final=final .. component(":")
			
			final=final .. component((string.format("%02d", second)),math.lerp(CLR_STATUS_UPDATE,CLR_STATUS,(timeSince)%1))
		end
		final=final .. component("]")
	else
		
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
			end
			updateStatus()
		end,"nameplateStatus")
	end
	updateStatus()
end



--────────────────────────-< Bootstrap >-────────────────────────--

nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)
updateStatus()

return NameplateAPI