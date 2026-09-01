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
local MAX_WIDTH = 128
local PADDING = 1
local CHILD_GAP = 4
local MASTER_VOLUME = 0.5
local MASTER_SCALE = 0.3

local scroll = 0

MODEL:setVisible(false)

local modelOrigin = models:newPart("bubbleOrigin")
local modelCamera = modelOrigin:newPart("bubbleCamera", "CAMERA")
local modelScroll = modelCamera:newPart("scroll")


---@param id Minecraft.soundID
---@param pitch any
---@param volume any
local function sound(id, pitch, volume)
	if player:isLoaded() then
		sounds:playSound(id, player:getPos(), volume * MASTER_VOLUME, pitch)
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

local function newBubble(text)
	text = text:gsub("\\","\n")
	local model = modelUtils.deepCopy(MODEL)
	model:setVisible(true)
	model:setLight(15, 15)
		 :setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")

	--modelOrigin:setPos(0,20,0)
	modelScroll:addChild(model)

	local label = model.LBL:newText("label")

	label:setAlignment("LEFT")
		 :setText('{"text":"' .. text .. '","color":"#000000"}')
		 :width(MAX_WIDTH)
		 :light(15, 15)
		 :setVisible(true)

	local size = client.getTextDimensions(text:gsub(":[^:]+:", "W"), MAX_WIDTH, true):ceil():add(1, 0)
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
	sound("minecraft:entity.item.pickup", 0.35, 0.5)
	Tween.new {
		from = 0,
		to = 0,
		duration = 0.15,
		onFinish = function()
			sound("minecraft:entity.item.pickup", 0.7, 0.5)
		end,
	}
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


events.CHAT_SEND_MESSAGE:register(function(message)
	newBubble(message)
	return message
end)
