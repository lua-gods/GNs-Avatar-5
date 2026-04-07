for index, value in ipairs(listFiles("auto.actions")) do
	require(value)
end