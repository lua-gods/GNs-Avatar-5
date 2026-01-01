local gncommon = require("lib.gncommon") ---@type GNCommon

---@class GNUI.BoxAPI
local BoxAPI = {}

---@alias FitMode string
---| "FIXED"
---| "FIT"
---| "FILL"


---@alias GNUI.Box.LayoutMode string?
---| "VERTICAL"
---| "HORIZONTAL"
---| nil


---@class GNUI.Box
---
---@field pos Vector2
---@field size Vector2
---@field sizeFit {x:FitMode,y:FitMode}
---@field minSize Vector2
---@field maxSize Vector2
---
---@field layout GNUI.Box.LayoutMode?
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
---
---@field sprite GNUI.Sprite?
---@field canvas GNUI.Canvas
local Box = {}
Box.__index = Box
Box.__style = "box"

function BoxAPI.index(i)
	return Box[i]
end


local queueUpdate = {}


local nextFree = 1

---Creates a new box, the fundemental primitive element of GNUI.
---@param canvas GNUI.Canvas
---@return GNUI.Box
function BoxAPI.new(canvas)
	local self = {
		pos = vec(0,0),
		size = vec(-1,-1),
		minSize = vec(0,0),
		maxSize = vec(0,0),
		
		layout = "HORIZONTAL",
		
		bakedPos = vec(0,0),
		bakedSize = vec(0,0),
		bakedDim = vec(0,0,0,0),
		
		parent = nil,
		childIndex = 0,
		children = {},
		childAlign = vec(0,0),
		
		id = nextFree,
		visible = true,
		
		canvas = canvas,
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
	self.pos = gncommon.vec2(x,y)
	return self
end


---@return Vector2
function Box:getPos()
	return self.pos
end


---Sets the size of the box  
---NOTE: setting an axis to -1 will make it automatically fit that given axis.
---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	self.size = gncommon.vec2(x,y)
	self:update()
	return self
end


---@return Vector2
function Box:getSize()
	return self.size
end


---@generic self
---@param self self
---@return self
---@param layout GNUI.Box.LayoutMode
function Box:setLayout(layout)
	---@cast self GNUI.Box
	self.layout = layout
	self:update()
	return self
end


---@generic self
---@param self self
---@return self
---@param sprite GNUI.Sprite
function Box:setSprite(sprite)
	---@cast self GNUI.Box
	if self.sprite then
		self.sprite:setBox(self)
	end
	self.sprite = sprite
	return self
end


--────────────────────────-< Children Management >-────────────────────────--

local function updateChildrenIndexes(box)
	for index, child in ipairs(box.children) do
		child.childIndex = index
		updateChildrenIndexes(child)
	end
end


---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Box:addChild(box)
	---@cast self GNUI.Box
	box.parent = self
	local nextFree = #self.children + 1
	self.children[nextFree] = box
	box.childIndex = nextFree
	
	self:update()
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
	self:update()
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


--────────────────────────-< UPDATERS >-────────────────────────--
function BoxAPI.flushUpdates()
	for index, box in pairs(queueUpdate) do
		box:forceUpdate()
	end
	queueUpdate = {}
end


function Box:update()
	queueUpdate[self.id] = self
end


---Forces this element to update
---@generic self
---@param self self
---@return self
function Box:forceUpdate()
	---@cast self GNUI.Box
	self:calculateSize(false)
	self:calculateSize(true)
	
	if self.sprite then
		local sprite = self.sprite
		sprite:setPos(self.bakedPos)
		sprite:setSize(self.bakedSize)
	end
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:calculateSize(other)
	local a = (other and "y" or "x")
	---@cast self GNUI.Box
	if self.size[a] == -1 and self.layout then
		if (self.layout == (other and "VERTICAL" or "HORIZONTAL")) then
			local totalSize = 0
			for _, child in ipairs(self.children) do
				child:calculateSize(other)
				totalSize = totalSize + child.bakedSize[a]
			end
			self.bakedSize[a] = totalSize
		else
			local max = -math.huge
			for _, child in ipairs(self.children) do
				child:calculateSize(other)
				max = math.max(max, child.bakedSize[a])
			end
			self.bakedSize[a] = max
		end
	else
		self.bakedSize[a] = self.size[a]
	end
	return self
end


return BoxAPI