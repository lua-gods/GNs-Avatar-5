

---@class GNUI.RenderAPI
local RenderAPI = {}


---An abstract class for all the renderers for GNUI
---@class GNUI.Render
---@field canvas GNUI.Canvas


---A Figura GNUI renderer
---@class GNUI.Render.Figura : GNUI.Render
---@field modelPart ModelPart
local Render = {}
Render.__index = Render


---@type GNUI.Render[]
local renders = {}

---Creates a new render instance of a
---@param data table|GNUI.Render
---@return GNUI.Render.Figura
function RenderAPI.new(data)
	local model = models:newPart("GNUIRenderer","SKULL")
	local self = {
		canvas = data.canvas,
		modelPart = model
	}
	self.modelPart:scale(-1,-1,1)
	renders[#renders+1] = self
	
	setmetatable(self, Render)
	return self
end


---@param box GNUI.Box
function Render:updateElement(box)
	local size = box.bakedSize
	local pos = box.bakedPos
	--────────────────────────-< FIGURA SPECIFIC CODE >-────────────────────────--
	local task = self.modelPart:newBlock(box.id)
	task:block("minecraft:dirt")
	:scale(size.x/16,size.y/16,1)
	:pos(pos.x,pos.y,0)
	--────────────────────────-< END OF FIGURA SPECIFIC CODE >-────────────────────────--
end


---@param box GNUI.Box
function Render:updateRecursive(box)
	self:updateElement(box)
	for index, child in ipairs(box.children) do
		self:updateRecursive(child)
	end
end



function Render:updateAll()
	self:updateRecursive(self.canvas)
end



return RenderAPI