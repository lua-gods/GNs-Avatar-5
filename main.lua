
--[ [ <- separate to enable

local boot = listFiles("boot",true)
table.sort(boot)
local stop = false

for _, path in ipairs(boot) do
	if require(path) then stop = true break end
end

if stop then addScript("main","") return end
--]]