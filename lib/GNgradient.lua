--[[______   __
  / ____/ | / / Name: GN GRADIENT LIBRARY v1.2.0
 / / __/  |/ /  Desc: A library for anything color gradients.
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- GNcommon > https://github.com/lua-gods/GNs-Avatar-5/blob/future/lib/GNcommon.lua
]]

local gncommon = require("./GNcommon")

---@class GN.GradientAPI
local GradientAPI = {}


---@class GN.Gradient
---@field colors Vector3[]
---@field positions number[]
---@field range number
local Gradient = {}
Gradient.__index = Gradient
Gradient.__type = "GN.Gradient"


---Creates a new gradient.
---@param data table<number, Vector3|string>?
---@return GN.Gradient
function GradientAPI.new(data)
	---@type GN.Gradient
	local self = {
		colors = {},
		positions = {},
		range = 1,
	}
	setmetatable(self, Gradient)
	for pos, color in pairs(data) do
		self:addPoint(pos, color)
	end
	return self
end


---Unpacks a gradient from a packed gradient string.
---@param packedGradient string
---@return GN.Gradient
function GradientAPI.unpack(packedGradient)
	local self = GradientAPI.new()
	local buffer = data:createBuffer(#packedGradient * 5)
	buffer:writeByteArray(packedGradient)
	buffer:setPosition(0)
	local count = buffer:readInt()
	for i = 1, count, 1 do
		local pos = buffer:readFloat()
		local r = buffer:read() / 255
		local g = buffer:read() / 255
		local b = buffer:read() / 255
		self:addPoint(pos, vec(r, g, b))
	end
	buffer:close()
	return self
end


---Adds a point to the gradient at a given position and color.
---@param pos number
---@param color Vector3|string?
function Gradient:addPoint(pos, color)
	if not color then
		color = self:sample(pos)
	else
		local t = type(color)
		if t == "string" then color = vectors.hexToRGB(color) end
	end
	local found = false
	local poses = self.positions
	for i = 1, #self.colors do
		if poses[i] > pos then
			table.insert(self.colors, i, color)
			table.insert(self.positions, i, pos)
			found = true
			break
		end
	end
	if not found then
		self.colors[#self.colors + 1] = color
		self.positions[#self.positions + 1] = pos
	end
	self.range = self.positions[#self.positions]
	return self
end


---Sets the color of the point with the given ID in the gradient.
---@param id integer
---@param clr Color
---@return GN.Gradient
function Gradient:setColor(id, clr)
	self.colors[id] = gncommon.color(clr).xyz
	return self
end


---Sets the position of the point with the given ID in the gradient.
---@param id integer
---@param pos number
---@return GN.Gradient
function Gradient:setPos(id, pos)
	self.positions[id] = pos
	return self
end


---Removes a point in the gradient.
---@param id number
---@return GN.Gradient
function Gradient:removePoint(id)
	table.remove(self.colors, id)
	table.remove(self.positions, id)
	self.range = self.positions[#self.positions]
	return self
end


---Returns the id of the point in the gradient.
---@param pos any
---@return integer
function Gradient:getPointID(pos)
	local positions = self.positions
	local colors = self.colors
	for i = 1, #self.colors, 1 do
		if positions[i] < pos then
			return i
		end
	end
	return -1
end


---Moves a point in the gradient.
---@param id number
---@param to number
---@return GN.Gradient
function Gradient:movePoint(id, to)
	local color = self.colors[id]
	self:removePoint(id)
	self:addPoint(to, color)
	return self
end


---Returns a color from the gradient in the given position.
---@param pos number
---@return Vector3
function Gradient:sample(pos)
	pos = math.clamp(pos, 0, self.range)
	local positions = self.positions
	local colors = self.colors
	for i = 1, #self.colors, 1 do
		if positions[i] >= pos then
			local j = (i - 2) % #colors + 1
			local colorA = colors[j]
			local colorB = colors[i]
			local posA = positions[j]
			local posB = positions[i]
			local t = math.map(pos, posA, posB, 0, 1)
---@diagnostic disable-next-line: return-type-mismatch
			return math.lerp(colorA, colorB, t)
		end
	end
	return vec(0, 0, 0)
end


---Returns a color from the gradient in the given position. from a range of 0 to 1.
---@param pos number
---@return Vector3
function Gradient:sampleRange(pos)
	return self:sample(pos * self.range)
end


--────────────────────────-< Compression >-────────────────────────--

--- Packs the gradient into a string, can be unpacked via `GradientAPI.unpack`.  
--- This is useful for sending gradients over pings.
---@return string
function Gradient:pack()
	local count = #self.colors
	local buffer = data:createBuffer(count * 5)
	buffer:writeInt(count)
	for i = 1, count, 1 do
		local pos = self.positions[i]
		local color = self.colors[i]
		buffer:writeFloat(pos)
		buffer:write(math.clamp(math.floor(color.x * 255), 0, 255))
		buffer:write(math.clamp(math.floor(color.y * 255), 0, 255))
		buffer:write(math.clamp(math.floor(color.z * 255), 0, 255))
	end
	local len = buffer:getPosition()
	buffer:setPosition(0)
	local out = buffer:readByteArray(len)
	buffer:close()
	return out
end

return GradientAPI
