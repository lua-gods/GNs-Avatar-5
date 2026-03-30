
local function hash(string)
	local hash = 0
	for i = 1, #string do
		local c = string:byte(i) * 513513
		hash = (hash * math.pi + c) % 513613615
	end
	return math.floor(hash)
end

local function getSession()
	local output = ""
	.. table.concat(client:getTabList().players)
	.. client:getServerBrand()
	return hash(output)
end

if false then SESSION_ID = 0 end


if host:isHost() then
	addScript("session","SESSION_ID = "..getSession(),"BOTH")
else
	require("session")
	if SESSION_ID ~= getSession() then
		pings = {}
	end
end