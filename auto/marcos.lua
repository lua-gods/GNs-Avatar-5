if not host:isHost() then return end
for key, value in pairs(listFiles("auto.macros")) do
	require(value)
end