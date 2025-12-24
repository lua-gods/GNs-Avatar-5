
local STATE = {
	status = 0
}

animations.player.afk:setPriority(1)

local STATUS = {
	{status="idle",icon=":zzz:"},
	{status="typing...",icon=":mci_book_and_quill:"},
}

function pings.setStatus(id)
	local status = {}
	STATE.status = id
	if STATUS[id] then
		status = STATUS[id]
	end
	
end

if host:isHost() then
	local lastStatus = 0
	
	
	events.KEY_PRESS:register(function ()
		if not host:getScreen() and STATE.status == 1 then
			STATE.status = 0
		end
	end)
	
	
	events.TICK:register(function ()
		if not client:isWindowFocused() then
			STATE.status = 1
			
		elseif STATE.status ~= 1 then
			if host:isChatOpen() then
				STATE.status = 2
			else
				STATE.status = 0
			end
		end
		
		if lastStatus ~= STATE.status then
			lastStatus = STATE.status
			pings.setStatus(STATE.status)
		end
	end)
end
return STATE