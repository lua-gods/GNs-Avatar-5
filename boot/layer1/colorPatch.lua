
if client.compareVersions(client.getVersion(), "1.21.4") >= 0 then
	
	local ogTexture = figuraMetatables.Texture.__index
	local Texture = {}

	--ApplyFunc dosent seem to be affected

	function Texture:fill(x, y, width, height, color,g,b,a)
		local clr
		if g and b then
			clr = vec(b,g,color,a or 1)
		else
			clr = color * 1
         clr.xz = clr.zx
		end
		return ogTexture(self, "fill")(self,x, y, width, height, clr)
	end
	
	figuraMetatables.Texture.__index = function(self, index)
		return Texture[index] or ogTexture(self, index)
	end
	
	local ogRenderer = figuraMetatables.RendererAPI.__index
	local Renderer = {}
	
	function Renderer:setBlockOutlineColor(r,g,b)
		local clr
		if g and b then
			clr = vec(b,g,r)
		else
         clr = vec(r.w or 1,r.z,r.y,r.x)
		end
		return ogRenderer(self, "setBlockOutlineColor")(self,clr)
	end
	
	figuraMetatables.RendererAPI.__index = function(self, index)
		return Renderer[index] or ogRenderer(self, index)
	end
end
