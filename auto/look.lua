
if not host:isHost() then return end



---@param dirVec Vector3
---@return Vector3
local function dirToEular(dirVec)
	local yaw = math.atan2(dirVec.x, dirVec.z)
	local pitch = math.atan2(dirVec.y, dirVec.xz:length())
	return vec(math.deg(pitch), math.deg(yaw) + 180, 0)
end


local activeLook = false
local activeZoom = false


local homePage = action_wheel:newPage("home")

homePage:newAction()
:setTitle("Look")
:setItem("minecraft:ender_eye")
:onToggle(function (state, self)
	activeLook = state
end)

homePage:newAction()
:setTitle("zoom")
:setItem("minecraft:spyglass")
:onToggle(function (state, self)
	activeZoom = state
	if not activeZoom then
		renderer:setFOV()
	end
end)


---@param point Vector3
---@param radius number
---@return Entity|nil
local function nearestEntity(point, radius)
   local best = math.huge
   local entity
   for _, e in pairs(world.getEntities(point - radius, point + radius)) do
      ---@cast e Entity
		if e:getType() ~= "minecraft:player" and e:isLiving() and e:getHealth() > 0 then
			local dist = (e:getPos() - point):lengthSquared()
			if dist < best then
				best = dist
				entity = e
			end
		end
   end
   return entity
end

action_wheel:setPage(homePage)

events.POST_WORLD_RENDER:register(function (delta)
	if not player:isLoaded() then return end
	local ppos = player:getPos()
	
	local closestPos
	if activeLook then
		local from = player:getPos(delta):add(0,player:getEyeHeight())
		local nearest = nearestEntity(from, 32)
		if nearest then
			silly:setRot((dirToEular(nearest:getPos(delta):add(0,nearest:getEyeHeight())-from).xy * vec(-1,-1) - vec(0,180)).xy)
		end
	end
	
	renderer.renderCrosshair = not (activeLook or activeZoom)
end,"look")