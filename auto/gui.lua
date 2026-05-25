# flags: host_only

if false then
	return
end


local GNUI = require("lib.GNUI.init")
GNUI.setup()

local screen = GNUI.getScreen()

if false then
	--- parent box to hold all the columns
	local classColumns = screen:parse({
		style = "empty",
		layout = "HORIZONTAL",
		sizing = { "FIT", "FIT" },
		gap = 5,
	})

	-- loop for each class with a given style
	for _, className in ipairs(GNUI.Theme.getClassNames()) do
		-- create a column container for each widget
		local variantColumn = screen:parse({
			layout = "VERTICAL",
			sizing = { "FIT", "FIT" },
			minSize = vec(80, 0),
			style = "empty",
		})
		classColumns:addChild(variantColumn)

		-- create the class header
		local classHeader = screen:parse({
			sizing = { "FILL", "FIT" },
			minSize = vec(0, 15),
			style = "empty",
			text = className,
		})
		variantColumn:addChild(classHeader)

		-- loop for each class variant
		for _, variantName in ipairs(GNUI.Theme.getVariantNames(className)) do
			-- create that given widget with the given variant
			local widget = screen:parse({
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



local function loadWindow(name)
	local WindowFactory = require("auto.windows."..name)
	WindowFactory(screen,GNUI)
end

loadWindow("colorPicker")





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