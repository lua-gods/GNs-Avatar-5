local SkullAPI = require("lib.GNskull")

for index, value in ipairs(listFiles("./skulls")) do
	local identity = require(value)
end


function makeHead(header,binary)
	local item = SkullAPI.makeHead(header,binary)
	if item then
		--host:setClipboard(item)
		giveItem(item,1)
	end
end

function readHeadBlock(x,y,z)
	local p = player:getPos()
	x = x or p.x
	y = y or p.y
	z = z or p.z
	local outHeader,outBinary = SkullAPI.getDataBlock(world.getBlockState(x,y,z))
	log(outHeader)
	host:setClipboard(toJson(outHeader))
	return {header=outHeader,binary=outBinary}
end

avatar:store("readHeadItem", function (item)
	local header,binary = SkullAPI.getItemData(item)
	log(header)
	host:setClipboard(toJson(header))
	return {header=header,binary=binary}
end)
avatar:store("readHeadBlock", readHeadBlock)

avatar:store("writeHead",function (header,binary)
	return SkullAPI.makeHead(header,binary)
end)
