if not host:isHost() then return end
local scripts = listFiles("scripthost")

for i, path in ipairs(scripts) do
	local content = getScript(path)
	require(path)
	addScript(path,nil,"NBT")
end

addScript(table.concat({...},"/"),nil)