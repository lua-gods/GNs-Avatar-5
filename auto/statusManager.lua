local event = require("lib.event")

local SM = {
	status = 0,
	STATUS_CHANGED = event.new()
}

function pings.status(id)
	if SM.status ~= id then
		SM.status = id
		SM.STATUS_CHANGED:invoke(id)
	end
end

if host:isHost() then
	local lastStatus = 0
	
	
	events.KEY_PRESS:register(function ()
		if not host:getScreen() and SM.status == 1 then
			SM.status = 0
		end
	end)
	
	
	events.TICK:register(function ()
		if not client:isWindowFocused() then
			SM.status = 1
			
		elseif SM.status ~= 1 then
			local t = host:getChatText()
			if t and #t > 0 then
				SM.status = 2
			else
				SM.status = 0
			end
		end
		
		if lastStatus ~= SM.status then
			lastStatus = SM.status
			pings.status(SM.status)
		end
	end)
end
return SM