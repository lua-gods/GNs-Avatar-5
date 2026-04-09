--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Nameplate Generator
/ /_/ / /|  /  desc: not a library
\____/_/ |_/ source: link ]]


local NAME = "GNanimates"

local USE_HEX = true


local NameplateAPI = {}
local CLR_FROM = vectors.hexToRGB("#d3fc7e")
local CLR_TO = vectors.hexToRGB("#33984b")

local CLR_STATUS = vectors.hexToRGB("#aaaaaa")
local CLR_STATUS_UPDATE = vectors.hexToRGB("#d3fc7e")


--────────────────────────-< Nameplate Name >-────────────────────────--

local nameComponent = {
	{ text = "${badges}:@gn:" },
	{ text = ":back::@gn_band:", color = "#" .. vectors.rgbToHex(CLR_FROM) },
}

local nameLength = #NAME
for i = 1, nameLength, 1 do
	local w = i / nameLength
	nameComponent[#nameComponent + 1] = {
		color = "#" .. vectors.rgbToHex(math.lerp(CLR_FROM, CLR_TO, w)),
		text = NAME:sub(i, i),
	}
end

---@cast nameComponent string
nameComponent = toJson(nameComponent)

--────────────────────────-< Nameplate Status >-────────────────────────--

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
		 '","color":"' .. (color and "#" .. vectors.rgbToHex(color) or "gray") .. '"}'
end

local function flicker(number)
	return component((toHex(math.floor(number))),
		math.lerp(CLR_STATUS_UPDATE, CLR_STATUS, math.clamp(number % 1, 0, 1)))
end

local status
local statusTime

local function updateStatus()
	local final = "["
	final = final .. '{"text":"","extra":[' .. nameComponent .. "]}"

	if status then
		final = final .. ',{"text":"\n"}'
		final = final .. component("[")

		if USE_HEX then
			if statusTime then
				local time      = client:getSystemTime()
				local timeSince = ((time - statusTime) / 1000)
				final           = final .. component(status .. " " .. toHex(timeSince):upper())
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
	else

	end


	final = final .. "]"
	nameplate.ALL:setText(final)
	nameplate.CHAT:setText(nameComponent)
end

--────────────────────────-< Update Status >-────────────────────────--

function NameplateAPI.setStatus(title, time)
	status = title
	statusTime = time
	events.WORLD_RENDER:remove("nameplateStatus")
	if status then
		local time = client:getSystemTime()
		events.WORLD_RENDER:register(function()
			local currentTime = client:getSystemTime()
			if currentTime - time > 1000 then
				time = currentTime
			end
			updateStatus()
		end, "nameplateStatus")
	end
	updateStatus()
end

--────────────────────────-< Bootstrap >-────────────────────────--

nameplate.ENTITY:setOutline(true):setBackgroundColor(0, 0, 0, 0)
updateStatus()

return NameplateAPI
