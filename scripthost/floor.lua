local floor = models:newPart("floor","WORLD")
:light(15,15)
local tex = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1,1))

local BORDER_THICKNESS = 0.2

local i = 0
local CHECK_QUALITY = 2
local function newSquare(alpha)
	i = i + 1
	local self = floor
	:newPart("floor"..i)
	
	local task = self:newSprite("a")
	
	task:texture(tex,1,1)
	:pos(0.5,0.5)
	:setColor(1,1,1,alpha)
	return self,task
end



newSquare(0.2)
:rot(90,0,0)
:scale(16,16,16)

newSquare(1)
:pos(0,0,8)
:rot(90,0,0)
:scale(16,BORDER_THICKNESS,0)

newSquare(1)
:pos(0,0,-8)
:rot(90,0,0)
:scale(16,BORDER_THICKNESS,0)


newSquare(1)
:pos(8,0,0)
:rot(90,0,0)
:scale(BORDER_THICKNESS,16,0)

newSquare(1)
:pos(-8,0,0)
:rot(90,0,0)
:scale(BORDER_THICKNESS,16,0)



local DOWN = vec(0,-50,0)

events.WORLD_RENDER:register(function (delta)
	if not player:isLoaded() then return end
	local s = player:getBoundingBox().x
	local pos = player:getPos(delta)
	
	local highest = DOWN.y
	local STEPS = math.ceil(s*16) / CHECK_QUALITY
	for z = 0, STEPS, 1 do
		for x = 0, STEPS, 1 do
			local eye = pos + (vec(x,z) / STEPS - vec(0.5,0.5)).x_y:add(0,0.1,0) * s
			local block, hitPos = raycast:block(eye,eye + DOWN)
			highest = math.max(highest,hitPos.y)
		end
	end
	
	floor
	:pos((vec(pos.x,highest+0.01,pos.z))*16)
	:scale(s,s)
end)