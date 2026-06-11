local MODEL = models.plushie

MODEL:setParentType("Skull")

local label = MODEL:newText("label")
:scale(1)
:pos(-8,16,0)
:background(true)
:backgroundColor(0,0,0,0.5)


local IS_NEW = 0 < client.compareVersions(client:getVersion(),"1.20.1")

---@param item ItemStack
local function getItemData(item)
	local nbt = item.tag
	if IS_NEW then
		if nbt
		and nbt["minecraft:profile"]
		and nbt["minecraft:profile"].properties
		and nbt["minecraft:profile"].properties then
			local textures = {}
			for index, value in ipairs(nbt["minecraft:profile"].properties) do
				textures[index] = value.value
			end
			return textures
		end
	else
		if nbt
		and nbt.SkullOwner
		and nbt.SkullOwner.Properties
		and nbt.SkullOwner.Properties.textures
		and nbt.SkullOwner.Properties.textures then
			local textures = {}
			local i = 0
			for index, value in pairs(nbt.SkullOwner.Properties) do
				i = i + 1
				textures[i] = value[1].Value
			end
			return textures
		end
	end
	return nbt
end

---@param block BlockState
local function getDataBlock(block)
	local nbt = block:getEntityData()
	if IS_NEW then
		if nbt
		and nbt.profile
		and nbt.profile.properties
		and nbt.profile.properties then
			local textures = {}
			for index, value in ipairs(nbt.profile.properties) do
				textures[index] = value.value
			end
			return textures
		end
	else
		if nbt
		and nbt.SkullOwner
		and nbt.SkullOwner.Properties
		and nbt.SkullOwner.Properties.textures
		and nbt.SkullOwner.Properties.textures then
			local textures = {}
			local i = 0
			for index, value in pairs(nbt.SkullOwner.Properties) do
				i = i + 1
				textures[i] = value[1].Value
			end
			return textures
		end
	end
	return nbt
end


local function display(...)
	label:setText(...)
end

local textureCache = {}

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	local benchmark = avatar:getCurrentInstructions() -- START OF BENCHMARK
	local textures
	local hash = ""
	if ctx == "BLOCK" then
		hash = hash .. tostring(block:getPos())
		textures = textureCache[hash] or getDataBlock(block)
	elseif ctx == "HEAD" then
		hash = hash .. item:getName() .. entity:getUUID()
		textures = textureCache[hash] or getItemData(item)
	end
	textureCache[hash] = textures
	local results = avatar:getCurrentInstructions()-benchmark-5
	display(results)
end)