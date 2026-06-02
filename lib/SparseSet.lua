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

---@type table<table,SparseSet>
local tableProps = {}


---@class SparseSet
---@field package data any[]
---@field package toData integer[] -- lookup id for data
---@field package toIndex integer[] -- lookup data for id
---@field package indexSize integer
---@field package dataSize integer
local SparseSet = {}
SparseSet.__index = function (table,index)
	return SparseSet[index] or table:get(index)
end
SparseSet.__newIndex = function (table,index,value)
	if type(index) == "nil" then
		table:remove(index)
	else
		table:set(index,value)
	end
end


local function swap(table,id1,id2)
	table[id1],table[id2] = table[id2],table[id1]
end


---@param index integer
---@return any
function SparseSet:get(index)
	local props = tableProps[self]
	return props.data[props.toData[index]]
end


---@param index integer
---@param data any
function SparseSet:set(index,data)
	local props = tableProps[self]
	if index <= props.dataSize then
		props.data[props.toData[index]] = data
	else
		local indexSize = props.indexSize
		props.toData[indexSize+1] = index
		props.toIndex[indexSize+1] = index
		props.data[indexSize+1] = data
		props.dataSize = indexSize + 1
	end
end


function SparseSet:insert(index,data)
	local props = tableProps[self]
	local indexSize = props.indexSize
	props.toData[indexSize+1] = index
	props.toIndex[indexSize+1] = index
	props.data[indexSize+1] = data
end


---@param index1 integer
---@param index2 integer
function SparseSet:swap(index1,index2)
	local props = tableProps[self]
	local realIndex1 = props.toData[index1]
	local realIndex2 = props.toData[index2]
	
	-- swap with the last element
	swap(props.data,realIndex1,realIndex2)
	swap(props.toIndex,realIndex1,realIndex2)
	
	realIndex1,realIndex2 = realIndex2,realIndex1
	
	props.toData[props.toIndex[realIndex1]] = realIndex1
	props.toData[props.toIndex[realIndex2]] = realIndex2
end



---@param index integer
function SparseSet:remove(index)
	local props = tableProps[self]
	if props.dataSize > 0 then
		local size = props.dataSize
		
		-- swap with the last element in the data
		self:swap(index,props.toIndex[size])
		props.data[size] = nil
		props.dataSize = size - 1
	end
end


---@param data any
function SparseSet:append(data)
	local props = tableProps[self]
	props.data[props.dataSize+1] = data
	props.dataSize = props.dataSize + 1
	
	-- if indexSize is not enough
	if props.indexSize < props.dataSize then
		local size = props.dataSize
		props.toData[size] = size
		props.toIndex[size] = size
	end
end

---@param props SparseSet
---@param index integer
local function next(props,index)
	index = (index or 0) + 1
	local data = props.data[props.toData[index]]
	if data then
		return index,data
	end
end


function SparseSet:pairs()
	return next,tableProps[self]
end


function SparseSet:print()
	local props = tableProps[self]
	print("toData ",table.concat(props.toData," "))
	print("toIndex",table.concat(props.toIndex," "))
	print("data   ",table.concat(props.data," "))
	print()
end



local SparseSetAPI = {}



---@return SparseSet
function SparseSetAPI.new(set)
	local proxyTable = {}
	local toData = {}
	local toIndex = {}
	local self = {
		toData = toData,
		toIndex= toIndex,
		data   = set,
		dataSize = 0,
		indexSize = 0,
	}
	for i = 1, #set, 1 do
		toData[i] = i
		toIndex[i] = i
	end
	
	tableProps[proxyTable] = self
	setmetatable(proxyTable, SparseSet)
	return proxyTable
end

return SparseSetAPI