#host


local STEER_SPEED = 90


local keys = {
	left = keybinds:newKeybind("Steer Left","key.keyboard.left"),
	right = keybinds:newKeybind("Steer Right","key.keyboard.right"),
	up = keybinds:newKeybind("Accelerate","key.keyboard.up"),
	down = keybinds:newKeybind("Reverse","key.keyboard.down")
}

local lastTime = client:getSystemTime()
events.WORLD_RENDER:register(function ()
	if not player:isLoaded() then return end
	local time = client:getSystemTime()
	local delta = (time - lastTime) / 1000
	lastTime = time
	local rot = player:getRot()
	local add = vec(0,0)
	if keys.left:isPressed() then add.y = add.y - STEER_SPEED end
	if keys.right:isPressed() then add.y = add.y + STEER_SPEED end
	if keys.up:isPressed() then add.x = add.x - STEER_SPEED end
	if keys.down:isPressed() then add.x = add.x + STEER_SPEED end
	if add ~= vec(0,0) then
		silly:setRot(rot + add * delta)
	end
end)