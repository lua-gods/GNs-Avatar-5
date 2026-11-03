local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()

if false then
	return
end
local SIZE = 12
local ICON_SCALE = 1
local GAP = 1

---@class Toolbar.Entry
---@field name string
---@field path string
---@field icon string
---@field shortcut Minecraft.keyCode?

---@type table<integer,Toolbar.Entry|{gap:true}>
local ENTRIES = {
	{
		name = "Macros [IMPLEMENT]",
		path = "orthographic",
		icon = ":mcb_chain_command_block:",
	},
	{
		name = "Camera Mode [IMPLEMENT]",
		path = "orthographic",
		icon = ":camera:",
	},
	
	{
		name = "Player Info [IMPLEMENT]",
		path = "orthographic",
		icon = ":mcm_steve:",
	},
	
	{
		name = "Server Info [IMPLEMENT]",
		path = "orthographic",
		icon = ":minecraft:",
	},
	{gap=true},
	
	{
		name = "Color Picker",
		path = "colorize",
		icon = ":palette:",
	},
	
	{
		name = "File Dialog [IMPLEMENT]",
		path = "orthographic",
		icon = ":folder_paper:",
	},
	{
		name = "Notepad [IMPLEMENT]",
		path = "orthographic",
		icon = ":mci_book_and_quill:",
	},
	{gap=true},
	{
		name = "Local Storage [IMPLEMENT]",
		path = "orthographic",
		icon = ":mcb_chest:",
	},
	
	
}

local toolbar = screen:parse({
	layout = "HORIZONTAL",
	pos = vec(5, 5),
	name = "toolbar",
	growDirection = vec(1, 1),
	sizing = { "FIT", "FIXED" },
	sizee = vec(0, SIZE),
})

for index, entry in ipairs(ENTRIES) do
	if entry.gap then
		toolbar:parse({
			sizing = { "FIXED", "FIXED" },
			size = vec(GAP, 0),
		})
	else
		local btn = toolbar:parse({
			--name = entry.name,
			type = "button",
			style = "secondary",
			sizing = { "FIXED", "FIXED" },
			size = vec(SIZE, SIZE),
			text = entry.icon,
			textAlign = vec(0, 0),
			textScale = ICON_SCALE,
			wrapText = false,
		})
	
		if false then
			btn:parse({
				style = "opaque",
				text = tostring(index),
				size = vec(9, 9),
				textAlign = vec(0, 0),
				pos = vec(math.floor(SIZE / 2 - 9 / 2),-9-2),
			})
		end
		local macro = require("scripthost.windows." .. entry.path)
		entry.macro = macro
		---@cast btn GNUI.Widget.Button
	
		btn.PRESSED:register(function()
			entry.macro:setActive(true, screen, GNUI)
		end)
	
		btn.tooltipText = entry.name
	end
end

local function updateToolbar(mode)
	local size = screen:getFinalSize()
	toolbar:setPos(size.x * 0.5 - 89.66, size.y - (mode and 53 or 35))
end

local lGamemode
events.TICK:register(function ()
	local gamemode = player:getGamemode()
	if lGamemode ~= gamemode then
		lGamemode = gamemode
		updateToolbar(gamemode ~= "CREATIVE")
	end
end)

screen.SIZE_CHANGED:register(function(size)
	updateToolbar(false)
end)
