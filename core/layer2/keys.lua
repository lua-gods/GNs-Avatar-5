if false then
	KEY = 0
end

if host:isHost() then
	addScript("key", "KEY = " .. math.random(1, 99999999999), "BOTH")
end
require("key")
