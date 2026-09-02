--[[______   __
  / ____/ | / / Name: GN CHAT BUBBLES v1.0.0
 / / __/  |/ /  Desc: hard coded, dont use lmao, heavily inspired by Lua Fish's basicBubbles https://discord.com/channels/1129805506354085959/1538524060949020782
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]

---@diagnostic disable: param-type-mismatch
local modelUtils = require("lib.modelUtils")
local Tween = require("lib.GNtween")

local MODEL = models.bubble.bubble
local MODEL_ALT = models.bubble_alt.bubble
local MAX_WIDTH = 128+32
local PADDING = 1
local CHILD_GAP = 4
local MASTER_VOLUME = 0.5
local MASTER_SCALE = 0.3

local scroll = 0

MODEL:setVisible(false)
MODEL_ALT:setVisible(false)

local modelOrigin = models:newPart("bubbleOrigin")
local modelCamera = modelOrigin:newPart("bubbleCamera", "CAMERA")
local modelScroll = modelCamera:newPart("scroll")


---@param id Minecraft.soundID
---@param pitch any
---@param volume any
local function sound(id, pitch, volume)
	if player:isLoaded() then
		return sounds:playSound(id, player:getPos(), volume * MASTER_VOLUME, pitch)
	end
end


modelOrigin:setPos(0, 32 + 8, 0)
modelOrigin:scale(MASTER_SCALE)

local lastBubbleModel


local function fade(bubble)
	Tween.new {
		from = 1,
		to = 0,
		duration = 1,
		tick = function(v, t)
			bubble.model:setOpacity(v)
			bubble.label:setOpacity(v)
			if v < 0.05 then -- patch for rendering glitch
				bubble.label:setVisible(false)
			end
		end,
		onFinish = function()
			bubble.model:remove()
		end,
	}
end

local function newBubble(text,alt)
	local model = modelUtils.deepCopy(alt and MODEL_ALT or MODEL)
	model:setVisible(true)
	model:setLight(15, 15)
		 :setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")

	--modelOrigin:setPos(0,20,0)
	modelScroll:addChild(model)

	local label = model.LBL:newText("label")

	label:setAlignment("LEFT")
		 :setText(text)
		 :width(MAX_WIDTH)
		 :light(15, 15)
		 :setVisible(true)

	local size = client.getTextDimensions(text:gsub(":[^a-zA-Z_]+:", "W"), MAX_WIDTH, true):ceil()
		 :add(1, 0)
		 :add(PADDING, PADDING)
	size.x = math.max(size.x, 8)
	size.x = math.ceil(size.x / 2) * 2


	-- I am too lazy ok
	local function setSize(size)
		local h = size.x * 0.5 - 0.5
		label:pos(h, size.y - 1 - PADDING * 0.5)
		model.BL:pos(h, 0):scale(1, 1, 0)
		model.BM:pos(0, 0):scale(size.x, 1, 0)
		model.BR:pos(-h, 0):scale(1, 1, 0)
		model.ML:pos(h, 0):scale(1, size.y, 0)
		model.MM:pos(0, 0):scale(size.x, size.y, 0)
		model.MR:pos(-h, 0):scale(1, size.y, 0)
		model.TL:pos(h, size.y - 1):scale(1, 1, 0)
		model.TM:pos(0, size.y - 1):scale(size.x, 1, 0)
		model.TR:pos(-h, size.y - 1):scale(1, 1, 0)
	end

	if lastBubbleModel then
		lastBubbleModel.TAIL:remove()
	end
	lastBubbleModel = model


	model:setVisible(false)


	Tween.new {
		from = scroll,
		to = scroll + size.y + CHILD_GAP,
		duration = 0.15,
		easing = "outSine",
		tick = function(v, t)
			modelScroll:setPos(0, v)
			scroll = v
			model:setPos(0, -v)
		end,
	}
	model:setVisible(true)
	Tween.new {
		from = vec(8, 0),
		to = size,
		duration = 0.15,
		easing = "outSine",
		tick = function(v, t)
			setSize(v)
			label:width(v.x)
			label:setVisible(false)
		end,
		onFinish = function()
			label:setVisible(true)
			label:setVisible(true)
		end,
	}

	local bubble = {
		model = model,
		label = label,
		setSize = setSize,
	}

	Tween.new {
		from = 0,
		to = 0,
		duration = 5,
		onFinish = function()
			fade(bubble)
		end,
	}

	return bubble
end

--[[
local bubble = newSpeech("ooo")

local clock = 0
local time = 0
events.TICK:register(function ()
	clock = clock + 1
	if clock > 3 then
		clock = 0
		time = (time + 1) % 6
		local str = ""
		for i = 0, 2, 1 do
			str = str .. ((time == i) and "O" or "o")
		end
		bubble.label:setText(str)
	end
end)
--]]


local function getKey(alt)
	return math.floor(world.getTimeOfDay() / 12000 + (alt and 1 or 0))
end

local HEADER = "BALLS"


local function xorCipher(text, key)
	local out = {}
	local prngState = bit32.bxor(key, 0xA5A5A5A5)

	for i = 1, #text do
		local byte = string.byte(text, i)
		prngState = (prngState * 1664525 + 1013904223) % 4294967296

		local k1 = bit32.rshift(prngState, 16)
		local k2 = (key * i) % 256
		local derivedKey = bit32.bxor(k1, k2, i) % 256

		out[i] = string.char(bit32.bxor(byte, derivedKey))
	end

	return table.concat(out)
end

local function encrypt(text)
	return xorCipher(HEADER .. text, math.floor(world.getTimeOfDay() / 12000))
end

local function decrypt(text)
	local result = xorCipher(text, getKey())
	if not result:find("^" .. HEADER) then
		result = xorCipher(text, getKey(true))
	end
	return result:sub(#HEADER + 1, -1)
end


function pings.chat(msg, alt)
	if alt then
		local total = math.max(#msg,1)
		newBubble('{"text":"'..(("g"):rep(total*2))..'","font":"minecraft:alt","obfuscated":true,"color":"#00ff00"}',alt)
		--[ [
		local count = 0
		local timer = 0
		local lastSound
		local lastSound2
		
		local function process()
			timer = timer + 1
			if timer > 2 then
				timer = 0
				if lastSound then
					lastSound:stop()
					lastSound2:stop()
				end
				lastSound = sound("minecraft:block.note_block.bit", math.lerp(0.02,0.2,math.random()), 1)
				lastSound2 = sound("minecraft:block.note_block.bit", math.lerp(0.02,0.2,math.random()), 1)
				count = count + 1
				if count > total then
					lastSound:stop()
					lastSound2:stop()
					sound("minecraft:block.note_block.bit", 0.1, 1)
					events.TICK:remove(process)
				end
			end
		end
		events.TICK:register(process)
		--]]
		
		
		--[[
		local s = sound("minecraft:block.note_block.bit",1,1)
		Tween.new {
			from = 1,
			to = 0.5,
			duration = 1,
			tick = function (v, t)
				local r = math.lerp(0.2,v,math.random())
				s:pitch(r)
			end,
		}
		--]]
	else
		msg = msg:gsub("\\", "\n")
		newBubble('{"text":"' .. decrypt(msg) .. '","color":"white"}')
		sound("minecraft:entity.item.pickup", 0.35, 0.5)
		Tween.new {
			from = 0,
			to = 0,
			duration = 0.15,
			onFinish = function()
				sound("minecraft:entity.item.pickup", 0.7, 0.5)
			end,
		}
	end
end

events.CHAT_SEND_MESSAGE:register(function(message)
	if message then
		if message:find("^/") then
			pings.chat(("a"):rep(#message*0.25),true)
		else
			pings.chat(encrypt(message))
		end
		return message
	end
end)
