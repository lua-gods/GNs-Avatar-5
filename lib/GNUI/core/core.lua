local box = require("./box") ---@type GNUI.BoxAPI
local canvas = require("./canvas") ---@type GNUI.CanvasAPI

---Holds all instantiations for elements in GNUI
---and utility functions with them
---@class GNUI.CoreAPI
local CoreAPI = {}


function CoreAPI.flushUpdates()
	box.flushUpdates()
end
function CoreAPI.newBox() return box.new() end
function CoreAPI.newCanvas() return canvas.new() end

return CoreAPI