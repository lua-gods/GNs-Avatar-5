#host

local entries = {
	scale = function (size)
		return "/trigger scale set " .. size
	end,
	sit = function ()
		return "/trigger sit"
	end
}

events.CHAT_SEND_MESSAGE:register(function (message)
	if message and message:find("^/") then
		local head
		local words = {}
		local i = 0
		for word in message:sub(2,-1):gmatch("%S+") do
			if i == 0 then
				head = word
			else
				words[i] = word
			end
			i = i + 1
		end
		
		if entries[head] then
			return entries[head](table.unpack(words))
		end
	end
	return message
end)