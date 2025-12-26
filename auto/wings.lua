if true then
	models.player.Base.Torso.Waist.Chest.Wings:setVisible(false)
	return
end

local WINGX = animations.player.wingsX
local WINGZ = animations.player.wingsZ

local WINGS = models.player.Base.Torso.Waist.Chest.Wings
WINGS:setScale(0.7)

for index, value in ipairs(WINGS.RightWing.RightWing1:getChildren()) do
	if value:getType() == "GROUP" then
		value:setSecondaryRenderType("EYES"):setSecondaryTexture("PRIMARY"):setPrimaryColor(0,0,0)
	end
end

for index, value in ipairs(WINGS.LeftWing.LeftWing1:getChildren()) do
	if value:getType() == "GROUP" then
		value:setSecondaryRenderType("EYES"):setSecondaryTexture("PRIMARY"):setPrimaryColor(0,0,0)
	end
end

WINGX:speed(0):play()
WINGZ:speed(0):play()

events.RENDER:register(function (delta)
	local t = (world.getTime()+delta)/5
	WINGX:setTime(math.sin(t)*0.5+0.5)
	WINGZ:setTime(math.cos(t)*0.5+0.5)
end)