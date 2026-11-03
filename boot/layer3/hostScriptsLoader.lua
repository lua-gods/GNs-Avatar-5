if not host:isHost() then
	return
end

local FILE_NAME = avatar:getName() .. ".cache"

local byte = string.byte
---@param str string
---@return string
local function checksum(str)
	local len = #str
	local h1, h2 = len, 2166136261
	local limit = len - 63
	for i = 1, limit, 64 do
		local b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36, b37, b38, b39, b40, b41, b42, b43, b44, b45, b46, b47, b48, b49, b50, b51, b52, b53, b54, b55, b56, b57, b58, b59, b60, b61, b62, b63, b64 =
			byte(str, i, i + 63)
		-- Combines 64 bytes with only 3 multiplications total:
		local chunk = (b1 + b5 + b9 + b13 + b17 + b21 + b25 + b29 + b33 + b37 + b41 + b45 + b49 + b53 + b57 + b61)
			+ (b2 + b6 + b10 + b14 + b18 + b22 + b26 + b30 + b34 + b38 + b42 + b46 + b50 + b54 + b58 + b62) * 256
			+ (b3 + b7 + b11 + b15 + b19 + b23 + b27 + b31 + b35 + b39 + b43 + b47 + b51 + b55 + b59 + b63) * 65536
			+ (b4 + b8 + b12 + b16 + b20 + b24 + b28 + b32 + b36 + b40 + b44 + b48 + b52 + b56 + b60 + b64) * 16777216
		h1 = (h1 * 65599 + chunk) % 4294967296
		h2 = (h2 + h1) % 4294967296 -- 0 multiplications!
	end
	for i = limit + 64, len do
		h1 = (h1 * 65599 + byte(str, i)) % 4294967296
		h2 = (h2 + h1) % 4294967296
	end
	return string.format("%08x%08x", h1, h2)
end

local directories = { "scripthost", "libhost" }

local paths = {}

do
	local i = 0
	for key, dir in pairs(directories) do
		for _, path in ipairs(listFiles(dir, true)) do
			i = i + 1
			paths[i] = path
		end
	end
end

config:setName(FILE_NAME)

if host:isAvatarUploaded() then
	local contents = config:load("content")
	local ok, entries = pcall(require, "checksums")
	if not ok then
		return
	end

	for path, checksum in pairs(entries) do
		local content = contents[path]
		if content then
			if checksum(content) == checksum then
				addScript(path, content, "RUNTIME")
			else
				warn("Checksum for " .. path .. " failed, file might be tampered")
			end
		else
			warn("Host Script " .. path .. " is missing")
		end
	end

	require("scripthost.gui") -- UI bootstrapper
	notify("Host scripts loaded from cache", "Host Cacher", ":open_file_folder_paper:")
else -- cache in local scripts
	local checksums = "return {"
	local contents = {}
	for _, path in pairs(paths) do
		local content = getScript(path)
		local checksum = checksum(content)

		contents[path] = content
		checksums = checksums .. '["' .. path .. '"]="' .. checksum .. '",'
	end

	checksums = checksums .. "}"
	addScript("checksums", checksums)
	config:save("content", contents)
	require("scripthost.gui") -- UI bootstrapper
	notify(#paths .. " Host scripts stored in cache", "Host Cacher", ":open_file_folder_paper:")
end