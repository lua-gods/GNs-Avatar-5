

local MODEL = models.plushie


local IS_NEW = 0 < client.compareVersions(client:getVersion(),"1.20.1")
MODEL:setParentType("Skull")


---@class GN.Skull.Identity
---@field id string
---@field init  fun(skull: GN.Skull.Instance,model:ModelPart)
---@field frame fun(skull: GN.Skull.Instance,dt: number, df: number)
---@field tick  fun(skull: GN.Skull.Instance)
---@field exit  fun(skull: GN.Skull.Instance)

---@class GN.Skull.Instance
---@field identity GN.Skull.Identity
---@field part ModelPart
---@field header table
---@field binary string


local label = MODEL:newText("label")
:scale(0.25)
:pos(-8,16,0)
:background(true)
:backgroundColor(0,0,0,0.5)


--────  Utilities  ────────────────────────────────────────────────────────--

---@param string string
---@return string
local function parseBase64(string)
	local buffer = data:createBuffer()
	buffer:writeBase64(string)
	buffer:setPosition(0)
	local out = buffer:readByteArray(buffer:available())
	buffer:close()
	return out
end


---@param string string
---@return string
local function toBase64(string)
	local buffer = data:createBuffer()
	buffer:writeByteArray(string)
	buffer:setPosition(0)
	local out = buffer:readBase64(buffer:available())
	buffer:close()
	return out
end


local function _recursiveComponent(text,component)
	if component.text then
		text = text .. component.text
	end

	if component.extra then
		for _,extra in ipairs(component.extra) do
			text = text .. _recursiveComponent(text,extra)
		end
	end

	return text
end


---Converts raw json text to the final output text
---@param rawJsonText any
---@return unknown
local function toPlainText(rawJsonText)
	local ok, result = pcall(parseJson,rawJsonText)
	if ok then
		return _recursiveComponent("",result)
	else
		return rawJsonText
	end
end


--- apple,banana,carrot={color="glue"}
--- 
--- turns into
--- 
--- apple={},banana={},carrot={color='glue'}
---@param name any
---@return unknown
local function parseName(name)
	local output = toPlainText(name)..","
	local hasNoCasing = false
	if not output:find("^{") then 
		output = "{" .. output
		hasNoCasing = true
	end
	
	output = output
	:gsub("([%a_][%w_]*)%s*,", "%1={},")
	:gsub("^([%a_][%w_]*)%s*,", "%1={},")
	:gsub(",%s*([%a_][%w_]*)%s*=", ",%1=")
	
	output = output:sub(1,-2)
	
	if hasNoCasing then
		output = output .. "}"
	end
	
	return output
end


local function parseHeader(base64)
	local ok, result = pcall(parseBase64,base64)
	if ok then
		local ok, result = pcall(parseJson,result)
		if ok then
			return result
		end
	end
	return {}
end


---@param item ItemStack
local function getItemData(item)
	local header = ""
	local binary = ""
	local nbt = item.tag
	if IS_NEW then
		if nbt
		and nbt["minecraft:custom_name"] then
			header = parseName(nbt["minecraft:custom_name"])
		end
		
		if nbt
		and nbt["minecraft:profile"]
		and nbt["minecraft:profile"].properties
		and nbt["minecraft:profile"].properties then
			for index, property in ipairs(nbt["minecraft:profile"].properties) do
				if index == 1 then
					if #header > 0 then
						header = parseJson(header:sub(1,-2) .. "," .. (toJson(parseHeader(property.value)):sub(2,-1)))
					else
						header = parseHeader(property.value)
					end
				else
					binary = binary .. property.value
				end
			end
		end
	else
		
		if nbt --TODO: Check if this works
		and nbt.CustomName then
			header = parseName(nbt.CustomName)
		end
		
		if nbt
		and nbt.SkullOwner
		and nbt.SkullOwner.Properties
		and nbt.SkullOwner.Properties.textures
		and nbt.SkullOwner.Properties.textures then
			local i = 0
			for index, value in pairs(nbt.SkullOwner.Properties) do
				i = i + 1
				if i == 1 then
					if #header > 0 then
						header = parseJson(header:sub(1,-2) .. "," .. (toJson(parseHeader(value[1].Value)):sub(2,-1)))
					else
						header = parseHeader(value[1].Value)
					end
				else
					binary = binary .. value[1].Value
				end
			end
			return header,binary
		end
	end
	return header,binary
end


---@param block BlockState
---@return string,string
local function getDataBlock(block)
	local nbt = block:getEntityData()
	local header = ""
	local binary = ""
	
	if IS_NEW then
		
		if nbt
		and nbt.custom_name then
			header = parseName(nbt.custom_name)
		end
		
		if nbt
		and nbt.profile
		and nbt.profile.properties
		and nbt.profile.properties then
			
			for index, property in ipairs(nbt.profile.properties) do
				if index == 1 then
					if #header > 0 then
						-- badly stitch together two json tables
						header = parseJson(header:sub(1,-2).. "," .. (toJson(parseHeader(property.value)):sub(2,-1)))
					else
						header = parseHeader(property.value)
					end
				else
					binary = binary .. property.value
				end
			end
			
		end
	else
		if nbt --TODO: Check if this works
		and nbt.CustomName then
			header = parseName(nbt.CustomName)
		end
		
		if nbt
		and nbt.SkullOwner
		and nbt.SkullOwner.Properties
		and nbt.SkullOwner.Properties.textures
		and nbt.SkullOwner.Properties.textures then
			local i = 0
			
			for index, property in pairs(nbt.SkullOwner.Properties) do
				i = i + 1
				if i == 1 then
					if #header > 0 then
						header = parseJson(header:sub(1,-2) .. "," .. (toJson(parseHeader(property[1].Value)):sub(2,-1)))
					else
						header = parseHeader(property[1].Value)
					end
				else
					binary = binary .. property[1].Value
				end
			end
		end
	end
	return header,binary
end





local function display(...)
	label:setText(printTable({...},6,true):gsub("\t",":   "))
end


--────  SKULLS  ────────────────────────────────────────────────────────--

local IDENTITIES = {}
local skulls = {}

local first = false

events.WORLD_RENDER:register(function (delta) first = true end)

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if first then
		first = false
	end
	local hash = ""
	if ctx == "BLOCK" then
		hash = hash .. tostring(block:getPos())
		if skulls[hash] then
		else
			local header,binary = getDataBlock(block)
			skulls[hash] = {
				header = header,
				binary = binary,
			}
		end
	elseif ctx == "HEAD" then
		hash = hash .. item:getName() .. entity:getUUID()
		if skulls[hash] then
		else
			local header,binary = getItemData(item)
			skulls[hash] = {
				header = header,
				binary = binary
			}
		end
	end
	if skulls[hash] then
		display(skulls[hash])
	end
end)



for index, value in ipairs(listFiles("auto.skulls")) do
	local identity = require(value)
	IDENTITIES[identity.id] = identity
end