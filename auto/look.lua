
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

action_wheel:setPage(homePage)

events.POST_WORLD_RENDER:register(function (delta)
	if not player:isLoaded() then return end
	local ppos = player:getPos()
	
	local closestPos
	for name, other in pairs(world.getPlayers()) do
		if other:getUUID() ~= player:getUUID() and other:isLoaded() and player:isLoaded() then
			local pos = other:getPos(delta):add(0,other:getBoundingBox().y*0.8)
			if not closestPos then
				closestPos = pos
			else
				if closestPos then
					if (pos - ppos):length() < (closestPos - ppos):length() then
						closestPos = pos
					end
				end
			end
			local from = player:getPos(delta):add(0,player:getEyeHeight())
			
			if activeLook then
				
				silly:setRot((dirToEular(closestPos-from).xy * vec(-1,-1) - vec(0,180)).xy)
			end
			
			if activeZoom then
				local dist = closestPos-from
				renderer:setFOV(math.min(1.5/dist:length(),1))
			end
			
			renderer.renderCrosshair = not (activeLook or activeZoom)
		end
	end
end,"look")