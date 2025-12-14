events.CHAT_SEND_MESSAGE:register(function(message)
	if message then
		if (message:sub(1, 1) == "!") then
			host:sendChatCommand(
				"/tellraw @a " .. toJson(
					{
						{
							text = ":@gn: <GN> ",
							color = "#d3fc7e",
						},
						{
							text = message:sub(2, message:len()),
							color = "#d3fc7e",
						},
					}
				)
			)
		else
			return message
		end
	end
end, "chatStuff")