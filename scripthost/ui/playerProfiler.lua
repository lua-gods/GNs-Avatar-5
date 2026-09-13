local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()
local Macro = require("lib.GNMacros")

local ZOOM_SPEED = 0.05
local TARGET_ZOOM = 2
local SELECTOR_SIZE = 8
local TARGET_DECAY = 20

---@param dir Vector3
---@return Vector3
local function dirToEular(dir)
    local yaw = math.atan2(dir.x, dir.z)
    local pitch = math.atan2(dir.y, dir.xz:length())
    return vec(-math.deg(pitch), -math.deg(yaw), 0)
end

local hasTarget = false
local isSearching = false
local target
local keyActivate = keybinds:fromVanilla("key.playerlist")
local profiler = Macro.new(function (macro, events, ...)
	local res = client:getScaledWindowSize()
	local selection = screen:parse{
		style={
			type="nineslice",
			uv=vec(3,0,19,16),
			texturePath="textures.ui",
			border=vec(8,8,8,8),
		},
		size=vec(0,0),
		sizing={"FIXED","FIXED"},
	}
	
	local low = res*0.5
	local high = res*0.5
	
	local newlLow
	local newHigh
	
	local timeSinceTarget = 0
	local lastDiff
	local targetZoom = 1
	
	events.WORLD_RENDER:register(function ()
		if isSearching then
			local from = player:getPos():add(0,player:getEyeHeight())
			local to = from + player:getLookDir() * 100
			local newTarget = raycast:entity(from,to,function (entity)
				return entity ~= player
			end)
			if newTarget then
				timeSinceTarget = TARGET_DECAY
			end
			if target ~= newTarget then
				if newTarget then
					target = newTarget
					if target then
						soundUI("minecraft:block.stone_button.click_off",4)
					end
				else
					timeSinceTarget = timeSinceTarget - 1
					if timeSinceTarget < 0 then
						soundUI("minecraft:block.stone_button.click_off",3)
						target = nil
					end
				end
			end
		end
		if target and target:isLoaded() then
			hasTarget = true
			local pos = target:getPos()
			local b = target:getBoundingBox():mul(0.5,1,0.5)
			
			newlLow = vec(math.huge,math.huge)
			newHigh = vec(-math.huge,-math.huge)
			
			for z = -1,1,2 do
				for y = 0,1,1 do
					for x = -1,1,2 do
						local point = pos + b * vec(x,y,z)
						local lpos = vectors.worldToScreenSpace(point)
						if lpos.z > 1 then
							local spos = lpos.xy * 0.5 + 0.5
							newlLow.x = math.min(newlLow.x,spos.x)
							newlLow.y = math.min(newlLow.y,spos.y)
							
							newHigh.x = math.max(newHigh.x,spos.x)
							newHigh.y = math.max(newHigh.y,spos.y)
						end
					end
				end
			end
		else
			lastDiff = nil
			newlLow,newHigh = nil,nil
			hasTarget = false
		end
		
		local res = client:getScaledWindowSize()
		if newlLow and newHigh then
			low = newlLow*res
			high = newHigh*res
		else
			low = math.lerp(low,res*0.5-SELECTOR_SIZE,0.5)
			high = math.lerp(high,res*0.5+SELECTOR_SIZE,0.5)
		end
		selection:setPos(low)
		selection:setSize((high-low))
	end)
	
	
	events.WORLD_RENDER:register(function (delta)
		if target and target:isLoaded() and player:isLoaded() then
			local posA = player:getPos(delta):add(0,player:getEyeHeight())
			local posB = target:getPos(delta):add(0,target:getEyeHeight())
			local diff = posA-posB
			
			if lastDiff then
				local angleDiff = dirToEular(diff)-dirToEular(lastDiff)
				angleDiff.y = ((angleDiff.y + 180) % 360) - 180
				angleDiff.x = -angleDiff.x
				if angleDiff:lengthSquared() > 0.0001 then
					silly:setRot(player:getRot() + angleDiff.xy)
				end
			end
			lastDiff = diff
			targetZoom = diff:length()/TARGET_ZOOM
		else
			targetZoom = 1
		end
		renderer:setFOV(math.clamp(1/targetZoom,0.001,1))
	end)
	
	events.ON_EXIT:register(function ()
		renderer:setFOV()
		selection:free()
	end)
end)

keyActivate
:onPress(function () 
	isSearching = true
	profiler:setActive(true) 
end)
:onRelease(function () 
	isSearching = false
	profiler:setActive(hasTarget)
end)