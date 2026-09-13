local extraMath = require("lib.extraMath")

local zoom = 5



events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" and renderer:isCameraBackwards() then
		local rot = player:getRot(delta)
		renderer:setFOV(0.5)
		renderer:offsetCameraPivot(0,-0.6,0)
		renderer:cameraRot(10,rot.y+180,0)
	else
		renderer:cameraRot()
		renderer:offsetCameraPivot()
		renderer:setFOV()
	end
end)