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

local ogError = error
function error(error,level)
	local ok, result = pcall(function() ogError(error, 4) end)
	if not ok then
		print(result)
		local json = BetterErrorAPI.parseError(result)
		printJson(toJson(json))
		host:setClipboard(toJson(json))
		if goofy then
			goofy:stopAvatar()
		else
			printJson('{"text":"\n"}')
			ogError("Install Goofy Plugin to stop this annoying part of the error message",99)
		end
	end
end