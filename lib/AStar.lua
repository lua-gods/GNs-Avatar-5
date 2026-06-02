--[[______   __
  / ____/ | / / Name: GN A STAR PATHFIND LIBRARY v1.0.0
 / / __/  |/ /  Desc: a star pathfinding algorithm
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]

---@type Astar.SearchOption[]
local SEARCH_OPTIONS = {
	{ offset = vec(1, 0, 0), cost = 1 }, -- x+
	{ offset = vec(-1, 0, 0), cost = 1 }, -- x-
	{ offset = vec(0, 0, 1), cost = 1 }, -- z+
	{ offset = vec(0, 0, -1), cost = 1 }, -- z-
	
	{ offset = vec(1, 0, 1), cost = 1 }, -- x+ z+
	{ offset = vec(-1, 0, 1), cost = 1 }, -- x- z+
	{ offset = vec(1, 0, -1), cost = 1 }, -- x+ z-
	{ offset = vec(-1, 0, -1), cost = 1 }, -- x- z-
	
	{ offset = vec(1, 1, 0), cost = 1 }, -- x+
	{ offset = vec(-1, 1, 0), cost = 1 }, -- x-
	{ offset = vec(0, 1, 1), cost = 1 }, -- z+
	{ offset = vec(0, 1, -1), cost = 1 }, -- z-
	
	{ offset = vec(1, -1, 0), cost = 1 }, -- x+
	{ offset = vec(-1, -1, 0), cost = 1 }, -- x-
	{ offset = vec(0, -1, 1), cost = 1 }, -- z+
	{ offset = vec(0, -1, -1), cost = 1 }, -- z-
}



---@class Astar.Node
---@field pos Vector3
---@field Gcost number # distance from start
---@field Hcost number # distance from end
---@field Fcost number # Gcost + Hcost
---@field parent Astar.Node


---@class Astar.SearchOption
---@field offset Vector3
---@field cost number

---@class Astar.Path
---@field openNodes Astar.Node[]
---@field closeNodes Astar.Node[]
---@field start Vector3
---@field finish Vector3
local AstarPath = {}
AstarPath.__index = AstarPath


local hashPos = function(pos)
	return tostring(pos)
end

local DOWN = vec(0, 1, 0)

local function isTraversable(pos)
	local inBlock = world.getBlockState(pos)
	local onBlock = world.getBlockState(pos - DOWN)
	local inBLockAbove = world.getBlockState(pos + DOWN)
	
	if onBlock.id:find("carpet$") then
		onBlock = world.newBlock("minecraft:air")
	end
	if inBlock.id:find("carpet$") then
		inBlock = world.newBlock("minecraft:air")
	end
	
	return inBlock:isAir() and not onBlock:isAir() and inBLockAbove:isAir()
end

---@param from Vector2
---@param to Vector2
---@return Astar.Path
function AstarPath.new(from, to)
	local self = {
		openNodes = {},
		closeNodes = {},
		start = from,
		finish = to,
	}
	setmetatable(self, AstarPath)
	return self
end

---@param pos Vector3
---@param Gcost integer
---@param Hcost integer
---@param parent Astar.Node?
---@param active boolean?
---@return Astar.Node
function AstarPath:node(pos, Gcost, Hcost, parent, active)
	local node = {
		pos = pos,
		Gcost = Gcost,
		Hcost = Hcost,
		Fcost = Gcost + Hcost,
		parent = parent,
	}
	if active then
		self.openNodes[hashPos(pos)] = node
	else
		self.closeNodes[hashPos(pos)] = node
	end
	return node
end

local function point(pos, color)
	particles["end_rod"]:pos(pos + 0.5):scale(1):color(color):lifetime(0):spawn()
end

local AstarAPI = {}


local OFFSET = vec(0.5,0,0.5)
---@param node Astar.Node
local function getPath(node)
	local parent = node
	local path = {}
	while parent do
		path[#path+1] = parent.pos + OFFSET
		parent = parent.parent
	end
	return path
end


function AstarAPI.findPath(startPos, targetPos)
	local self = AstarPath.new(startPos, targetPos)
	local startNode = self:node(startPos, 0, (startPos-targetPos):length(), nil, true)
	local targetNode = self:node(targetPos, math.huge, math.huge, nil, true)
	
	local lFNode
	local closestNode
	local closedNodeCost = math.huge
	for i = 1, 120, 1 do
		lFNode = nil
		local lowestFCost = math.huge
		for key, node in pairs(self.openNodes) do
			if node.Fcost < lowestFCost then
				lFNode = node
				lowestFCost = node.Fcost
			end
			if node.Hcost < closedNodeCost then
				closestNode = node
				closedNodeCost = node.Hcost
			end
		end

		if not lFNode then return end
		
		self.openNodes[hashPos(lFNode.pos)] = nil
		self.closeNodes[hashPos(lFNode.pos)] = lFNode
		if lFNode.pos == targetPos then
			return getPath(lFNode)
		end

		for _, opt in ipairs(SEARCH_OPTIONS) do
			local to = lFNode.pos + opt.offset
			if isTraversable(to) and not self.closeNodes[hashPos(to)] then
				local distanceToTarget = (to - targetNode.pos):length()
				local potentialCost = lFNode.Gcost + opt.cost + distanceToTarget
				if potentialCost < lowestFCost or not self.openNodes[hashPos(to)] then
					self:node(to,
						lFNode.Gcost + opt.cost,
						distanceToTarget,
						lFNode, true)
					lowestFCost = potentialCost
				end
			end
		end
	end
	
	
	
	--for key, value in pairs(self.openNodes) do
	--	point(value.pos, vec(0, 0.8, 0))
	--end
	--for key, value in pairs(self.closeNodes) do
	--	point(value.pos, vec(1, 0, 0))
	--end
	
	--- draw a line from start to finish
	return getPath(closestNode)
end

return AstarAPI
