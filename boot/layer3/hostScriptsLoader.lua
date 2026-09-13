if not host:isHost() then return end

local CACHE_NAME = avatar:getName()..".cache"

local function makeUUID()
	local uuid = client.intUUIDToString(client.generateUUID())
	return uuid
end




local directories = {"scripthost","libhost"}

local paths = {}


do
	local i = 0
	for key, dir in pairs(directories) do
		for _, path in ipairs(listFiles(dir)) do
			i = i + 1
			paths[i] = path
		end
	end
end

config:setName(CACHE_NAME)

if host:isAvatarUploaded() then
	local contents = config:load("content")
	local foundKey = config:load("session")
	local thisKey = require("session")
	
	if thisKey ~= foundKey then
		warn("Tampered cache scripts detected, canceled loading")
		return
	end
	for path, content in pairs(contents) do
		addScript(path,content,"RUNTIME")
	end
	
	require("scripthost.gui")
	
	notify("Host scripts loaded from cache","Host Cacher",":open_file_folder_paper:")
else -- cache in local scripts
	
	local content = {}
	for _, path in pairs(paths) do
		content[path] = getScript(path)
	end
	local session = makeUUID()
	addScript("session","return \""..session.."\"")
	config:save("session",session)
	config:save("content",content)
	notify("Host scripts stored in cache","Host Cacher",":open_file_folder_paper:")
end