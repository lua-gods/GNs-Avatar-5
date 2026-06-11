---@diagnostic disable: param-type-mismatch, redefined-local
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Miside Text
/ /_/ / /|  /  desc: makes the thing you type in chat look like from miside
\____/_/ |_/ source: link 
-- NOTE:

- This script is crazy expensive, only works on Max

]]

--────────────────────────-< DEPENDENCEIS >-────────────────────────--

local tweens = require("lib.GNtween")


--────────────────────────-< CONFIG >-────────────────────────--

local KEY = 0
events.TICK:register(function ()
	KEY -- avoid crash log revealing how the key is generated
	=
	math
	.
	floor
	(
	world
	.
	getTime
	(
	)
	/
	12000
	)
	KEY = KEY % 256
end)


local function xorCipher(text, key)
    local out = {}

    for i = 1, #text do
        local byte = string.byte(text, i)

        -- Derive a per-character key
        local k = (key + i) % 256

        out[i] = string.char(bit32.bxor(byte, k))
    end

    return table.concat(out)
end

local key = 42




local function ENCRYPT(string)
	return xorCipher(string, key)
end


local function DECRYPT(string)
	
	return xorCipher(string, key)
end




local LINE_SEPARATORS = ",;.?!"
local SHRINK_RATIO = 100
local TEST_MODE = false
local VOICE_INTERVAL = 0.09
local COLOR = vectors.hexToRGB("#4DB52A")
local COLOR_OUTLINE = vectors.hexToRGB("#ffffff")
local OUTLINE_COUNT = 24
local OUTLINE_THICKNESS = 0.2

--────────────────────────-< END OF CONFIG >-────────────────────────--

local LABEL_WORLD = models:newPart("LabelWorld", "WORLD")


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
	local i = 0
	while i < #text do
		local part = text:sub(i+1,-1)
		local char = part:match("^:[%w_]+:") or part:match("^[\x00-\x7F\xC2-\xF4][\x80-\xBF]*") or part:sub(1, 1)
		result[#result+1] = char
		i = i + #char
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
---@param screaming number
local function speak(message, pos, rot, scale, screaming)
	scale = scale or 1
	pos = pos * 16
	
	local from,to = message:find("^[^"..LINE_SEPARATORS.."]*["..LINE_SEPARATORS.." ]*")

	local text = message:sub(from,to)
	local tasks = {}
	
	local letters = splitWithColons(text)
	
	local color1 = '#'..vectors.rgbToHex(COLOR)
	local color2 = '#'..vectors.rgbToHex(COLOR * 0.85)
	local color3 = '#'..vectors.rgbToHex(COLOR_OUTLINE)

	
	local fscale = (SHRINK_RATIO/(getWidth(text)+SHRINK_RATIO)) * scale
	local outline = OUTLINE_THICKNESS / fscale
	
	local offset = -getWidth(text) / 2 * fscale
	for i = 1, #letters, 1 do
		c = c + 1
		local letter = letters[i]
		local width = getWidth(letter)

		local part = LABEL_WORLD:newPart("Letter" .. c)
		part
		:setPos(vectors.rotateAroundAxis(rot, vec(offset + (width * 0.5) * fscale, 0, 0), UP) + pos)
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
				local o = vec(math.sin(c * math.pi * 2), math.cos(c * math.pi * 2), 0) * outline
				t:setPos(width * 0.5 + o.x, 4 + o.y, 0.01)
			end
		end
		
		for i = 0, OUTLINE_COUNT+2, 1 do
			local t = part:newText("lettere" .. c .. i)
			t:setText('{"text":' .. j .. ',"color":"#000000"}')
			local c = i / OUTLINE_COUNT
			local o = vec(math.sin(c * math.pi * 2), math.cos(c * math.pi * 2), 0) * outline * 2
			t:setPos(width * 0.5 + o.x, 4 + o.y, 0.1)
		end
		offset = offset + width * fscale
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
						local e = (1 + math.max(v, 0) * 0.5) * fscale
						task
							 :setVisible(true)
							 :scale(e, e, e)
					end
					local shift = vec(0,0,0)
					if screaming then
						shift = 
						vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) 
						* 0.5 * math.max(0,1-t*3)
					end
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
				from = fscale,
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
						from = fscale,
						to = 0,
						duration = 1,
						onFinish = function()
							speak(message:sub(to+1,-1), pos / 16, rot, scale, screaming)
						end,
					}
				end
				events.RENDER:remove("Miside Text"..id)
			end
		end
	end, "Miside Text"..id)
end

function pings.mitext(text, scale, screaming)
	if player:isLoaded() then
		local diff = (player:getPos() - client:getCameraPos()).x_z:normalize()
		local pos
		local rot
		if renderer:isFirstPerson() and client:getCameraEntity() == player then
			pos = client:getCameraPos()+client:getCameraDir().xyz:normalize():mul(1,1,1):add(0,-0.5,0)
			scale = scale * 0.5
			rot = 180-client:getCameraRot().y
		else
			pos = player:getPos():add(0, player:getEyeHeight() / 1.2, 0) - diff * 0.5
			rot = math.deg(math.atan2(diff.x, diff.z))-180
		end
		speak(
			DECRYPT(text),
			pos,
			rot, scale,
			screaming
		)
	end
end

function mitext(text, scale, shake)
	pings.mitext(ENCRYPT(text), scale, shake or 0)
end

events.CHAT_SEND_MESSAGE:register(function(message)
	if message and not message:find("^/") then
		pings.mitext(
			ENCRYPT(message),
			1,
			(message:find("!") and (not message:find("%l"))))
		if not TEST_MODE then
			return message
		else
			host:appendChatHistory(message)
		end
	else
		return message
	end
	
end, "milatch")
