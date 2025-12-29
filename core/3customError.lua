---@diagnostic disable: undefined-field
local BetterErrorAPI = require("lib.betterError")

if events.ERROR then
	events.ERROR:register(function (error)
		local json = BetterErrorAPI.parseError(error)
		printJson(toJson(json))
		goofy:stopAvatar()
		return true
	end)
end

local stopAvatar = error
function error(error,level)
	local ok, result = pcall(function() stopAvatar(error, 4) end)
	if not ok then
		local json = BetterErrorAPI.parseError(result)
		printJson(toJson(json))
		host:setClipboard(toJson(json))
		if goofy then
			goofy:stopAvatar()
		else
			printJson('{"text":"\n"}')
			stopAvatar("...",99)
		end
	end
end