
if not host:isHost() then return end

local INNACURACY = 0.0172275
local GRAVITY = 0.05
local DRAG = 0.99
local TERMINAL_VELOCITY = 100

local SENSITIVITY = 0.1

local rangeWeapons = {
	["minecraft:bow"] = {
		charge_time = 1,
		magnitude = 3,
		innacuracy = 1,
	}
}

---@param dirVec Vector3
---@return Vector3
local function directionToEulerDegree(dirVec)
    local yaw = math.atan2(dirVec.x, dirVec.z)
    local pitch = math.atan2(dirVec.y, dirVec.xz:length())
    return vec(-math.deg(pitch), -math.deg(yaw), 0)
end

local initRot
local zoom = 1

local isCharging = false
events.WORLD_RENDER:register(function (delta)
	if not player:isLoaded() then return end
	local activeItem = player:getActiveItem()
	if rangeWeapons[activeItem.id] then
		if not isCharging then
			isCharging = true
			initRot = player:getRot()
		end
		local props = rangeWeapons[activeItem.id]
		local charge = math.min((player:getActiveItemTime()+delta) / 20 * props.charge_time,1) * props.magnitude
		
		local startPos = player:getPos():add(0,player:getEyeHeight())
		
		local pos = startPos:copy()
		local vel = (player:getLookDir() * charge):clampLength(0,TERMINAL_VELOCITY)
		
		local hitPos
		
		local innacuracy = 0
		for i = 1, 300, 1 do
			innacuracy = innacuracy + INNACURACY
			local to = pos + vel
			local _,ehitPos = raycast:entity(pos, to,function (entity)
				return entity:getUUID() ~= player:getUUID()
			end)
			local _,bhitPos = raycast:block(pos, to)
			if (ehitPos and (ehitPos-to):lengthSquared() > 0.01) or (bhitPos-to):lengthSquared() > 0.01 then
				hitPos = ehitPos or bhitPos
				break
			end
			
			pos = pos + vel
			vel = vel * DRAG
			vel = vel - vec(0, GRAVITY, 0)
			particles["end_rod"]:scale(innacuracy * 3 * 2):pos(pos):spawn():lifetime(0)
		end
		hitPos = pos
		
		renderer:setFOV(1/zoom^2)
		renderer:setCameraRot(directionToEulerDegree((hitPos-startPos):normalize()))
		
	else
		zoom = 1
		isCharging = false
		renderer:setCameraRot()
		renderer:setFOV()
	end
end)

events.MOUSE_SCROLL:register(function (dir)
	if isCharging then
		zoom = math.clamp(zoom + dir * 0.1, 1, 10)
		return true
	end
end)

events.MOUSE_MOVE:register(function (x, y)
	if player:isLoaded() and rangeWeapons[player:getActiveItem().id] then
		initRot = initRot + vec(y,x) * SENSITIVITY * (1/zoom^2)
		initRot.x = math.clamp(initRot.x, -89, 89)
		silly:setRot(initRot)
		return true
	end
end)