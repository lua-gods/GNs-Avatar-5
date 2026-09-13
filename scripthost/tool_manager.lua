for _, path in pairs(listFiles("scripthost.tools")) do
	local tool = require(path)
	tool.macro:setActive(true)
end