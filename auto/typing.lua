local tweens = require("lib.tween")
local zlib = require("lib.zlib")

local LABEL_WORLD = models:newPart("LabelWorld", "WORLD"):setMatrix(matrices.mat4() * 0.1)

local VOICE_INTERVAL = 0.09

local COLOR = vectors.hexToRGB("#4DB52A")
local ALT_COLOR = vectors.hexToRGB("#B52AA3")
local OUTLINE_COUNT = 16
local OUTLINE_SIZE = 0.4



local fixes = client.getTextWidth(".")
local function getWidth(text)
	if text:find("^:[^:]+:$") == ":" then
		return 8
	else
		return client.getTextWidth("." .. text .. ".") - fixes * 2
	end
end


local function splitWithColons(text)
	local result = {}
	local i = 1
	local len = #text

	while i <= len do
		local char = text:sub(i, i)

		if char == ":" then
			local j = i + 1
			while j <= len and text:sub(j, j) ~= ":" do
				j = j + 1
			end

			-- If we found a closing colon, combine the whole :word:
			if j <= len then
				table.insert(result, text:sub(i, j))
				i = j + 1
			else
				-- No closing colon, treat ':' as a normal character
				table.insert(result, char)
				i = i + 1
			end
		else
			table.insert(result, char)
			i = i + 1
		end
	end

	return result
end



local Label = {}
Label.__index = Label

local DOWN = vec(0, -10, 0)
local UP = vec(0, 1, 0)

local c = 0
function Label.new(text, pos, rot, scale, shake, drippy, alt)
	scale = scale or 1
	pos = pos * 16
	local self = setmetatable({}, Label)
	self.text = text
	self.tasks = {}
	self.char = {}

	local letters = splitWithColons(text)
	local COLOR = alt and ALT_COLOR or COLOR

	local offset = -getWidth(text) / 2 * scale
	for i = 1, #letters, 1 do
		c = c + 1
		local letter = letters[i]
		local width = getWidth(letter)

		local part = LABEL_WORLD:newPart("Letter" .. c)
		part
			 :setPos(vectors.rotateAroundAxis(rot, vec(offset + (width * 0.5) * scale, 0, 0), UP) + pos)
			 :light(15, 15)
			 :rot(0, rot + 180, 0):setVisible(false)
		local j = toJson(letter)
		for i = 0, OUTLINE_COUNT, 1 do
			local t = part:newText("letter" .. c .. i)
			if i == 0 then
				t:setText('{"text":' .. j .. ',"color":"#' .. vectors.rgbToHex(COLOR) .. '"}')
				t:setPos(width * 0.5, 4, -0.07):rot(-1, 0, 0)
			elseif i == 1 then
				t:setText('{"text":' .. j .. ',"color":"#' .. vectors.rgbToHex(COLOR * 0.85) ..
					'"}')
				t:setPos(width * 0.5, 4, 0)
			else
				t:setText('{"text":' .. j .. ',"color":"#' .. vectors.rgbToHex(1, 1, 1) .. '"}')
				local c = i / OUTLINE_COUNT
				local o = vec(math.sin(c * math.pi * 2), math.cos(c * math.pi * 2), 0) * OUTLINE_SIZE
				t:setPos(width * 0.5 + o.x, 4 + o.y, 0.01)
			end
		end
		offset = offset + width * scale
		self.tasks[i] = part
		self.char[i] = letter
	end

	local c = 1
	
	local voiceCooldown = 0
	local cooldown = 0
	local lastTime = client:getSystemTime()
	local speed = #text > 15 and 0.03 or 0.06

	local duration = speed * #text + 1

	events.WORLD_RENDER:register(function()
		local time = client:getSystemTime()
		local delta = (time - lastTime) / 1000
		lastTime = time
		cooldown = cooldown + delta
		
		voiceCooldown = voiceCooldown + delta
		if voiceCooldown > VOICE_INTERVAL then
			sounds[alt and "sounds.fspeak" or "sounds.speak"]
			:pos(pos / 16)
			:volume(0.2)
			:play()
			:setAttenuation(0.01)
			voiceCooldown = 0
		end
		
		local finalSpeed = speed

		local char = self.char[c]
		if char == "." then
			finalSpeed = 1
			voiceCooldown = 0
		elseif char == " " then
			finalSpeed = finalSpeed * 1.5
		elseif char == "," then
			voiceCooldown = 0
			finalSpeed = 0.5
		end
		
		if cooldown > finalSpeed then
			
			cooldown = 0
			local task = self.tasks[c]
			local pos = task:getPos()
			local _, floorPos = raycast:block(pos / 16, pos / 16 + DOWN)
			local r = math.random() - 0.5

			tweens.new {
				from = 1,
				to = -3,
				duration = duration,
				easing = "outQuad",
				tick = function(v, t)
					if v > 0 then
						local e = (1 + math.max(v, 0) * 0.5) * scale
						task
							 :setVisible(true)
							 :scale(e, e, e)
					end
					local shift = vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.5 *
					shake
					local droop = drippy and (r - 1) * (1 - t) or 0
					task:pos(pos + shift + vec(0, droop * -2, 0))
				end,
				onFinish = function()
					tweens.new {
						from = pos,
						to = floorPos * 16,
						duration = math.random() * 0.2 + 0.2,
						easing = "inQuad",
						tick = function(v, t)
							task
								 :setPos(v)
								 :setRot(25 * t, r * 90 * t + rot + 180, 0)
						end,
						onFinish = function()
							local pos = task:getPos()
							tweens.new {
								from = 0,
								to = math.pi,
								duration = 0.30,
								easing = "linear",
								tick = function(v, t)
									task
										 :setPos(pos.x, pos.y + math.sin(v) * 4, pos.z)
										 :setRot(t * 45 + 45, r * 90 * t + rot + 180, 0)
								end,
							}

							tweens.new {
								from = scale,
								to = 0,
								duration = 0.6,
								easing = "linear",
								tick = function(v, t)
									task
										 :scale(v, v, v)
								end,
								onFinish = function()
									task:remove()
								end,
							}
						end,
					}
				end,
			}
			
			c = c + 1
			if c > #self.tasks then
				events.WORLD_RENDER:remove("AAA")
			end
		end
	end, "AAA")
end

function pings.mitext(text, scale, shake, drippy, alt)
	if player:isLoaded() then
		local diff = (player:getPos() - client:getCameraPos()).x_z:normalize()
		Label.new(zlib.Deflate.Decompress(text),
			player:getPos():add(0, player:getEyeHeight() / 1.2, 0) - diff * 0.5,
			math.deg(math.atan2(diff.x, diff.z)) + 180, scale or 0.75,
			shake, drippy, alt)
	end
end

function mitext(text, scale, shake, drippy, alt)
	pings.mitext(zlib.Deflate.Compress(text), scale, shake or 0, drippy or false, FEMALE or alt)
end

events.CHAT_SEND_MESSAGE:register(function(message)
	local screamCount = 0
	message:gsub("%?!", function() screamCount = screamCount + 1 end)
	message:gsub("!%?", function() screamCount = screamCount + 1 end)
	message:gsub("!!", function() screamCount = screamCount + 1 end)

	pings.mitext(zlib.Deflate.Compress(message),
		#message > 20 and 0.3 or 0.5,
		screamCount,
		(message:find("%.%.$")
			or message:find(":%(")
			or message:find(":c")))
	return message
end, "milatch")
