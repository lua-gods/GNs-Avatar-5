local soundNames = {}
local nameSounds = {}
local i = 0
for index, value in ipairs(sounds:getCustomSounds()) do
	if value:find("30%.") then
		i = i + 1
		table.insert(soundNames, value)
		nameSounds[value] = true
	end
end

local api = {}
local e = 0
function api.playRandom(pos)
	--e = (e + 1) % (i - 1)
	e = 0
	e = e + math.floor(world.getTime()/10)
	--pos = pos:floor()
	e = (e + pos.x * 12.135 )% 1024
	e = (e + pos.y * 321.25 )% 1024
	e = (e + pos.z * 42.41  )% 1024
	e = (e - 1) % (i - 1) + 1
	--local s = math.map(e*51.5215%1,0,1,0.25,2)
	e = math.floor(e)
	return sounds:playSound(soundNames[e],pos,1,1)
end

return api