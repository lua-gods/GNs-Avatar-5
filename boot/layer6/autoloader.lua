
local coreCommons = require("boot.lib.coreCommons")
local notif 
if host:isHost() and notify then
	notif = notify("Loading Scripts...","Avatar Loader",":loading:",true)
end
coreCommons.asyncLoadDir(listFiles("scripts",true),
function (path,ok)
	if notif then
		notif:setMessage("loading "..path)
	end
end
,function (dump)
	local errorCount = 0
	local correctCount = 0
	for key, value in pairs(dump) do
		if value.errored then
			errorCount = errorCount + 1
			if notif then
				notify(value.msg:match("[^\n]+"),value.path,nil,true):timeout(20)
			end
		else
			correctCount = correctCount + 1
		end
	end
	if notif then
		notif:setMessage(correctCount.." loaded, "..errorCount.." failed")
		notif:setIcon(":@gn_portrait:")
		notif:timeout(1)
	end
end)

