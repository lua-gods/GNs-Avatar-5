--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI TextField Class
/ /_/ / /|  /  desc: the text field widget for GNUI
\____/_/ |_/ source: link ]]


local BASE = ((...):gsub("/", ".")):match(".+%.GNUI")
local cfg = require(BASE .. ".config") ---@type GNUI.config
local Box = require(cfg.WIDGETS .. ".box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)
local Button = require(cfg.WIDGETS .. ".button") ---@type GNUI.Widget.ButtonAPI

local Theme = require(cfg.THEME .. ".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT .. ".init") ---@type GNUI.LayoutAPI

local utils = require(cfg.UTILS) ---@type GNUI.utils

---@class GNUI.WindowAPI
local WindowAPI = {}

---@class GNUI.Widget.Window : GNUI.Box
local Window = {}
Window.__index = function(t, i)
	return rawget(t, i)
		 or Window[i]
		 or Box.index(t, i)
end





---@param canvas GNUI.Canvas
---@return GNUI.Widget.Window
function WindowAPI.new(canvas)
	local self = Layout.parse(canvas, {
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
	close.BUTTON_DOWN:register(function()
		self:free()
	end)

	setmetatable(self, Window)
	---@cast self GNUI.Widget.Window
	return self
end

---@param child GNUI.Box
---@return GNUI.Widget.Window
function Window:addContent(child)
	self:getChild("content"):addChild(child)
	return self
end

function Window:setTitle(title)
	self:getChild("titlebar"):setText(title)
end

return WindowAPI
