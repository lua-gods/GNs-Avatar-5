
--[ [ <- separate to enable

local core = listFiles("core")
table.sort(core)
for _, path in ipairs(core) do
	require(path)
end

for _, path in ipairs(listFiles("class")) do
	require(path)
end


for _, path in ipairs(listFiles("auto")) do
	require(path)
end

--]]