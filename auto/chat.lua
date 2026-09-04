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

--──── CONFIG ────────────────────────────────────────────--


local MODEL = models.bubble.bubble
local MAX_WIDTH = 128+32
local PADDING = 3
local CHILD_GAP = 4
local MASTER_VOLUME = 0.5
local MASTER_SCALE = 0.3

--──── END OF CONFIG ────────────────────────────────────────────--

local scroll = 0


local modelOrigin = models:newPart("bubbleOrigin")
local modelCamera = modelOrigin:newPart("bubbleCamera", "CAMERA")
local modelScroll = modelCamera:newPart("scroll")
local lastBubbleModel


MODEL:setVisible(false)
modelOrigin:setPos(0, 32 + 8, 0)
modelOrigin:scale(MASTER_SCALE)


---@param id Minecraft.soundID
---@param pitch any
---@param volume any
local function sound(id, pitch, volume)
	if player:isLoaded() then
		return sounds:playSound(id, player:getPos(), volume * MASTER_VOLUME, pitch)
	end
end


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


local function newBubble(text)
	local model = modelUtils.deepCopy(MODEL)
	model:setVisible(true)
	model:setLight(15, 15)
		 :setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")

	--modelOrigin:setPos(0,20,0)
	modelScroll:addChild(model)

	local label = model.LBL:newText("label")

	label:setAlignment("LEFT")
		 :setText(('{"text":"%s","color":"white"}'):format(text))
		 :width(MAX_WIDTH+3)
		 :light(15, 15)
		 :setVisible(true)
	local size = client.getTextDimensions(text:gsub(":[^:]+:", "_l"),MAX_WIDTH+3,true):ceil()
		 :sub(1, 0) -- removes excess space at the end of text
		 :add(PADDING*2, PADDING)

	-- I am too lazy ok
	local function setSize(size)
		local h = size.x * 0.5 - 0.5
		label:pos(h+0.5-PADDING, size.y - 1 - PADDING * 0.5)
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
		to = scroll + size.y + PADDING + CHILD_GAP,
		duration = 0.15,
		easing = "outSine",
		tick = function(v, t)
			modelScroll:setPos(0, v)
			scroll = v
			model:setPos(0, -v)
		end,
	}
	model:setVisible(true)
	label:setVisible(false)
	
	-- the animation that plays when the speech bubble expands
	Tween.new {
		from = vec(8, 0),
		to = size,
		duration = 0.15,
		easing = "outSine",
		tick = function(v, t)
			setSize(v)
		end,
		onFinish = function()
			label:setVisible(true)
		end,
	}

	local bubble = {
		model = model,
		label = label,
		setSize = setSize,
	}

	Tween.new {
		duration = 5,
		onFinish = function()
			fade(bubble)
		end,
	}

	return bubble
end

--──── BASIC ENCRYPTION ────────────────────────────────────────────--

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

--──── FIGURA HOOKS ────────────────────────────────────────────--

function pings.chat(msg)
	msg = msg:gsub("\\", "\n")
	newBubble(decrypt(msg))
	
	-- the sound that plays when a bubble appears
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

events.CHAT_SEND_MESSAGE:register(function(message)
	if message and not message:find("^/") then
		pings.chat(encrypt(message))
	end
	return message
end)
