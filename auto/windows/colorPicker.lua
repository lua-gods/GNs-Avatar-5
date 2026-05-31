# flags: host_only
---@diagnostic disable: return-type-mismatch
---@diagnostic disable: param-type-mismatch

local Window = require("lib.GNUI-WindowManager.widgets.window")
local Event = require("lib.GNEvent")

local ProceduralTexture = require("lib.proceduralTexture")

local TAU = math.pi * 2

local function sampleColor(x, y)
	x = x - 0.5
	y = y - 0.5

	local dist = math.sqrt(x * x + y * y) * 2
	local angle = math.atan2(x, -y)

	return vectors.hsvToRGB(angle / (TAU), dist, 1):augmented(math.clamp((1 - dist) * 98, 0, 1))
end

local RESOLUTION = 64 * 3
ProceduralTexture:newTexture("colorWheel", RESOLUTION, RESOLUTION, function(x, y, w, h)
	return sampleColor(x / RESOLUTION, y / RESOLUTION)
end)

ProceduralTexture:newTexture("brightness", 80, RESOLUTION, function(x, y, w, h)
	local i = (1 - y / h) ^ 2.2
	return vec(i, i, i, 1)
end)

local saturationTexture = ProceduralTexture:newTexture("saturation", RESOLUTION, 80,
	function(x, y, w, h)
		local i = x / w
		return vec(1, i, i, 1)
	end)

local function applySaturationHue(hue, value)
	ProceduralTexture:apply(saturationTexture, function(x, y, w, h)
		return vectors.hsvToRGB(hue, (1 - (x / w)), value):augmented(1)
	end)
end



---@class GNUI.Window.Colorpicker : GNUI.Widget.Window
---@field COLOR_CHANGED GN.Event

---@param screen GNUI.Canvas
---@param GNUI GNUIAPI
---@return GNUI.Window.Colorpicker
return function(screen, GNUI)
	--────────────────────────-< Color Picker Test >-────────────────────────--
	local colorPickerWindow = Window.new(screen)
	
	local content = screen:parse({
		
		style = "none",
		layout = "VERTICAL",
		{
			{
				type = "box",
				name = "colorPreview",
				style = "white",
				minSize = vec(11, 11),
				sizing = { "FILL", "FIT" },
				color = vec(1, 0, 0),
			},
			{
				style = "none",
				layout = "HORIZONTAL",
				{
					{
						name = "colorwheel",
						layout = "FIXED",
						sizing = { "FIXED", "FIXED" },
						minSize = vec(80, 80),
						style = {
							type = "quad",
							texturePath = "colorWheel",
						},
						{
							type = "button",
							name = "grabber",
							size = vec(4, 4),
							pos = vec(50, 50),
						},
					},
					{
						name = "brightnessSlider",
						type = "slider",
						isVertical = true,
						min = 1,
						max = 255,
						step = 1,
						{
							sizing = { "FILL", "FILL" },
							style = {
								type = "quad",
								texturePath = "brightness",
							},
						},
					},
				},
			},
			{
				layout = "HORIZONTAL",
				style = "none",
				sizing = { "FILL", "FIT" },
				{
					{
						name = "saturationSlider",
						type = "slider",
						min = 1,
						max = 255,
						step = 1,
						{
							sizing = { "FILL", "FILL" },
							style = {
								type = "quad",
								texturePath = "saturation",
							},
						},
					},
					{
						type = "button",
						name="alphaToggleButton",
						text = "a",
						toggle = true,
						pressed = true,
						minSize = vec(7, 0),
						sizing = { "FIT", "FILL" },
					},
				},
			},
			{
				name="alphaRow",
				layout = "HORIZONTAL",
				style = "none",
				sizing = { "FILL", "FIT" },
				{
					{
						type = "slider",
						name = "alphaSlider",
						min = 1,
						max = 255,
						step = 1,
					},
					{
						type = "textField",
						name="alphaField",
						placeholder = "A",
						prefix="a",
						minSize = vec(26, 0),
						sizing = { "FIT", "FILL" },
					},
				},
			},
			{
				layout = "HORIZONTAL",
				style = "none",
				sizing = { "FILL", "FIT" },
				{
					{
						type = "textField",
						name = "hexField",
						sizing = { "FILL", "FIT" },
						placeholder = "#RRGGBB",
						validator = "hex",
					},
					{
						type = "button",
						name = "copyButton",
						text = "Copy",
						minSize = vec(26, 0),
						sizing = { "FIT", "FILL" },
					},
				},
			},
			{
				layout = "HORIZONTAL",
				style = "none",
				sizing = { "FILL", "FIT" },
				{
					{
						type = "textField",
						name = "hueField",
						sizing = { "FILL", "FIT" },
						placeholder = "Hue",
						prefix="h",
						validator = "integer",
					},
					{
						type = "textField",
						name = "satField",
						sizing = { "FILL", "FIT" },
						placeholder = "Sat",
						prefix="s",
						validator = "integer",
					},
					{
						type = "textField",
						name = "valField",
						sizing = { "FILL", "FIT" },
						placeholder = "Val",
						prefix="v",
						validator = "integer",
					},
				},
			},
			{
				layout = "HORIZONTAL",
				style = "none",
				sizing = { "FILL", "FIT" },
				{
					{
						type = "textField",
						name = "rField",
						sizing = { "FILL", "FIT" },
						placeholder = "R",
						prefix = "r",
						validator = "integer",
					},
					{
						type = "textField",
						name = "gField",
						sizing = { "FILL", "FIT" },
						placeholder = "G",
						prefix = "g",
						validator = "integer",
					},
					{
						type = "textField",
						name = "bField",
						sizing = { "FILL", "FIT" },
						placeholder = "B",
						prefix = "b",
						validator = "integer",
					},
				},
			},
		},
	})

	local hsva = vec(0, 0, 1, 1)
	
	local colorWheel = content:getChild("colorwheel")
	local grabber = content:getChild("grabber") ---@cast grabber GNUI.Widget.Button
	
	local brightnessSlider = content:getChild("brightnessSlider") ---@cast brightnessSlider GNUI.Widget.Slider
	local saturationSlider = content:getChild("saturationSlider") ---@cast saturationSlider GNUI.Widget.Slider
	local colorPreview = content:getChild("colorPreview")
	
	local hexField = content:getChild("hexField") ---@cast hexField GNUI.Widget.TextField
	local copyButton = content:getChild("copyButton") ---@cast copyButton GNUI.Widget.Button
	
	local alphaRow = content:getChild("alphaRow")
	local alphaButton = content:getChild("alphaToggleButton") ---@cast alphaButton GNUI.Widget.TextField
	local alphaSlider = content:getChild("alphaSlider") ---@cast alphaSlider GNUI.Widget.Slider
	local alphaField = content:getChild("alphaField") ---@cast alphaField GNUI.Widget.TextField
	
	local hueField = content:getChild("hueField") ---@cast hueField GNUI.Widget.TextField
	local satField = content:getChild("satField") ---@cast satField GNUI.Widget.TextField
	local valField = content:getChild("valField") ---@cast valField GNUI.Widget.TextField
	
	local rField = content:getChild("rField") ---@cast rField GNUI.Widget.TextField
	local gField = content:getChild("gField") ---@cast gField GNUI.Widget.TextField
	local bField = content:getChild("bField") ---@cast bField GNUI.Widget.TextField
	
	local function applyColor(from)
		--──── Extract values from controls ────────────────────────────────────────────--
		if from == 1 then -- color wheel and sliders
			local pos = grabber.finalPos
			local areaSize = colorWheel.finalSize
			local grabberOffset = grabber.finalSize.xy * 0.5
			local samplePos = (pos + grabberOffset) / areaSize

			local value = hsva.z
			local rgb = sampleColor(samplePos.x, samplePos.y) * value
			hsva = vectors.rgbToHSV(rgb.xyz):augmented(hsva.a)
		elseif from == 2 then -- color from brightness slider
			local brightness = (1 - brightnessSlider:getNormalizedValue()) ^ 2.2
			hsva.z = brightness
		elseif from == 3 then -- color from saturation slider
			local sat = 1 - saturationSlider:getNormalizedValue()
			hsva.y = sat
		elseif from == 4 then -- color from alpha slider
			local alpha = alphaSlider:getNormalizedValue()
			hsva.w = alpha
		elseif from == 5 then -- color from hex field
		local field = hexField:getActiveField()
		local alpha = field:sub(8,9)
		local ok, result = pcall(vectors.hexToRGB,field:sub(1,7))
		if ok then
			hsva = vectors.rgbToHSV(result)
			if alpha then
				local result = tonumber(alpha,16)
				if result then
					hsva = hsva:augmented(result/255)
				else
					hsva = hsva:augmented(1)
				end
			else
				hsva = hsva:augmented(1)
			end
		end
		elseif from == 6 then -- color from alpha field
			local alphaInput = alphaField:getActiveField()
			if alphaInput and #alphaInput > 0 then
				hsva.w = math.clamp(tonumber(alphaInput)/255,0,1)
			end
		elseif from == 7 then -- hsv slider
			local hsv = vec(
				(tonumber(hueField:getActiveField()) or 0) / 255,
				(tonumber(satField:getActiveField()) or 0) / 255,
				(tonumber(valField:getActiveField()) or 0) / 255
			)
			hsva = hsv:augmented(hsva.a)
		elseif from == 8 then -- rgb slider
			local rgb = vec(
				(tonumber(rField:getActiveField()) or 0) / 255,
				(tonumber(gField:getActiveField()) or 0) / 255,
				(tonumber(bField:getActiveField()) or 0) / 255
			)
			hsva = vectors.rgbToHSV(rgb.xyz):augmented(hsva.a)
		end

		--──── Apply values to controls ────────────────────────────────────────────--
		local rgb = vectors.hsvToRGB(hsva.xyz)
		if from ~= 1 then
			local grabberOffset = grabber.finalSize.xy * 0.5
			local finalPos = vec(
				math.sin(hsva.x * TAU),
				-math.cos(hsva.x * TAU)
			) * hsva.y
			finalPos = (finalPos * 0.5 + 0.5) * colorWheel.finalSize.xy - grabberOffset
			grabber:setPos(finalPos)
		end
		if from ~= 2 then
			local correctValue = hsva.z ^ (1 / 2.2)
			brightnessSlider:setNormalizedValueSilent(1 - correctValue)
		end
		if from ~= 3 then
			saturationSlider:setNormalizedValueSilent(1 - hsva.y)
		end
		if from ~= 4 then
			alphaSlider:setNormalizedValueSilent(hsva.w)
		end
		if from ~= 5 then
			local field = vectors.rgbToHex(vectors.hsvToRGB(hsva.xyz))
			if not alphaButton.down then
				field = field .. string.format("%x", hsva.a * 255)
			end
			hexField:setField("#" .. field)
		end
		if from ~= 6 then 
			if not alphaButton.down then
				alphaField:setField(tostring(math.floor(hsva.a * 255)))
			end
		end
		if from ~= 7 then
			hueField:setField(tostring(math.floor(hsva.x * 255)))
			satField:setField(tostring(math.floor(hsva.y * 255)))
			valField:setField(tostring(math.floor(hsva.z * 255)))
		end
		if from ~= 8 then
			local rgb = vectors.hsvToRGB(hsva.xyz)
			rField:setField(tostring(math.floor(rgb.x * 255))):setColor(1,1-rgb.r,1-rgb.r)
			gField:setField(tostring(math.floor(rgb.y * 255))):setColor(1-rgb.g,1,1-rgb.g)
			bField:setField(tostring(math.floor(rgb.z * 255))):setColor(1-rgb.b,1-rgb.b,1)
		end
		applySaturationHue(hsva.x, hsva.z)
		local v = hsva.z
		brightnessSlider.boxKnob:setColor(v, v, v)
		saturationSlider.boxKnob:setColor(rgb)
		colorWheel:setColor(hsva.zzz)
		alphaRow:setVisible(not alphaButton.down)
		
		local color = vectors.hsvToRGB(hsva.xyz)
		colorPreview:setColor(vectors.hsvToRGB(hsva.xyz))

		colorPickerWindow.COLOR_CHANGED:invoke(color:augmented(hsva.w))
	end


	grabber.BUTTON_DOWN:register(function()
		screen.CURSOR_MOVED:register(function(pos, vel)
			local areaSize = colorWheel.finalSize
			local grabberOffset = grabber.finalSize.xy * 0.5
			local samplePos = (colorWheel:toLocal(pos)) / areaSize

			local HALF = vec(0.5, 0.5)

			local centerDir = samplePos - HALF
			local centerLen = centerDir:length()
			if centerLen > 0.5 then
				samplePos = (samplePos - HALF):normalize() * 0.5 + HALF
			end
			grabber:setPos((samplePos) * areaSize - grabberOffset)
			applyColor(1)
		end, grabber.id)
	end)
	alphaButton.STATE_CHANGED:register(function (down)
		applyColor(0)
	end)
	
	grabber.BUTTON_UP:register(function()
		applyColor(1)
		screen.CURSOR_MOVED:remove(grabber.id)
	end)

	local brightnessSlider = content:getChild("brightnessSlider")
	---@cast brightnessSlider GNUI.Widget.Slider

	brightnessSlider.VALUE_CHANGED:register(function(value) applyColor(2) end)
	saturationSlider.VALUE_CHANGED:register(function(value) applyColor(3) end)
	alphaSlider.VALUE_CHANGED:register(function(value) applyColor(4) end)
	copyButton.PRESSED:register(function ()
		host:setClipboard(hexField.field)
	end)
	
	hexField.FIELD_CHANGED:register(function (text) applyColor(5) end)
	alphaField.FIELD_CHANGED:register(function (text) applyColor(6) end)
	
	hueField.FIELD_CHANGED:register(function (text) applyColor(7) end)
	satField.FIELD_CHANGED:register(function (text) applyColor(7) end)
	valField.FIELD_CHANGED:register(function (text) applyColor(7) end)
	
	rField.FIELD_CHANGED:register(function (text) applyColor(8) end)
	gField.FIELD_CHANGED:register(function (text) applyColor(8) end)
	bField.FIELD_CHANGED:register(function (text) applyColor(8) end)

	
	colorPickerWindow:setPos(20, 20)

	colorPickerWindow:setTitle("Color Wheel")
	colorPickerWindow:addContent(content)
	colorPickerWindow.COLOR_CHANGED = Event.new()
	colorPreview:setColor(0, 0, 0)
	screen:addChild(colorPickerWindow)

	screen:callNextFrame(function()
		applyColor(0)
	end)

	return colorPickerWindow
end
