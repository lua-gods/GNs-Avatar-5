---@diagnostic disable: return-type-mismatch
local util = require("../../gnutil") ---@type GNUtil
local Box = require("./box") ---@type GNUI.BoxAPI
local config = require("../config") ---@type GNUI.config
local Render = require("../"..config.RENDER) ---@type GNUI.RenderAPI

---@class GNUI.CanvasAPI
local CanvasAPI = {}

---A root node for boxes
---@class GNUI.Canvas : GNUI.Box
---@field render GNUI.RenderInstance
local Canvas = {}
Canvas.__index = function (t,i)
	return rawget(t,i) or Canvas[i] or Box.index(i)
end


---Creates a new canvas for boxes to attach to, this box is special, 
---as it acts as the root node of all boxes
---@return GNUI.Canvas
function CanvasAPI.new()
---@diagnostic disable-next-line: missing-parameter its literally me!
	local self = Box.new()
	---@cast self GNUI.Canvas
	self.render = Render.new(self)
	setmetatable(self,Canvas)
	return self
end


return CanvasAPI