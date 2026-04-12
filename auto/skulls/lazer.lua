local Skull = require("lib.skull")
local Color = require("lib.color")

local Line = require("lib.GNLine")

local COLOR = vectors.hexToRGB("#FF0000")
local THICKNESS = 2
local REACH_DISTANCE = 64
local MAX_BOUNCE = 30

local face2dir = {
   ["north"] = vec(1,1,-1),
   ["east"]  = vec(-1,1,1),
   ["south"] = vec(1,1,-1),
   ["west"]  = vec(-1,1,1),
   ["up"]    = vec(1,-1,1),
   ["down"]  = vec(1,-1,1),
}
local SCALE = 0.845

models.skull.lazer.hat:scale(SCALE,SCALE,SCALE)

---@type SkullIdentity|{}
local identity = {
	name = "Laser",
	id = "laser",
	modelBlock = models.skull.lazer.hat,
	modelHat = models.skull.lazer.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],1,0),
	modelEntity = models.skull.lazer.hat,
	
	processHat = {
		ON_READY = function (skull, model)
			
			-- pregenerate a line for every bounce
			skull.Lines = {}
			for i = 1, MAX_BOUNCE, 1 do
				local group = {
					Line.new():setWidth(THICKNESS*0.075):setColor(COLOR):setOpacity(0.1), -- red line
					Line.new():setWidth(THICKNESS*0.03):setColor(COLOR):setDepth(-0.005):setOpacity(0.5), -- red line
					Line.new():setWidth(THICKNESS*0.012):setColor(1,1,1):setDepth(-0.01) -- white line
				}
				skull.Lines[i] = group
			end
		end,
		ON_PROCESS = function (skull, model, delta)
			local dir = skull.entity:getLookDir()
			local pos = skull.entity:getPos(delta):add(0,skull.entity:getEyeHeight()+0.4)
			local points = {pos}
			
			-- gather the points
			for i = 1, MAX_BOUNCE, 1 do
				local to = pos + dir * REACH_DISTANCE
				local block,hit,side = raycast:block(pos,to)
				if (to-hit):length() > 0.1 then
					points[i+1] = hit
					pos = hit
					dir = dir * face2dir[side]
				else
					points[i+1] = to
					break
				end
			end
			
			for i = 1, MAX_BOUNCE, 1 do
				local group = skull.Lines[i]
				if points[i] and points[i+1] then
					for index, value in ipairs(group) do
						value:setAB(points[i], points[i+1]):setVisible(true)
					end
				else -- hide all lines afterwards
					for index, value in ipairs(group) do
						value:setVisible(false)
					end
				end
			end
		end,
		ON_EXIT = function (skull, model)
			for key, group in pairs(skull.Lines) do
				for index, value in ipairs(group) do
						value:free()
					end
			end
		end
	}
}

Skull.registerIdentity(identity)