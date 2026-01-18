for key, value in pairs(listFiles("auto.skulls")) do
	require(value)
end

local SkullAPI = require("lib.skull")

local function give(item)
	if player:isLoaded() then
		local id = player:getNbt().SelectedItemSlot
		sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
		host:setSlot("hotbar."..id,item)
	end
end

function head(nbt,name)
	name = name or "GN's Head"
	give(SkullAPI.makeSkull(nbt,name))
end
