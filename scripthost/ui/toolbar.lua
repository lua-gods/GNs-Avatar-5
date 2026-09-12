local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()


local ENTRIES = {
	{
		name = "Color Picker",
		path = "colorize",
		icon = ":palette:"
	},
	{
		name = "Orthographic Projection",
		path = "orthographic",
		icon = ":camera:"
	},
	--{
	--	name = "Face Expression",
	--	path = "expression",
	--	icon = ":smile:"
	--},
}


local toolbar = screen:parse{
	layout="HORIZONTAL",
	style="opaque",
	pos = vec(5,5),
	name="toolbar",
	sizing={"FIT","FIT"}
}






for index, entry in ipairs(ENTRIES) do
	local btn = toolbar:parse{
		--name = entry.name,
		type = "button",
		sizing={"FIT","FIT"},
		minSize = vec(10,10),
		text = entry.icon,
		wrapText = false,
		toggle=true
	}
	local macro = require("scripthost.windows."..entry.path)
	entry.macro = macro
	---@cast btn GNUI.Widget.Button
	
	btn.BUTTON_DOWN:register(function ()
		entry.macro:setActive(true,screen,GNUI)
	end)
	
	btn.BUTTON_UP:register(function ()
		entry.macro:setActive(false,screen,GNUI)
	end)
	
	btn.tooltipText = entry.name
end




screen.SIZE_CHANGED:register(function (size)
	toolbar:setPos(
		size.x * 0.5 - 91.25,
		size.y - 55.1
	)
end)
