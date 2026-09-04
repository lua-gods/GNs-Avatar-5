--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Nameplate Generator
/ /_/ / /|  /  desc: not a library
\____/_/ |_/ source: link ]]


local NAME = "GNᴀɴɪᴍᴀᴛᴇѕ"

local MOTD = ":flag_ph: he/him"

local USE_HEX = false


local NameplateAPI = {}
local CLR_FROM = vectors.hexToRGB("#d3fc7e")
local CLR_TO = vectors.hexToRGB("#33984b")

local CLR_STATUS = vectors.hexToRGB("#AAAAAA")
local CLR_STATUS_UPDATE = vectors.hexToRGB("#d3fc7e")
--────────────────────────-< Nameplate Name >-────────────────────────--

local nameComponent = {
	{ text = "${badges}:@gn:" },
--	{ text = ":back::@gn_band:", color = "#" .. vectors.rgbToHex(CLR_FROM) },
}

local characters = {}
for character in string.gmatch(NAME, "([%z\1-\127\194-\244][\128-\191]*)") do
	characters[#characters + 1] = character
end

local nameLength = #characters

for i=1,#characters do
	local w = i / nameLength
	nameComponent[#nameComponent + 1] = {
		color = "#" .. vectors.rgbToHex(math.lerp(CLR_FROM, CLR_TO, w)),
		text = characters[i],
	}
end
---@cast nameComponent string
nameComponent = toJson(nameComponent)

--────────────────────────-< Nameplate Status >-────────────────────────--

local motdComponent = toJson{
	text=MOTD.." ",
	color="gray"
}

local function toHex(k)
	local i = k
	local buffer = data:createBuffer()
	buffer:writeDouble(i)
	buffer:setPosition(0)
	local str = buffer:readByteArray()
	buffer:close()
	local hex = str:gsub(".", function(s)
		return string.format("%02x", s:byte())
	end)
	return hex
end

local function component(text, color)
	return ',{"text":"' ..
		 tostring(text) ..
		 '","color":"' .. ("#" .. vectors.rgbToHex(color or CLR_STATUS)) .. '"}'
end

local function flicker(number)
	return component(string.format("%02d",math.floor(number)),
		math.lerp(CLR_STATUS_UPDATE, CLR_STATUS, math.clamp(number % 1, 0, 1)))
end

local status
local statusTime
local isHovering = false

local function updateStatus()
	local final = "["
	if isHovering then
		final = final .. '{"text":"","extra":[' .. motdComponent .. "]},"
	end

	final = final .. '{"text":""}'
	
	if status then
		final = final .. component("[")

		if USE_HEX then
			if statusTime then
				local time      = client:getSystemTime()
				local timeSince = ((time - statusTime) / 1000)
				final           = final .. component(status .. " " .. toHex((timeSince)):upper())
				final           = final .. component("]")
			end
		else
			if statusTime then
				local time       = client:getSystemTime()
				local timeSince  = ((time - statusTime) / 1000)

				local second     = timeSince % 60
				local minute     = timeSince / 60
				local hour       = minute / 60
				local day        = hour / 24
				local week       = day / 7
				local month      = week / 4
				local year       = month / 12
				local century    = year / 100
				local millennium = century / 10
				minute           = minute % 60

				final            = final .. component(status .. " ")

				if millennium > 1 then
					final = final .. flicker(millennium)
					final = final .. component(":")
				end

				if century > 1 then
					final = final .. flicker(century % 10)
					final = final .. component(":")
				end

				if year > 1 then
					final = final .. flicker(year % 100)
					final = final .. component(":")
				end

				if month > 1 then
					final = final .. flicker(month % 12)
					final = final .. component(":")
				end

				if week > 1 then
					final = final .. flicker(week % 4)
					final = final .. component(":")
				end

				if day > 1 then
					final = final .. flicker(day % 7)
					final = final .. component(":")
				end

				if hour > 1 then
					final = final .. flicker(hour % 24)
					final = final .. component(":")
				end
				final = final .. flicker(minute)

				final = final .. component(":")
				final = final .. flicker(second)
			end
			final = final .. component("]")
			
		end
	end
	final = final .. component("\n")
	
	final = final .. ',{"text":"","extra":[' .. nameComponent .. "]}"

	final = final .. "]"
	nameplate.ALL:setText(final)
	nameplate.CHAT:setText(nameComponent)
end

--────────────────────────-< Update Status >-────────────────────────--

function NameplateAPI.setStatus(title, time)
	status = title
	statusTime = time
end
events.TICK:register(function()
	local time = client:getSystemTime()
	local currentTime = client:getSystemTime()
	if currentTime - time > 1000 then
		time = currentTime
	end
	isHovering = player:isLoaded() and client.getCameraEntity():getTargetedEntity(5) == player
	updateStatus()
end)

--────────────────────────-< Bootstrap >-────────────────────────--

nameplate.ENTITY
:setOutline(true)
:setBackgroundColor(0, 0, 0, 0)
:setPivot(0,2.2,0)
updateStatus()



return NameplateAPI
