---@diagnostic disable: redundant-return-value

-- Dumps the error into `figura/data/error.log`

--[[<- separate to enable
function events.ERROR(msg)
	local write = file:openWriteStream("error.log")
	
	local time = client.getDate()
	local header = "[ERROR] " .. time.day .. "/" .. time.month .. "/" .. time.year .. " " .. time.hour .. ":" .. time.minute .. ":" .. time.second .. "\n" 
	for i = 1, #header, 1 do
		write:write(string.byte(header:sub(i, i)))
	end
	
	for i = 1, #msg, 1 do
		write:write(string.byte(msg:sub(i, i)))
	end
	write:close()
	return true
end
--]]