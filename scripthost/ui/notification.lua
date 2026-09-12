---@diagnostic disable: param-type-mismatch
local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()
local tween = require("lib.GNtween")

local WIDTH = 130
local DURATION = 5
local MAX_WIDTH = 300

local area = screen:parse {
	layout = "VERTICAL",
	pos = vec(5, 5),
	size = vec(MAX_WIDTH, 0),
	sizing = { "FIXED", "FIT" },
	name = "notification",
	childAlign=vec(1,0)
}

---@class GN.Notification
---@field box GNUI.Box
local NotifAPI = {}
NotifAPI.__index = NotifAPI

function NotifAPI:setTitle(title)
	self.box:getChild("title"):setText(title)
end

---@param iconText string
---@return GN.Notification
function NotifAPI:setIcon(iconText)
	self.box:getChild("icon"):setText(iconText)
	return self
end

---@param message string
---@return GN.Notification
function NotifAPI:setMessage(message)
	self.box:getChild("message"):setText(message)
	return self
end

---@param message string
---@return GN.Notification
function NotifAPI:setMessage(message)
	self.box:getChild("message"):setText(message)
	return self
end

function NotifAPI:exit()
	tween.new {
		from = 0,
		to = WIDTH,
		duration = 0.2,
		easing = "inCubic",
		tick = function(v, t)
			self.box:setOffsetPos(v, 0)
		end,
		onFinish = function ()
			self.box:free()
		end
	}
end

---@param duration number?
---@return GN.Notification
function NotifAPI:timeout(duration)
	local middle = self.box:getChild("middle")
	
	local bar = middle:parse({
		style = "white",
		color = vectors.hexToRGB("#99e65f"),
		size = vec(0, 5000),
		sizing="FIXED",
	})
	
	tween.new {
		from = 1,
		to = 0,
		duration = duration or DURATION,
		tick = function(v, t)
			local width = middle:getFinalSize()
			---@diagnostic disable-next-line: param-type-mismatch
			bar:setSize(width.x * v, 1)
		end,
		onFinish = function()
			self:exit()
		end,
	}
	return self
end

---@param message string
---@param title string?
---@param icon string?
---@param manual boolean?
---@return GN.Notification
function notify(message, title, icon, manual)
	title = title or "Heads up"
	icon = icon or ":warning:"
	local notification = area:parse {
		layout = "VERTICAL",

		style = "opaque",
		sizing = { "FIT", "FIT" },
		minSize = vec(WIDTH,0),
		pos = vec(5, 5),
		{
			{
				layout = "HORIZONTAL",
				minSize=vec(WIDTH,0),
				sizing = { "FIT", "FIT" },
				{
					{
						type = "button",
						sizing = { "FIT", "FIT" },
						style = "secondary",
						text = icon,
						minSize = vec(7, 7),
						wrapText = false,
						name="icon"
					},
					{
						type = "button",
						style = "secondary",
						minSize = vec(WIDTH-7,0),
						textAlign = vec(-1, 0),
						sizing = { "FIT", "FIT" },
						text = title,
						wrapText = false,
						name="title"
					},
				},
			},
			{
				sizing = { "FILL", "FIT" },
				name = "middle",
			},
			{
				sizing = { "FILL", "FIT" },
				text = message,
				name="message",
				wrapText = true,
				padding = vec(1, 0, 1, 1),
			},
		},
	}
	
	local self = setmetatable({box=notification},NotifAPI)
	
	local middle = notification:getChild("middle")

	tween.new {
		from = WIDTH,
		to = 0,
		duration = 0.2,
		easing = "outCubic",
		tick = function(v, t)
			notification:setOffsetPos(v, 0)
		end,
	}

	if not manual then
		self:timeout()
	end
	
	return self
end

local height = 32

local function updateNotifPos()
	area:setPos(screen:getFinalSize().x-MAX_WIDTH,height)
end

-- wait for reload tooltip to disappear before moving to top right of the screen
tween.new {
	duration = 6,
	onFinish = function ()
		height = 0
		updateNotifPos()
	end
}

screen.SIZE_CHANGED:register(function (size)
	updateNotifPos()
end)