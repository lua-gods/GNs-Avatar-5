---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Miside Text
/ /_/ / /|  /  desc: makes the thing you type in chat look like from miside
\____/_/ |_/ source: link 
-- NOTE:

- This script is crazy expensive, only works on Max

]]

--────────────────────────-< DEPENDENCEIS >-────────────────────────--

local tweens = require("lib.tween")
local zlib = require("lib.zlib")

--────────────────────────-< CONFIG >-────────────────────────--

local TEST_MODE = false
local VOICE_INTERVAL = 0.09
local COLOR = vectors.hexToRGB("#4DB52A")
local COLOR_OUTLINE = vectors.hexToRGB("#ffffff")
local OUTLINE_COUNT = 8
local OUTLINE_SIZE = 0.4

--────────────────────────-< END OF CONFIG >-────────────────────────--

local LABEL_WORLD = models:newPart("LabelWorld", "WORLD"):setMatrix(matrices.mat4() * 0.1)


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
		-- this unicode catcher dosent seem to work.
		local from,to = text:find("^[\x00-\x7F\xC2-\xF4][\x80-\xBF]*",i)
		local char = text:sub(from, to)
		local charLen = to - from + 1
		i = from
		
		if char == ":" then
			local j = i + 1
			while j <= len and text:sub(j, j) ~= ":" do
				j = j + 1
			end

			-- If we found a closing colon, combine the whole :word:
			if j <= len then
				table.insert(result, text:sub(i, j))
				i = j + charLen
			else
				-- No closing colon, treat ':' as a normal character
				table.insert(result, char)
			end
		else
			table.insert(result, char)
		end
		
		i = i + charLen
	end

	return result
end


local DOWN = vec(0, -10, 0)
local UP = vec(0, 1, 0)

local c = 0

---@param message string
---@param pos Vector3
---@param rot number
---@param scale number
---@param shake number
local function speak(message, pos, rot, scale, shake)
	scale = scale or 1
	pos = pos * 16
	
	local from,to = message:find("[^.,]*[.,]?")

	local text = message:sub(from,to)
	:gsub("^%s*","")
	:gsub("%s*$","")
	local tasks = {}
	
	local letters = splitWithColons(text)
	
	local color1 = '#'..vectors.rgbToHex(COLOR)
	local color2 = '#'..vectors.rgbToHex(COLOR * 0.85)
	local color3 = '#'..vectors.rgbToHex(COLOR_OUTLINE)

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
		for i = 0, OUTLINE_COUNT+2, 1 do
			local t = part:newText("letter" .. c .. i)
			if i == 0 then
				t:setText('{"text":' .. j .. ',"color":"' .. color1 .. '"}')
				t:setPos(width * 0.5, 4, -0.07):rot(-1, 0, 0)
			elseif i == 1 then
				t:setText('{"text":' .. j .. ',"color":"' .. color2 .. '"}')
				t:setPos(width * 0.5, 4, 0)
			else
				t:setText('{"text":' .. j .. ',"color":"' .. color3 .. '"}')
				local c = i / OUTLINE_COUNT
				local o = vec(math.sin(c * math.pi * 2), math.cos(c * math.pi * 2), 0) * OUTLINE_SIZE
				t:setPos(width * 0.5 + o.x, 4 + o.y, 0.01)
			end
		end
		offset = offset + width * scale
		tasks[i] = part
	end

	local c = 1

	local id = math.random(1000, 9999)
	
	local voiceCooldown = 0
	local cooldown = 0
	local lastTime = client:getSystemTime()
	local speed = #text > 15 and 0.03 or 0.06

	local duration = speed * #text + 1

	events.RENDER:register(function(_,ctx)
		if not (ctx == "RENDER" or ctx == "FIRST_PERSON") then
			return
		end
		
		local time = client:getSystemTime()
		local delta = (time - lastTime) / 1000
		lastTime = time
		cooldown = cooldown + delta

		voiceCooldown = voiceCooldown + delta
		if voiceCooldown > VOICE_INTERVAL then
			sounds["sounds.speak"]
			:pos(pos / 16)
			:volume(0.2)
			:play()
			:setAttenuation(0.01)
			voiceCooldown = 0
		end

		local finalSpeed = speed
		
		if cooldown > finalSpeed then
			cooldown = 0
			local task = tasks[c]
			local tpos = task:getPos()
			local _, floorPos = raycast:block(tpos / 16, tpos / 16 + DOWN)
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
					task:pos(tpos + shift)
				end,
				onFinish = function()
			tweens.new {
				from = tpos,
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
			if c > #tasks then
				if (to < #message) then
					tweens.new {
						from = scale,
						to = 0,
						duration = 1,
						onFinish = function()
							speak(message:sub(to+1,-1), pos / 16, rot, scale, shake)
						end,
					}
				end
				events.RENDER:remove("Miside Text"..id)
			end
		end
	end, "Miside Text"..id)
end

function pings.mitext(text, scale, shake)
	if player:isLoaded() then
		local diff = (player:getPos() - client:getCameraPos()).x_z:normalize()
		speak(
			zlib.Deflate.Decompress(text),
			player:getPos():add(0, player:getEyeHeight() / 1.2, 0) - diff * 0.5,
			math.deg(math.atan2(diff.x, diff.z)) + 180, scale or 0.75,
			shake
		)
	end
end

function mitext(text, scale, shake)
	pings.mitext(zlib.Deflate.Compress(text), scale, shake or 0)
end

events.CHAT_SEND_MESSAGE:register(function(message)
	local screamCount = 0
	message:gsub("%?!", function() screamCount = screamCount + 1 end)
	message:gsub("!%?", function() screamCount = screamCount + 1 end)
	message:gsub("!!", function() screamCount = screamCount + 1 end)
	
	pings.mitext(zlib.Deflate.Compress(message),
		#message > 20 and 0.3 or 0.5,
		screamCount)
	if not TEST_MODE then
		return message
	else
		host:appendChatHistory(message)
	end
end, "milatch")
