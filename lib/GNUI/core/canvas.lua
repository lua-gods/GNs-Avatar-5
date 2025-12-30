---@diagnostic disable: return-type-mismatch
local util = require("../../gnutil") ---@type GNUtil
local box = require("./box") ---@type GNUI.BoxAPI

---@class GNUI.CanvasAPI
local CanvasAPI = {}

---A root node for boxes
---@class GNUI.Canvas : GNUI.Box
local Canvas = {}
Canvas.__index = function (t,i)
	return rawget(t,i) or Canvas[i] or box.index(i)
end


---Creates a new canvas for boxes to attach to, this box is special, 
---as it acts as the root node of all boxes
---@return GNUI.Canvas
function CanvasAPI.new()
	local self = box.new()
	setmetatable(self,Canvas)
	return self
end


return CanvasAPI