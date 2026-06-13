local SkullAPI = require("lib.GNskull")

for index, value in ipairs(listFiles("./skulls")) do
	local identity = require(value)
end


function makeSkull(header,binary)
	local item = SkullAPI.makeSkull(header,binary)
	if item then
		--host:setClipboard(item)
		giveItem(item,1)
	end
end