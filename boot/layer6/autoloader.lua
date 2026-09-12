
local coreCommons = require("boot.lib.coreCommons")
local notif = notify("Loading Scripts...","Avatar Loader",":loading:",true)
coreCommons.asyncLoadDir(listFiles("scripts",true),
function (path,ok)
	if host:isHost() then
		notif:setMessage("loading "..path)
	end
end
,function (dump)
	local errorCount = 0
	local correctCount = 0
	for key, value in pairs(dump) do
		if value.errored then
			errorCount = errorCount + 1
			if host:isHost() then
				notify(value.msg:match("[^\n]+"),value.path)
			end
		else
			correctCount = correctCount + 1
		end
	end
	if host:isHost() then
		notif:setMessage(correctCount.." loaded, "..errorCount.." failed")
		notif:setIcon(":@gn_portrait:")
		notif:timeout(1)
	end
end)

