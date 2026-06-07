--[[______   __
  / ____/ | / / Name: GN ASYNC PROCEDURAL TEXTURE LIBRARY v1.0.0
 / / __/  |/ /  Desc: makes procedural generation of textures slow and gradual with an effective approximation display
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
]]
--──── CONFIG ────────────────────────────────────────────--
-- replace 120 with the desired maximum frames per second before it stalls
local MAX_FPS = 2000/120
local MAX_REPETITION_COUNT = 10000

--──── END OF CONFIG ────────────────────────────────────────────--

---@class GN.ProceduralTextureAPI
local ProceduralTextureAPI = {}


---@class GN.ProceduralTexture
local ProceduralTexture = {}
ProceduralTexture.__index = ProceduralTexture


---@param texture Texture
---@param applyFunc fun(x:integer,y:integer,w:integer,h:integer):Vector4
function ProceduralTextureAPI:apply(texture,applyFunc)
	local rendererName = "ProceduralTexture"..texture:getName()
	if models[rendererName] then
		models[rendererName]:remove()
	end
	local width,height = texture:getDimensions():unpack()
	local step = 2^math.floor(math.log(math.max(width,height),2))
	local x,y = 0,0
	local odd = true
	local layer = 1
	
	local startTime = client:getSystemTime()
	models:newPart(rendererName,"WORLD")
	.midRender = function (_,_,part)
		startTime = client:getSystemTime()
		for i = 1, MAX_REPETITION_COUNT, 1 do
			texture:fill(
				x,
				y,
				math.min(x+step,width)-x,
				math.min(y+step,height)-y,
				applyFunc(x,y,width,height)
			)
			
			x = x + ((odd and layer > 1) and (step*2) or step)
			if x >= width then
				x = ((odd or layer == 1) and 0 or step)
				odd = not odd
				y = y + step
				if y >= height then
					y = 0
					step = step / 2
					layer = layer + 1
					x = step
					odd = true
					texture:update()
					if step < 1 then
						part:remove()
					end
				end
			end
			if (client:getSystemTime() - startTime) > MAX_FPS then
				break
			end
		end
	end
	return texture
end

---@param name string
---@param width integer
---@param height integer
---@param applyFunc fun(x:integer,y:integer,w:integer,h:integer):Vector4
function ProceduralTextureAPI:newTexture(name,width,height,applyFunc)
	local tex = textures:newTexture(name,width,height)
	ProceduralTextureAPI:apply(tex,applyFunc)
	return tex
end

return ProceduralTextureAPI