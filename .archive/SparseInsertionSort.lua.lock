if not host:isHost() then return end
local SparseSet = require("lib.SparseSet")

local COUNT = 10

local setA = {}
local setRandom = {}
for i = 1, COUNT, 1 do
	setA[#setA+1] = i
end
for i = 1, #setA, 1 do
	local target = math.random(#setA)
	setRandom[#setRandom+1] = setA[target]
	table.remove(setA, target)
end

local sparse = SparseSet.new()

for i = 1, #setRandom, 1 do
	sparse:insertSorted(setRandom[i])
end
sparse:print()

print("ORDER")
for key, value in sparse:pairs() do
	print(value)
end



