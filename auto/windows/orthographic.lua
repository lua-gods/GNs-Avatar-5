local Macro = require("lib.GNMacros")

local Window = require("lib.GNUI-WindowManager.widgets.window")
local Event = require("lib.GNEvent")
local Pathfind = require("lib.AStar")
local applyMotion = require("lib.silly.walk")
local Tween = require("lib.GNtween")

local transition = 0
local myApp

---@return Vector3
local function getVelocity()
	---@diagnostic disable-next-line: return-type-mismatch
	return vec(table.unpack(player:getNbt().Motion))
end

local function applyMat(t)
	if t > 0.01 then
		local fov = client:getFOV()
		local F = fov * (1 - t * 0.999)
		local dist = 3
		local cmat = matrices.mat4(
			vec(1, 0, 0, 0),
			vec(0, 1, 0, 0),
			vec(0, 0, F / fov, (F / fov) - 1),
			vec(0, 0, 0, 1)
		):transpose()
		renderer:setCameraMatrix(matrices.translate4(0, 0, -dist) * cmat *
		matrices.translate4(0, 0, dist))
	else
		renderer:setCameraMatrix()
	end
end

myApp = Macro.new(function(events, screen, GNUI)
	Tween.new{
		from = transition,
		to = 1,
		duration = 1,
		tick = function(v)
			transition = v
			applyMat(v)
		end,
		easing="inOutCubic",
		id="isometricTransition"
	}
	local Window = Window.new(screen)
	Window.ON_CLOSE:register(function()
		myApp:setActive(false)
	end)
	
	Window:setPos(-50,0)
	
	events.ON_EXIT:register(function()
		Tween.new{
			from = transition,
			to = 0,
			duration = 1,
			tick = function(v)
				transition = v
				applyMat(v)
			end,
			easing="inOutCubic",
			id="isometricTransition"
		}
		Window:free()
	end)
end)

return myApp
