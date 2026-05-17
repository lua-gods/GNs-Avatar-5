# flags: host_only

if false then
	return
end


local GNUI = require("lib.GNUI.init")
GNUI.setup()

local screen = GNUI.getScreen()

if false then
	--- parent box to hold all the columns
	local classColumns = GNUI.parse(screen, {
		style = "empty",
		layout = "HORIZONTAL",
		sizing = { "FIT", "FIT" },
		gap = 5,
	})

	-- loop for each class with a given style
	for _, className in ipairs(GNUI.Theme.getClassNames()) do
		-- create a column container for each widget
		local variantColumn = GNUI.parse(screen, {
			layout = "VERTICAL",
			sizing = { "FIT", "FIT" },
			minSize = vec(80, 0),
			style = "empty",
		})
		classColumns:addChild(variantColumn)

		-- create the class header
		local classHeader = GNUI.parse(screen, {
			sizing = { "FILL", "FIT" },
			minSize = vec(0, 15),
			style = "empty",
			text = className,
		})
		variantColumn:addChild(classHeader)

		-- loop for each class variant
		for _, variantName in ipairs(GNUI.Theme.getVariantNames(className)) do
			-- create that given widget with the given variant
			local widget = GNUI.parse(screen, {
				type = className,
				sizing = { "FILL", "FIT" },
				style = variantName,
				text = variantName,
			})
			variantColumn:addChild(widget)

			--if className == "button" then
			--	widget.PRESSED:register(function ()
			--		widget:free()
			--	end)
			--end
		end
	end
	classColumns:setPos(5, 5)
	screen:addChild(classColumns)
end




local Window = require("lib.GNUI-WindowManager.widgets.window")




--────────────────────────-< Color Picker Test >-────────────────────────--

local ProceduralTexture = require("lib.proceduralTexture")

local RESOLUTION = 512
ProceduralTexture:newTexture("colorWheel", RESOLUTION, RESOLUTION, function(x, y, w, h)
	local v = (x + 0.5) / w - 0.5
	local u = (y + 0.5) / h - 0.5

	local dist = math.sqrt(u * u + v * v) * 2
	if dist > 1 then return vec(0, 0, 0, 0) end

	local angle = math.atan2(v, u)
	return vectors.hsvToRGB(angle / (math.pi * 2), dist, 1)
		 :augmented(math.clamp((1 - dist) * 98, 0, 1))
end)

ProceduralTexture:newTexture("brightness", 80, RESOLUTION, function(x, y, w, h)
	local i = 1 - y / h
	return vec(i, i, i, 1)
end)

ProceduralTexture:newTexture("hue", RESOLUTION, 80, function(x, y, w, h)
	return vectors.hsvToRGB(0.75 - x / w, 1, 1)
end)

ProceduralTexture:newTexture("saturation", RESOLUTION, 80, function(x, y, w, h)
	return vec(x / w, x / w, 1, 1)
end)

ProceduralTexture:newTexture("alpha", RESOLUTION, 11, function(x, y, w, h)
	local pattern = 1 - x / w
	return vec(pattern, pattern, pattern, 1)
end)



local content = GNUI.parse(screen, {
  sizing = { "FIT", "FIT" },
  style = "none",
  layout = "VERTICAL",
  {
    {
      style = "none",
      layout = "HORIZONTAL",
      {
        {
          name = "colorwheel",
          sizing = { "FIXED", "FIXED" },
          minSize = vec(80, 80),
          style = {
            type = "quad",
            texturePath = "colorWheel",
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
      type = "slider",
      {
        sizing = { "FILL", "FILL" },
        style = {
          type = "quad",
          texturePath = "hue",
        },
      },
    },
    {
      type = "slider",
      {
        sizing = { "FILL", "FILL" },
        style = {
          type = "quad",
          texturePath = "saturation",
        },
      },
    },
    {
      type = "slider",
      {
        sizing = { "FILL", "FILL" },
        style = {
          type = "quad",
          texturePath = "alpha",
        },
      },
    },
  },
})



local colorWheel = content:getChild("colorwheel")

local brightnessSlider = content:getChild("brightnessSlider")
---@cast brightnessSlider GNUI.Widget.Slider

brightnessSlider.VALUE_CHANGED:register(function(value)
	value = 1 - value / 255
	colorWheel:setColor(value, value, value)
end)


local colorPickerWindow = Window.new(screen)
colorPickerWindow
	 :setPos(20, 20)

colorPickerWindow:setTitle("Color Wheel")
colorPickerWindow:addContent(content)
screen:addChild(colorPickerWindow)




--────────────────────────────────────────-< GNUI Boilerplate >-────────────────────────────────────────--
-- TODO: make all this boilerplate code a loadable preset instead
events.KEY_PRESS:register(function(key, state)
	local cancel = screen:inputKey(key, state)
	if cancel then
		host:setChatText("")
	end
	return cancel
end)

events.CHAR_TYPED:register(function(char, modifiers, codepoint) screen:inputChar(char) end)
events.MOUSE_PRESS:register(function(button, state) screen:inputMouse(button, state) end)
events.MOUSE_SCROLL:register(function(amount) screen:inputScroll(amount, 0) end)


function events.WORLD_RENDER()
	local screenID = host:getScreen()
	if (action_wheel:isEnabled() or screenID) and not screenID == "net.minecraft.class_408" then -- move mouse away if theres already UI open
		screen:setCursorPos(-1000, -1000)
	else
		screen:setCursorPos(client:getMousePos() *
			(client:getScaledWindowSize() / client:getWindowSize()))
	end
	screen:flushUpdates()
end

screen.display:setParentType("HUD")
