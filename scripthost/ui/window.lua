--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI TextField Class
/ /_/ / /|  /  desc: the text field widget for GNUI
\____/_/ |_/ source: link ]]


local Event = require("lib.GNEvent")
local Box = require("libhost.GNUI.widgets.box")

---@class GNUI.WindowAPI
local WindowAPI = {}

---@class GNUI.Widget.Window : GNUI.Box
---@field ON_CLOSE GN.Event
local Window = {}
Window.__index = function(t, i)
	return rawget(t, i)
		 or Window[i]
		 or Box.index(t,i)
end





---@param canvas GNUI.Canvas
---@return GNUI.Widget.Window
function WindowAPI.new(canvas)
	local self = canvas:parse({
		layout = "VERTICAL",
		sizing = { "FIT", "FIT" },
		style="opaque",
		{
			{
				layout = "HORIZONTAL",
				style = "none",
				gap = 1,
				sizing = { "FILL", "FIT" },
				margin = vec(0, 0, 0, 0),
				{
					{
						type = "button",
						name = "titlebar",
						text = "title",
						sizing = { "FILL", "FIT" },
					},
					{
						type = "button",
						name = "close",
						text = "x",
						textOffset = vec(0,1),
						color=vec(1,0,0),
						minSize = vec(7,7),
						wrapText = false,
						sizing = { "FIT", "FIT" },
					},
				},
			},
			{
				name = "content",
				style = "none",
				sizing = { "FIT", "FIT" },
			},
		},
	})
	local titlebar = self:getChild("titlebar")
	---@cast titlebar GNUI.Widget.Button
	titlebar.BUTTON_DOWN:register(function()
		self.canvas.CURSOR_MOVED:register(function(pos, vel)
			self:setPos(self.pos + vel)
		end, titlebar.id)
	end)

	titlebar.BUTTON_UP:register(function()
		self.canvas.CURSOR_MOVED:remove(titlebar.id)
	end)

	local close = self:getChild("close")
	---@cast close GNUI.Widget.Button
	
	
	self.ON_CLOSE = Event.new()

	setmetatable(self, Window)
	---@cast self GNUI.Widget.Window
	
	close.PRESSED:register(function()
		self:close()
	end)
	
	return self
end

---@param child GNUI.Box
---@return GNUI.Widget.Window
function Window:addContent(child)
	self:getChild("content"):addChild(child)
	return self
end


function Window:close()
	self.ON_CLOSE:invoke()
	self.ON_CLOSE:clear()
	self:free()
end

function Window:setTitle(title)
	self:getChild("titlebar"):setText(title)
	return self
end

return WindowAPI
