local util = require("../../gnutil") ---@type GNUtil

---@class GNUI.BoxAPI
local BoxAPI = {}

---@alias FitMode string
---| "FIXED"
---| "FIT"
---| "FILL"



---@class GNUI.Box
---
---@field pos Vector2
---@field size Vector2
---@field sizeFit {x:FitMode,y:FitMode}
---@field minSize Vector2
---@field maxSize Vector2
---
---@field bakedPos Vector2
---@field bakedSize Vector2
---@field bakedDim Vector4
---
---@field parent GNUI.Box?
---@field childIndex integer
---@field children GNUI.Box[]
---@field childAlign Vector2
---
---@field visible boolean
---@field id integer
local Box = {}
Box.__index = Box


function BoxAPI.getIndex()
	return Box.__index
end

local nextFree = 1

---Creates a new box, the fundemental primitive element of GNUI.
---@return GNUI.Box
function BoxAPI.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		minSize = vec(0,0),
		maxSize = vec(0,0),
		
		bakedPos = vec(0,0),
		bakedSize = vec(0,0),
		bakedDim = vec(0,0,0,0),
		
		parent = nil,
		childIndex = 0,
		children = {},
		childAlign = vec(0,0),
		
		id = nextFree,
		visible = true
	}
	nextFree = nextFree + 1
	
	setmetatable(self, Box)
	return self
end


---Sets the position of the box,
---note that position only applies if the parent box dosent automatically handle it
---@overload fun(self: GNUI.Box ,pos : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setPos(x,y)
	---@cast self GNUI.Box
	self.pos = util.vec2(x,y)
	return self
end


---@return Vector2
function Box:getPos()
	return self.pos
end


---Sets the size of the box
---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	self.size = util.vec2(x,y)
	return self
end


---@return Vector2
function Box:getSize()
	return self.size
end


--────────────────────────-< Children Management >-────────────────────────--

local function updateChildrenIndexes(box)
	for index, child in ipairs(box.children) do
		child.childIndex = index
		updateChildrenIndexes(child)
	end
end


---@generic self
---@param self self
---@return self
function Box:addChild(box)
	---@cast self GNUI.Box
	box.parent = self
	local nextFree = #self.children + 1
	self.children[nextFree] = box
	box.childIndex = nextFree
	
	return box
end


---Removes a child from the box
---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Box:removeChild(box)
	---@cast self GNUI.Box
	local boxID = box.childIndex
	if self.children[boxID] == box then
		local box = self.children[boxID]
		table.remove(self.children, boxID)
		updateChildrenIndexes()
		box.parent = nil
	end
	return self
end


---Removes the parent of the box
---@generic self
---@param self self
---@return self
function Box:removeParent()
	---@cast self GNUI.Box
	if self.parent then
		self.parent:removeChild(self)
	end
	return self
end


---Sets the parent of the box
---@param parent GNUI.Box
---@return GNUI.Box
function Box:setParent(parent)
	self:removeParent()
	parent:addChild(self)
	return self
end


return BoxAPI