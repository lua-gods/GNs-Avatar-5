local gncommon = require("../../gncommon") ---@type GNCommon
local utils = require("../utils") ---@type GNUI.utils

---@class GNUI.BoxAPI
local BoxAPI = {}


---@alias GNUI.Box.SizingMode string
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
---@field sizing {x:GNUI.Box.SizingMode,y:GNUI.Box.SizingMode}
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
---@field namedChildren table<string,GNUI.Box>
---@field childAlign Vector2
---
---@field visible boolean
---@field id integer
---
---@field text string
---@field wrapText boolean
---
---@field flaggedUpdate boolean
---@field sprite GNUI.Sprite?
---@field canvas GNUI.Canvas
---@field [string] GNUI.Box
local Box = {}
Box.__index = function (t,i)
	return rawget(t,i) or Box[i] or rawget(t,"children")[i] or rawget(t,"namedChildren")[i]
end
Box.__style = "box"

function BoxAPI.index(i)
	return Box[i]
end


local nextFree = 1

---Creates a new box, the fundemental primitive element of GNUI.
---@param canvas GNUI.Canvas
---@return GNUI.Box
function BoxAPI.new(canvas)
	local self = {
		pos = vec(0,0),
		
		sizing = {x="FIT",y="FIT"},
		size = vec(-1,-1),
		minSize = vec(0,0),
		maxSize = vec(math.huge,math.huge),
		
		layout = "HORIZONTAL",
		
		bakedPos = vec(0,0),
		bakedSize = vec(0,0),
		
		parent = nil,
		childIndex = 0,
		children = {},
		namedChildren = {},
		childAlign = vec(0,0),
		
		id = nextFree,
		visible = true,
		
		canvas = canvas,
	}
	nextFree = nextFree + 1
	
	setmetatable(self, Box)
	return self
end


---@param name string
---@return GNUI.Box
function Box:setName(name)
	if self.parent then
		self.parent.namedChildren[name] = self
	end
	self.name = name
	return self
end


---Sets the position of the box,
---note that position only applies if the parent box dosent automatically handle it
---@overload fun(self: GNUI.Box ,pos : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setPos(x,y)
	---@cast self GNUI.Box
	self.pos = gncommon.vec2(x,y,self.pos)
	self:update()
	return self
end


---@return Vector2
function Box:getPos()
	return self.pos
end


---Sets the size of the box  
---NOTE: setting an axis to -1 will make it automatically fit that given axis.
---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	local size = gncommon.vec2(x,y,self.size)
	self.size = size
	self:update()
	return self
end


---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setMinimumSize(x,y)
	---@cast self GNUI.Box
	self.minSize = gncommon.vec2(x,y,self.minSize)
	self:update()
	return self
end


---@return Vector2
function Box:getMinimumSize()
	return self.minSize
end


---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setMaximumSize(x,y)
	---@cast self GNUI.Box
	self.maxSize = gncommon.vec2(x,y,self.maxSize)
	self:update()
	return self
end


---@return Vector2
function Box:getMaximumSize()
	return self.maxSize
end


---@generic self
---@param self self
---@return self
---@param x GNUI.Box.SizingMode?
---@param y GNUI.Box.SizingMode?
function Box:setSizing(x,y)
	---@cast self GNUI.Box
	self.sizing = {x=x or self.sizing.x,y=y or self.sizing.y}
	return self
end


---@return Vector2
function Box:getSize()
	return vec(
		math.clamp(self.size.x,self.minSize.x,self.maxSize.x),
		math.clamp(self.size.y,self.minSize.y,self.maxSize.y)
	)
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
		
		for index, value in ipairs(self.children) do
			if value.sprite then
				value.sprite:setParent(self.sprite.id, index)
			end
		end
	end
	self.sprite = sprite
	self:update()
	return self
end


--────────────────────────-< Children Management >-────────────────────────--

---@param box GNUI.Box
local function updateChildrenIndexes(box)
	for id, child in ipairs(box.children) do
		child.childIndex = id
		if child and child.sprite and box.sprite then
			child.canvas.render:setIndex(child.sprite.id, id)
		end
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
	local id = #self.children + 1
	self.children[id] = box
	box.childIndex = id
	
	if box.name then
		self.namedChildren[box.name] = box
	end
	
	if box and box.sprite and self.sprite then
		box.sprite:setParent(self.sprite.id, id)
	end
	
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
		
		if box.name then
			box.namedChildren[box.name] = nil
		end
		
		updateChildrenIndexes(self)
		box.parent = nil
	end
	self:update()
	return self
end


---@param name string
---@return GNUI.Box?
function Box:getChild(name)
	if tonumber(name) then
		return self.children[name]
	else
		for index, child in ipairs(self.children) do
			if child.name == name then
				return child
			end
		end
	end
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


---Returns the parent of the box
---@return GNUI.Box?
function Box:getParent()
	return self.parent
end


---@generic self
---@param self self
---@return self
---@param text string
function Box:setText(text)
	---@cast self GNUI.Box
	self.text = text
	if self.sprite then
		self.sprite:setText(text)
	end
	return self
end


---sets if the text should wrap around or not
---@generic self
---@param self self
---@return self
---@param wrap boolean
function Box:setWrapText(wrap)
	---@cast self GNUI.Box
	self.wrapText = wrap
	return self
end


--────────────────────────-< UPDATERS >-────────────────────────--


---Updates itself and its relatives that will get affected
function Box:update()
	self:updateItself()
end


function Box:updateItself()
	if not self.flaggedUpdate then
		self.flaggedUpdate = true
		if self.canvas then
			self.canvas.queueUpdate[self.id] = self
		end
	end
end

function Box:updateSprites()
	if self.sprite then
		local sprite = self.sprite
		sprite:setPos(self.bakedPos)
		sprite:setSize(self.bakedSize)
	end
	for _, child in ipairs(self.children) do
		child:updateSprites()
	end
end

---Forces this element to update
---@generic self
---@param self self
---@return self
function Box:forceUpdate()
	---@cast self GNUI.Box
	self
	
	:solveForFitSizing(false)
	:sovleForFillSizing(false)
	:sovleForLayout(false)
	
	:solveForFitSizing(true)
	:sovleForFillSizing(true)
	:sovleForLayout(true)
	
	
	:updateSprites()
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:solveForFitSizing(other)
	local x = (other and "y" or "x")
	---@cast self GNUI.Box
	
	for _, child in ipairs(self.children) do
		child:solveForFitSizing(other)
	end
	
	local textSize = self.text and utils.getTextSize(self.text, x == "y" and self.bakedSize.x or 0, self.wrapText) or vec(0,0)
	if self.sizing[x] == "FIXED" then
		self.bakedSize[x] = math.max(self.minSize[x],self.size[x])
	
	elseif self.sizing[x] == "FIT" then
		if (self.layout == (other and "VERTICAL" or "HORIZONTAL")) then -- is parallel
			local totalSize = 0
			for _, child in ipairs(self.children) do
				totalSize = totalSize + child.bakedSize[x]
			end
			self.bakedSize[x] = math.max(self.minSize[x],totalSize,textSize[x])
		
		else
			local minSize = self.minSize[x]
			for _, child in ipairs(self.children) do
				minSize = math.max(minSize,child.bakedSize[x])
			end
			self.bakedSize[x] = math.max(minSize,textSize[x])
		end
	
	elseif self.sizing[x] == "FILL" then
		self.bakedSize[x] = math.max(self.minSize[x], 0)
	end
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:sovleForFillSizing(other)
	---@cast self GNUI.Box
	local x = (other and "y" or "x")
	local remainingSpace = self.bakedSize[x]
	
	local parallel = self.layout == (other and "VERTICAL" or "HORIZONTAL")
	local fillers = {} ---@type GNUI.Box[]
	local fitters = {} ---@type GNUI.Box[]
	
	if parallel then
		for _, child in ipairs(self.children) do
			if child.sizing[x] == "FILL"then
				fillers[#fillers+1] = child
			elseif child.sizing[x] == "FIT" then
				fitters[#fitters+1] = child
			end
			remainingSpace = remainingSpace - child.bakedSize[x]
		end
		
		if #fillers > 0 then
			for i = 1, 10, 1 do
				if remainingSpace < 0.01 then break end
				local smallest = fillers[1]
				local secondSmallest = fillers[1]
				local spaceToAdd = remainingSpace
				
				for _, child in pairs(fillers) do
					-- find the smallest and 2nd smallest child
					if child.bakedSize[x] < smallest.bakedSize[x] then
						secondSmallest = smallest
						smallest = child
					end
					
					-- set space to add to the difference between the smallest to the 2nd smallest
					if child.bakedSize[x] > smallest.bakedSize[x] then 
						secondSmallest.bakedSize[x] = math.max(secondSmallest.bakedSize[x], child.bakedSize[x])
						spaceToAdd = secondSmallest.bakedSize[x] - smallest.bakedSize[x]
					end
				end
				
				-- clamp the allowed space to expand to the remaining space divided to all fillers
				spaceToAdd = math.min(spaceToAdd, remainingSpace / #fillers)
				for _, child in pairs(fillers) do
					if child.bakedSize[x] == smallest.bakedSize[x] then
						child.bakedSize[x] = child.bakedSize[x] + spaceToAdd
						remainingSpace = remainingSpace - spaceToAdd
					end
				end
			end
		end
	else
		for _, child in pairs(self.children) do
			if child.sizing[x] == "FILL" then
				child.bakedSize[x] = math.max(self.bakedSize[x],child.bakedSize[x])
			end
		end
	end
	
	for _, child in ipairs(self.children) do
		child:sovleForFillSizing(other)
	end
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:sovleForLayout(other)
	---@cast self GNUI.Box
	local x = (other and "y" or "x")
	local y = (other and "x" or "y")
	if self.sizing[x] == "FIXED" and (not self.parent or (self.parent and not self.parent.layout)) then
		self.bakedPos[x] = self.pos[x]
		self.bakedSize[x] = self.size[x]
	end
	if self.layout then
		if self.layout == (other and "VERTICAL" or "HORIZONTAL") then
			local pos = 0
			for _, child in ipairs(self.children) do
				local childSize = child.bakedSize[x]
				child.bakedPos[x] = pos
				--child.bakedPos[y] = child.bakedPos[y]
				pos = pos + childSize
			end
		end
	end
	
	for _, child in ipairs(self.children) do
		child:sovleForLayout(other)
	end
	return self
end


return BoxAPI