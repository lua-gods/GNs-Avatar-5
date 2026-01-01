local gncommon = require("lib.gncommon") ---@type GNCommon

---@diagnostic disable: param-type-mismatch
---@class GNUI.RenderAPI
local RenderAPI = {}


---An abstract class for all the renderers for GNUI
---@class GNUI.RenderInstance
---@field canvas GNUI.Canvas
---@field visuals table<integer,GNUI.Render.Visual.Quad>
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
	renders[#renders+1] = self
	
	setmetatable(self, Render)
	return self
end


-----@param box GNUI.Box
--	function Render:update(box,i)
--		local size = box.bakedSize
--		local pos = box.bakedPos
--		local sprite = box.sprite
--		--────────────────────────-< FIGURA SPECIFIC CODE >-────────────────────────--
--		if sprite then
--			local task = self.model:newBlock(box.id)
--			task:block("minecraft:glass")
--			:scale(size.x/16,size.y/16,1/16)
--			:pos(pos.x,pos.y,-i)
--		end
--		--────────────────────────-< END OF FIGURA SPECIFIC CODE >-────────────────────────--
--	end

--	---@param box GNUI.Box
--	function Render:updateRecursive(box,i)
--		i = i or 0
--		for _, child in ipairs(box.children) do
--			self:updateRecursive(child,i+1)
--		end
--		self:update(box,i)
--	end
--	
--	
--	
--	function Render:updateAll()
--		self:updateRecursive(self.canvas)
--	end


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
---@field children GNUI.Render.Visual[]
---@field texture_path string
---@field texture_size Vector2
---@field uv Vector4
---@field task SpriteTask


---@return integer
function Render:newQuadVisual()
	local id = #self.visuals+1
	local new = {
		type = "quad",
		render = self,
		id = id,
		children = {},
		task = self.model:newSprite("a"..id)
	}
	
	self.visuals[id] = new
	return id
end


---Frees the given visual
---
---Works for all visual types
---@param id integer
function Render:free(id)
	self.visuals[id].task:remove()
end


---Sets the position of the visual
---
---Works for all visual types
---@param id integer
---@param x number
---@param y number
function Render:setPos(id,x,y)
	self.visuals[id].task:pos(x,y)
end


---NOTE: Quad exclusive function
---
---Sets the size of the visual
---@param id integer
---@param x number
---@param y number
function Render:setSize(id,x,y)
	self.visuals[id].task:scale(x/20,y/20)
end


---NOTE: Quad exclusive function
---
---Sets the texture path of the visual
---@param path string
function Render:setTexture(id,path)
	assert(textures[path],"Texture "..path.." not found")
	local visual = self.visuals[id]
	local texture = textures[path]
	local textureSize = texture:getDimensions()
	local uv = vec(0,0,1,1)
	visual.texture_path = path
	visual.texture_size = textureSize
	visual.uv = uv
	visual.task:texture(textures[path],textureSize.x,textureSize.y)
	visual.task:setUV(uv.xy / visual.texture_size):setRegion(uv.zw * visual.texture_size)
end


---NOTE: Quad exclusive function
---
---Sets the UV of the visual
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
function Render:setUV(id,u1,v1,u2,v2)
	local visual = self.visuals[id]
	assert(visual,"Visual Quad "..id.." not found")
	local uv = gncommon.vec4(u1,v1,u2,v2)
	visual.uv = uv
	visual.task:setUV(uv.xy / visual.texture_size):setRegion(uv.zw * visual.texture_size)
end


---NOTE: For all parent types
---
---Sets the parent of the visual
---@param id integer
---@param parentID integer
---@param index integer
function Render:setParent(id,parentID,index)
	assert(self.visuals[id],"Visual Quad "..id.." not found")
	local quad = self.visuals[id]
	local parent = self.visuals[parentID]
	quad.parent = parent
	quad.index = index
	parent.children[index] = quad
end

return RenderAPI