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
--	{
--		name = "Macros [IMPLEMENT]",
--		path = "info",
--		icon = ":mcb_chain_command_block:",
--	},
--	{
--		name = "Camera Mode [IMPLEMENT]",
--		path = "orthographic",
--		icon = ":camera:",
--	},
--	
	{
		name = "Info Sheet",
		path = "info",
		icon = ":info:",
	},
	{gap=true},
	--	
	{
		name = "Color Picker",
		path = "colorize",
		icon = ":palette:",
	},
--	{
--		name = "UI Elements",
--		path = "colorize",
--		icon = ":mcb_white_stained_glass:",
--	},
	{gap=true},
--	
	{
		name = "File Importer",
		path = "file",
		icon = ":folder_paper:",
	},
--	{
--		name = "Notepad [IMPLEMENT]",
--		path = "colorize",
--		icon = ":mci_book_and_quill:",
--	},
--	{gap=true},
--	{
--		name = "Local Item Storage [IMPLEMENT]",
--		path = "colorize",
--		icon = ":mcb_chest:",
--	},
--	
	
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
			toggle=true,
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
		local macro = require("scripthost.toolbar." .. entry.path)
		entry.macro = macro
		---@cast btn GNUI.Widget.Button
	
		btn.BUTTON_DOWN:register(function()
			entry.macro:setActive(true, screen, GNUI, btn)
		end)
		
		btn.BUTTON_UP:register(function()
			entry.macro:setActive(false, screen, GNUI, btn)
		end)
		
		if false and entry.path == "info" then
			local i = 0
			local function e()
				i = i + 1
				if i > 4 then
					btn:press()
					events.TICK:remove(e)
				end
			end
			events.TICK:register(e)
		end
		
		btn.tooltipText = entry.name
	end
end

local function updateToolbar(mode)
	local size = screen:getFinalSize()
	toolbar:setPos(math.floor(size.x * 0.5 + 0.4) - 90, size.y - (mode and 53 or 35))
end

local c = 0
local lGamemode
events.TICK:register(function ()
	local gamemode = player:getGamemode()
	if lGamemode ~= gamemode or c < 10 then
		lGamemode = gamemode
		updateToolbar(gamemode ~= "CREATIVE")
	else
		c = c + 1
	end
	
end)

screen.SIZE_CHANGED:register(function(size)
	updateToolbar(false)
end)