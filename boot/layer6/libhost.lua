if not host:isHost() then return end
local scripts = listFiles("libhost",true)

for i, path in ipairs(scripts) do
	local content = getScript(path)
	addScript(path,nil,"NBT")
	addScript(path,content,"RUNTIME")
end

addScript(table.concat({...},"/"),nil)