if not host:isHost() then return end

local FILE_NAME = avatar:getName()..".cache"

local byte = string.byte
---@param str string
---@return string
local function fastFullChecksum(str)
	local len = #str
	local h1, h2 = len, 2166136261
	local limit = len - 31

	-- 32 bytes processed per iteration
	for i = 1, limit, 32 do
		local b1, b2, b3, b4, b5, b6, b7, b8,
		b9, b10, b11, b12, b13, b14, b15, b16,
		b17, b18, b19, b20, b21, b22, b23, b24,
		b25, b26, b27, b28, b29, b30, b31, b32 =
			byte(str, i, i + 31)

		h1 = (
			h1 * 65599
			+ (b1 + b2 * 256 + b3 * 65536 + b4 * 16777216)
			+ (b5 + b6 * 256 + b7 * 65536 + b8 * 16777216)
			+ (b9 + b10 * 256 + b11 * 65536 + b12 * 16777216)
			+ (b13 + b14 * 256 + b15 * 65536 + b16 * 16777216)
		) % 0x100000000

		h2 = (
			h2 * 65599
			+ (b17 + b18 * 256 + b19 * 65536 + b20 * 16777216)
			+ (b21 + b22 * 256 + b23 * 65536 + b24 * 16777216)
			+ (b25 + b26 * 256 + b27 * 65536 + b28 * 16777216)
			+ (b29 + b30 * 256 + b31 * 65536 + b32 * 16777216)
		) % 0x100000000
	end

	-- Handle the remaining tail bytes (< 32 bytes)
	for i = limit + 32, len do
		h1 = (h1 * 65599 + byte(str, i)) % 0x100000000
	end

	return string.format("%08x%08x", h1, h2)
end



local directories = {"scripthost","libhost"}

local paths = {}


do
	local i = 0
	for key, dir in pairs(directories) do
		for _, path in ipairs(listFiles(dir,true)) do
			i = i + 1
			paths[i] = path
		end
	end
end

config:setName(FILE_NAME)

if host:isAvatarUploaded() then
	local contents = config:load("content")
	local ok, entries = pcall(require,"checksums")
	if not ok then return end
	
	
	for path, checksum in pairs(entries) do
		local content = contents[path]
		if fastFullChecksum(content) == checksum then
			addScript(path,content,"RUNTIME")
		else
			warn("Checksum for "..path.." failed, file might be tampered")
		end
	end
	
	require("scripthost.gui") -- UI bootstrapper
	notify("Host scripts loaded from cache","Host Cacher",":open_file_folder_paper:")
else -- cache in local scripts
	
	local checksums = "return {"
	local contents = {}
	for _, path in pairs(paths) do
		local content = getScript(path)
		local checksum = fastFullChecksum(content)
		
		contents[path] = content
		checksums = checksums..'["'..path..'"]="'..checksum..'",'
	end
	
	checksums = checksums .. "}"
	addScript("checksums",checksums)
	config:save("content",contents)
	require("scripthost.gui") -- UI bootstrapper
	notify((#paths).." Host scripts stored in cache","Host Cacher",":open_file_folder_paper:")
end