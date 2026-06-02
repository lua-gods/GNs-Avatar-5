local SparseSet = require("lib.SparseSet")

local COUNT = 10000

local setA = {}
local setB = {}
for i = 1, COUNT, 1 do
	setA[i] = "E"
	setB[i] = "E"
end


---@param fun fun()
local function benchmark(fun,prefix)
	local start = silly:getNanoTime()
	fun()
	local finish = silly:getNanoTime()
	local result = finish-start
	print(prefix.." : "..result.."ns")
	return result
end

local function compare(resultA,resultB)
	if resultB > resultA then
		local percentFaster = math.floor((resultB / resultA) * 100)
		print("Result: "..percentFaster.."% faster")
	else
		local percentFaster = math.floor((resultA / resultB) * 100)
		print("Result: "..percentFaster.."% slower")
	end
end


print("=== Removing "..COUNT.." elements ===")
local sparse = SparseSet.new(setA)

local resultA = benchmark(function ()
	for i = 1, COUNT, 1 do
		sparse:remove(1)
	end
end,"SparseSet")

local resultB = benchmark(function ()
	for i = 1, COUNT, 1 do
		table.remove(setB, 1)
	end
end,"Array    ")

compare(resultA, resultB)


print("=== Appending "..COUNT.." elements ===")
local sparse = SparseSet.new(setA)

local resultA = benchmark(function ()
	for i = 1, COUNT, 1 do
		sparse:append("E")
	end
end,"SparseSet")

local resultB = benchmark(function ()
	for i = 1, COUNT, 1 do
		table.insert(setB,"E")
	end
end,"Array    ")

compare(resultA, resultB)

print("=== Inserting element to id 1 "..COUNT.." times ===")
local sparse = SparseSet.new(setA)

local resultA = benchmark(function ()
	for i = 1, COUNT, 1 do
		sparse:insert("E")
	end
end,"SparseSet")

local resultB = benchmark(function ()
	for i = 1, COUNT, 1 do
		table.insert(setB,1,"E")
	end
end,"Array    ")

compare(resultA, resultB)


print("Getting random element "..COUNT.." times ===")
local sparse = SparseSet.new(setA)

local resultA = benchmark(function ()
	for i = 1, COUNT, 1 do
		sparse:get(math.random(COUNT))
	end
end,"SparseSet")

local resultB = benchmark(function ()
	for i = 1, COUNT, 1 do
		local a = setB[math.random(COUNT)]
	end
end,"Array    ")

compare(resultA, resultB)
