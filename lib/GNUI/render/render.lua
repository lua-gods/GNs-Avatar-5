---@class GNUI.RenderAPI
local RenderAPI = {}


---An abstract class for all the renderers for GNUI
---@class GNUI.RenderInstance
---@field canvas GNUI.Canvas
---@field visuals table<integer,table>
---@field model ModelPart
local Render = {}
Render.__index = Render


---@type GNUI.RenderInstance[]
local renders = {}

---Creates a new render instance
---@param canvas GNUI.Canvas
---@return GNUI.RenderInstance
function RenderAPI.new(canvas)
	local model = models:newPart("GNUIRenderer","SKULL")
	local self = {
		canvas = canvas,
		visuals = {},
		model = model
	}
	self.model:scale(-1,-1,1)
	renders[#renders+1] = self
	
	setmetatable(self, Render)
	return self
end


---@param box GNUI.Box
function Render:update(box,i)
	local size = box.bakedSize
	local pos = box.bakedPos
	local sprite = box.sprite
	--────────────────────────-< FIGURA SPECIFIC CODE >-────────────────────────--
	if sprite then
		local task = self.model:newBlock(box.id)
		task:block("minecraft:smooth_stone")
		:scale(size.x/16,size.y/16,1/16)
		:pos(pos.x,pos.y,-i)
	end
	--────────────────────────-< END OF FIGURA SPECIFIC CODE >-────────────────────────--
end

---@param box GNUI.Box
function Render:updateRecursive(box,i)
	i = i or 0
	for _, child in ipairs(box.children) do
		self:updateRecursive(child,i+1)
	end
	self:update(box,i)
end



function Render:updateAll()
	self:updateRecursive(self.canvas)
end


--────────────────────────-< Figura Specific Code >-────────────────────────--

---@class GNUI.Render.Visual
---@field render GNUI.RenderInstance
---@field id integer
---@field free fun()


function Render:free(id)
	self.visuals[id]:free()
	self.visuals[id] = nil
end


--────────────────────────-< Quad >-────────────────────────--

---@class GNUI.Render.Visual.Quad : GNUI.Render.Visual
---@field children integer[]
---@field texture_path string
---@field uv Vector4
---@field task SpriteTask
local VisualQuad = {}
VisualQuad.__index = VisualQuad


---@class GNUI.Render.Visual.Lines

---@class GNUI.Render.Visual.Polygon

---comment
---@param id integer
---@return GNUI.Render.Visual
function Render:newVisualQuad(id)
	local new = {
		type = "quad",
		render = self,
		id = id,
		children = {},
		task = self.model:newSprite("a"..id):setTexture(textures.avatar,20,20)
	}
	
	setmetatable(new, VisualQuad)
	self.visuals[id] = new
	return new
end


function VisualQuad:free()
	self.task:remove()
end


function VisualQuad:setPos(x,y)
	self.task:pos(x,y)
end


function VisualQuad:setSize(x,y)
	self.task:scale(x/20,y/20)
end


---@param path string
function VisualQuad:setTexture(path)
	self.texture_path = path
	assert(textures[path],"Texture "..path.." not found")
	self.task:texture(textures[path])
end


---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
function VisualQuad:setUV(u1,v1,u2,v2)
	self.uv = vec(u1,v1,u2,v2)
	self.task:setRegion()
end


function VisualQuad:setParent(parentID,index)
	local parent = self.render.visuals[parentID]
	self.parent = parent
	self.index = index
	parent.children[index] = self
end

return RenderAPI