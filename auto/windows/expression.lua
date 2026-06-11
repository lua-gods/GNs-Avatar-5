local Macro = require("lib.GNMacros")

local Window = require("lib.GNUI-WindowManager.widgets.window")
local Event = require("lib.GNEvent")


local myApp

myApp = Macro.new(function(events, screen, GNUI)
	local Window = Window.new(screen)
	Window:setTitle("Face Expression")
	
	Window:getChild("content"):parse({
		layout = "HORIZONTAL",
		gap=5,
		style = "none",
		{
			{
				layout = "VERTICAL",
				style = "none",
				gap=5,
				{
					{
						text = "Right Eye",
					},
					{
						layout = "HORIZONTAL",

						minSize = vec(0, 50),
						{
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},

						},
					},
				},
			},
			{
				layout = "VERTICAL",
				style = "none",
				gap=5,
				{
					{
						text = "Left Eye",
					},
					{
						layout = "HORIZONTAL",

						minSize = vec(0, 50),
						{
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},
							{
								type = "slider",
								isVertical = true,
								sizing = { "FIT", "FILL" },
							},

						},
					},
				},
			},
		},
	})

	Window.ON_CLOSE:register(function()
		myApp:setActive(false)
	end)

	events.ON_EXIT:register(function()
		Window:free()
	end)
end)

return myApp
