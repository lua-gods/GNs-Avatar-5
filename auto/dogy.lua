local Macro = require("lib.macros")
local ModelUtils = require("lib.modelUtils")

local macro = Macro.new(function (events, speed)
	local sound = sounds["sounds.dog"]:loop(true):pitch(speed):play()
	
	local verts = {}
	
	events.TICK:register(function ()
		sound:pos(player:getPos())
	end)
	
	events.WORLD_RENDER:register(function (delta)
		local t = (world.getTime()+delta)*0.23*speed
		for index, v in ipairs(verts) do
			v.ref:setPos(v.pos + vec(0,0,math.sin(t+v.pos.y*0.2)*4))
		end
	end)
	
	ModelUtils.apply(models.player, function (modelPart)
		for key, material in pairs(modelPart:getAllVertices()) do
			for key, vert in pairs(material) do
				verts[#verts+1] = {ref = vert, pos = vert:getPos()}
			end
		end
	end)
	
	events.ON_EXIT:register(function ()
		sound:stop()
		for index, v in ipairs(verts) do
			v.ref:setPos(v.pos)
		end
	end)
end)



function doggy(speed)
	pings.doggy(speed)
end

function pings.doggy(speed)
	speed = speed or (macro.isActive and 0 or 1)
	macro:setActive(false)
	macro:setActive(speed ~= 0,speed)
end