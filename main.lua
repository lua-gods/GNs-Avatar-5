
--[ [ <- separate to enable

local boot = listFiles("boot",true)
table.sort(boot)

for _, path in ipairs(boot) do
	require(path)
end
--]]