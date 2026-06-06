local history = ""
local count = 0
local time
events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
	if message:find("START") then
		time = client:getSystemTime()
	end
	if message:find("END") then
		print("Benchy took "..(client:getSystemTime() - time).."ms")
		history = history..(client:getSystemTime() - time).."\n"
		count = count + 1
		host:setActionbar(count.." times")
		host:setClipboard(history)
	end
end)