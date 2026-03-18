
local BUILDER_ITEM = "minecraft:diamond_shovel"

local key = {
	left = keybinds:fromVanilla("key.attack"),
	right = keybinds:fromVanilla("key.use"),
}

local face2dir = {
	north = vec(0,0,-1),
	east  = vec(1,0,0),
	south = vec(0,0,1),
	west  = vec(-1,0,0),
	up    = vec(0,1,0),
	down  = vec(0,-1,0),
}

local OFFSET = vec(-2,1,-2)

key.left:onPress(function (modifiers, self)
	if player:getHeldItem().id == BUILDER_ITEM then
		host:swingArm()
		local block,hitPos,face = player:getTargetedBlock()
		local dir = face2dir[face]
		local pos = block:getPos()
		pos = ((pos - OFFSET) / 3):floor() * 3 + OFFSET
		host:sendChatCommand(("fill %s %s %s %s %s %s %s"):format(
			pos.x,pos.y,pos.z,
			pos.x+2,pos.y+2,pos.z+2,
			"air destroy"
		))
		return true
	end
end)

key.right:onPress(function (modifiers, self)
	local heldItem = player:getHeldItem()
	if heldItem.id == BUILDER_ITEM then
		host:swingArm()
		local block,hitPos,face = player:getTargetedBlock()
		local dir = face2dir[face]
		local pos = block:getPos() + dir
		local p = ((pos - OFFSET)/3):floor()
		pos = ((pos - OFFSET) / 3):floor() * 3 + OFFSET
		local checkered = (math.cos(p.x * math.pi) * math.cos(p.y * math.pi) * math.cos(p.z * math.pi)) >= 0
		host:sendChatCommand(("fill %s %s %s %s %s %s %s"):format(
			pos.x,pos.y,pos.z,
			pos.x+2,pos.y+2,pos.z+2,
			checkered and "snow_block" or "white_concrete"
		))
		return true
	end
end)