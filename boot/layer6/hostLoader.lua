if not host:isHost() then return end
local coreCommons = require("boot.lib.coreCommons")

local addScript = addScript

if not addScript then
	notify("fallback to classic loader, All host scripts will be included if uploaded","SillyPlugin not found",":cancel:",true):timeout(10)
	addScript = function ()
	end
end
local notif = notify("Loading Host Scripts...","Host Loader",":loading:",true)
coreCommons.asyncLoadDir(listFiles("scripthost",true),
function (path,ok)
	notif:setMessage("loading "..path)
	addScript(path,nil,"NBT")
end
,function (dump)
	local errorCount = 0
	local correctCount = 0
	for key, value in pairs(dump) do
		if value.errored then
			errorCount = errorCount + 1
			notify(value.msg:match("[^\n]+"),value.path,nil,true):timeout(20)
		else
			correctCount = correctCount + 1
		end
	end
	if silly then
		silly:updateAvatarSize()
	end
	notif:setMessage(correctCount.." loaded, "..errorCount.." failed")
	notif:setIcon(":@gn_portrait:")
	notif:timeout(1)
end)
addScript(table.concat({...},"/"),nil)
