local patterns = {
	" gn ",
	" gnui ",
	" green neon user interface ",
}

local mentionColor = vectors.hexToRGB("#d3fc7e")

local hasInbox = 0

events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
	hasInbox = hasInbox + 1
end)

events.WORLD_RENDER:register(function (delta)
	for i = 1, hasInbox, 1 do
		local chat = host:getChatMessage(hasInbox)
		if not chat then break end
		local message = " "..chat.message:lower().. " "
		
		local mentioned = false
		for _, pattern in ipairs(patterns) do
			if message:find(pattern) then
				mentioned = true
				break
			end
		end
		
		if mentioned then
			host:setChatMessage(i,chat.json,mentionColor)
		end
	end
	hasInbox = 0
end)