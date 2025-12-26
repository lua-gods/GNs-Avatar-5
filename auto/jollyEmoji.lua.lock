function events.CHAT_SEND_MESSAGE(message)
	if message:sub(1,1) ~= "/" then
		return message:gsub(":([^: ]+):", ":%1::back::christmas_hat_emoji:")
	else
		return message
	end
end