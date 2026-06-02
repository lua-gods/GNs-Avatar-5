--[[______   __
  / ____/ | / / Name: GN SPARSE SET LIBRARY v1.0.0
 / / __/  |/ /  Desc: an implementation of a sparse set in lua
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: MIT License

--──── REFERENCES ────────────────────────────────────────────--
stuff I used to make this
- The magic container                - https://www.youtube.com/watch?v=L4xOCvELWlU
- Sparse Set                         - https://www.geeksforgeeks.org/dsa/sparse-set/
- Sparse Sets and Where to Find Them - https://timiskhakov.github.io/posts/sparse-sets-and-where-to-find-them/
- A Sparse Set in rust.              - https://github.com/bombela/sparseset
]]


local DEFAULT_SET_INSORTED_COMPARE = function(a, b) return a > b end


---@type table<table,SparseSet>
local tableProps = {}


---@class SparseSet
---@field package data any[]
---@field package toData integer[] -- lookup id for data
---@field package toIndex integer[] -- lookup data for id
---@field package indexSize integer
---@field package dataSize integer
local SparseSet = {}
SparseSet.__index = function(table, index)
	return SparseSet[index] or table:get(index)
end
SparseSet.__newIndex = function(table, index, value)
	if type(index) == "nil" then
		table:remove(index)
	else
		table:set(index, value)
	end
end





---@param index integer
---@return any
function SparseSet:get(index)
	local props = tableProps[self]
	return props.data[props.toData[index]]
end

function SparseSet:getById(id)
	local props = tableProps[self]
	return props.data[id]
end

function SparseSet:getId(index)
	local props = tableProps[self]
	return props.toIndex[index]
end

---@param index integer
---@param data any
function SparseSet:set(index, data)
	local props = tableProps[self]
	if index <= props.dataSize then
		props.data[props.toData[index]] = data
	else
		local indexSize = props.indexSize
		props.toData[indexSize + 1] = index
		props.toIndex[indexSize + 1] = index
		props.data[indexSize + 1] = data
		props.dataSize = indexSize + 1
	end
end

function SparseSet:insert(index, data)
	local props = tableProps[self]

	-- append the data physically
	local denseIndex = props.dataSize + 1
	props.data[denseIndex] = data
	props.dataSize = denseIndex
	props.indexSize = denseIndex
	props.toData[denseIndex] = denseIndex
	props.toIndex[denseIndex] = denseIndex

	-- shift pointers from the end down to index to open a gap
	for i = denseIndex, index + 1, -1 do
		self:swap(i, i - 1)
	end
end

local function swapEntries(table, id1, id2)
	table[id1], table[id2] = table[id2], table[id1]
end


---@param index1 integer
---@param index2 integer
local function swapData(props, index1, index2)
	local realIndex1 = props.toData[index1]
	local realIndex2 = props.toData[index2]

	-- swap with the last element
	swapEntries(props.data, realIndex1, realIndex2)
	swapEntries(props.toIndex, realIndex1, realIndex2)

	realIndex1, realIndex2 = realIndex2, realIndex1

	props.toData[props.toIndex[realIndex1]] = realIndex1
	props.toData[props.toIndex[realIndex2]] = realIndex2
end


function SparseSet:swap(index1, index2)
	local props = tableProps[self]
	local realIndex1 = props.toData[index1]
	local realIndex2 = props.toData[index2]

	props.toData[index1] = realIndex2
	props.toData[index2] = realIndex1

	props.toIndex[realIndex1] = index2
	props.toIndex[realIndex2] = index1
end

---@param index integer
function SparseSet:remove(index)
	local props = tableProps[self]
	if props.dataSize > 0 then
		local size = props.dataSize

		-- swap with the last element in the data
		swapData(props, index, props.toIndex[size])
		props.data[size] = nil
		props.dataSize = size - 1
	end
end

---@param data any
function SparseSet:append(data)
	local props = tableProps[self]
	local id = props.dataSize + 1
	props.data[id] = data
	props.dataSize = id

	-- if indexSize is not enough
	if props.indexSize < props.dataSize then
		local size = props.dataSize
		props.toData[size] = size
		props.toIndex[size] = size
		return size
	end
	return id
end

---@param data any
---@param check (fun(a:any,b:any):boolean)?  -- returns true if a should come BEFORE b
function SparseSet:insertSorted(data, check)
	check = check or function(a, b) return a < b end

	local props = tableProps[self]
	local low = 1
	local high = props.dataSize

	while low <= high do
		local mid = math.floor((low + high) / 2)
		if check(data, props.data[props.toData[mid]]) then
			high = mid - 1
		else
			low = mid + 1
		end
	end

	self:insert(low, data)
end

---@param props SparseSet
---@param index integer
local function next(props, index)
	index = (index or 0) + 1
	local data = props.data[props.toData[index]]
	if data then
		return index, data
	end
end


function SparseSet:pairs()
	return next, tableProps[self]
end

function SparseSet:print()
	local props = tableProps[self]
	print("toData ", table.concat(props.toData, " "))
	print("toIndex", table.concat(props.toIndex, " "))
	print("data   ", table.concat(props.data, " "))
	print()
end

local SparseSetAPI = {}



---@return SparseSet
function SparseSetAPI.new(set)
	set = set or {}
	local proxyTable = {}
	local toData = {}
	local toIndex = {}
	local size = #set
	local self = {
		toData    = toData,
		toIndex   = toIndex,
		data      = set,
		dataSize  = size,
		indexSize = size,
	}
	for i = 1, size, 1 do
		toData[i] = i
		toIndex[i] = i
	end

	tableProps[proxyTable] = self
	setmetatable(proxyTable, SparseSet)
	return proxyTable
end

return SparseSetAPI
