for index, value in ipairs(listFiles("auto.commands")) do
	require(value)
end