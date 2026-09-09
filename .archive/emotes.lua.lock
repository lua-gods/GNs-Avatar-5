local EMOTES = {}

for key, value in pairs(animations.player) do
	EMOTES[#EMOTES+1] = value
end

local speed = 0
local lastEmote
function pings.emote(id)
	if lastEmote then
		lastEmote:stop()
	end
	if EMOTES[id] then
		EMOTES[id]:play()
	end
	lastEmote = EMOTES[id]
end

function pings.speed(s)
	speed = s
end

local page = action_wheel:newPage()

for index, value in ipairs(EMOTES) do
	local o = index
	page:newAction()
	:setTitle(value:getName())
	:onLeftClick(function()
		pings.emote(o)
	end)
	:onRightClick(function (self)
		pings.emote()
	end)
end

action_wheel:setPage(page)