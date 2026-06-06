local MOVEMENT_SPEED = 0.1
local MUL_SPRINT = 1.3
local MUL_SNEAK = 0.3
local JUMP_PUSH = 0.3
local JUMP_STRENGTH = 0.42

---@param pos Vector3
---@param vel Vector3
---@param yaw number
---@param isOnGround boolean
---@param move Vector3
---@param isCrouching boolean?
---@param isSprinting boolean?
---@return Vector3
local function applyMovement(pos, vel, yaw, isOnGround, move, isCrouching, isSprinting)
	local pos = pos
	local rYaw = math.rad(yaw)

	-- calculate player movement strength
	local markiplier = 1
	if isCrouching then
		markiplier = MUL_SNEAK
	elseif isSprinting then
		markiplier = MUL_SPRINT
	end

	-- calculate friction
	local slipperiness = isOnGround and world.getBlockState(pos - vec(0, 0.5, 0)):getFriction() or
		 0.91

	-- calculation of movement based on floor friction
	local movementSpeed = isOnGround
		 and (MOVEMENT_SPEED * (0.6 / slipperiness) ^ 3)
		 or (MOVEMENT_SPEED * 0.1)

	local speed = math.max(movementSpeed * markiplier, 0.02)

	local pushVel
	local d = move:lengthSquared()
	if d < 1.0E-7 then
		pushVel = vec(0, 0, 0)
	else
		local move = (d > 0 and move.x_z:normalized() or move) * speed
		local f = math.sin(rYaw)
		local g = math.cos(rYaw)
		---@diagnostic disable-next-line: param-type-mismatch
		pushVel = vec(move.x * g - move.z * f, move.y, move.z * g + move.x * f)
	end

	-- jump logic
	if isOnGround then
		if move.y > 0 then
			vel.y = JUMP_STRENGTH
		end
		if isSprinting then -- sprint jump forward boost
			pushVel = pushVel + vec(
				-math.sin(rYaw) * JUMP_PUSH,
				0,
				math.cos(rYaw) * JUMP_PUSH
			)
		end
	end

	vel = vel + pushVel
	return vel
end

return applyMovement