--[[______   __
  / ____/ | / / Name: GN SKULL LIBRARY v1.0.0
 / / __/  |/ /  Desc: an API for skulls, idk how to describe this lmao
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]

--──── CONFIG ────────────────────────────────────────────--

local SKULL_PARTS = models:newPart("Skulls", "SKULL")
local BINARY_CHUNK_SIZE = 32000-1
local DISCARD_THRESHOLD = 5
--──── AUTO CONFIG ────────────────────────────────────────────--
-- leave these alone unless you know what youre doing
local IS_NEW = 0 < client.compareVersions(client:getVersion(), "1.20.1")

--──── COMMENTS ────────────────────────────────────────────--

--[=[ GN Skull data Specification
- the data is scraped and sterilized in the following order for each entry:
HEADER:
	1. NAME
		- name is converted to a json string
		- apple,banana,manderine={count=5} -> {"apple","banana","manderine"={"count"=5}}
	2. PROFILE PROPERTIES (aka textures)
		- texture 2 is converted from a base64 to a json string
		- if name entry exists, both are joined together into a single json
BINARY:
	2. PROFILE PROPERTIES (aka textures)
		- texture 3 and beyond are concatinated into one entry,
		  after being converted back from a base64

--- END OF SPECIFICATION

I chose this layout to allow for skulls to each have their own config header
to tell instructions, while also allowing for binary compressed data to be stored
alongside the same skull

texture 1 is left alone to keep the player head from rendering with a default skin

--]=]



---@class GN.SkullAPI
local SkullAPI = {}

--──── DEFINITIONS ────────────────────────────────────────────--
---@class GN.Skull.Identity
---@field id string
---@field init  fun(skull: GN.Skull.Instance, cfg: table)?
---@field frame fun(skull: GN.Skull.Instance, cfg: table, dt: number, df: number)?
---@field world_frame fun(skull: GN.Skull.Instance, cfg: table, dt: number, df: number)?
---@field tick  fun(skull: GN.Skull.Instance, cfg: table)?
---@field exit  fun(skull: GN.Skull.Instance, cfg: table)?

---@class GN.Skull.Instance
---@field ctx Event.SkullRender.context
---@field hash string
---@field model ModelPart
---@field header table<string,table>
---@field binary string
---@field package id integer?
---@field block BlockState?
---@field item ItemStack?
---@field entity LivingEntity?

---@alias GN.Skull.Context string
---| "BLOCK"
---| "HEAD"
----| "ITEM"
----| "FIRST_PERSON"

local label = SKULL_PARTS:newText("label")
	 :scale(0.25)
	 :pos(-8, 16, 0)
	 :background(true)
	 :backgroundColor(0, 0, 0, 0.5)
SKULL_PARTS:newBlock("dirt"):block("dirt"):scale(0, 0, 0)

--────  Utilities  ────────────────────────────────────────────────────────--

---@param string string
---@return string
local function parseBase64(string)
	local buffer = data:createBuffer(#string)
	buffer:writeBase64(string)
	buffer:setPosition(0)
	local out = buffer:readByteArray(buffer:available())
	buffer:close()
	return out
end


---@param string string
---@return string
local function toBase64(string)
	local buffer = data:createBuffer(#string)
	buffer:writeByteArray(string)
	buffer:setPosition(0)
	local out = buffer:readBase64(buffer:available())
	buffer:close()
	return out
end


local function _recursiveComponent(text, component)
	if component.text then
		text = text .. component.text
	end

	if component.extra then
		for _, extra in ipairs(component.extra) do
			text = text .. _recursiveComponent(text, extra)
		end
	end

	return text
end


---Converts raw json text to the final output text
---@param rawJsonText any
---@return unknown
local function toPlainText(rawJsonText)
	local ok, result = pcall(parseJson, rawJsonText)
	if ok then
		if type(result) == "table" then
			return _recursiveComponent("", result)
		else
			return result
		end
	else
		return rawJsonText
	end
end


--- apple,banana,carrot={color="glue"}
---
--- turns into
---
--- apple={},banana={},carrot={color='glue'}
---@param name string
---@return string
local function parseName(name)
	local output = toPlainText(name) .. ","
	local hasNoCasing = false
	if not output:find("^{") then
		output = "{" .. output
		hasNoCasing = true
	end

	output = output
		 :gsub("([%a_][%w_]*)%s*,", "%1={},")
		 :gsub("^([%a_][%w_]*)%s*,", "%1={},")
		 :gsub(",%s*([%a_][%w_]*)%s*=", ",%1=")

	output = output:sub(1, -2)

	if hasNoCasing then
		output = output .. "}"
	end

	return output
end


---@param base64 string
---@return any
local function parseHeader(base64)
	local ok, result = pcall(parseBase64, base64)
	if ok then
		return result
	end
	return {}
end


---@param item ItemStack
---@return string,string
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
				if index == 2 then
					-- header reader, not related
				elseif index > 2 then
					binary = binary .. parseBase64(property.value)
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
				if i == 2 then
					if #header > 0 then
						header = (header:sub(1, -2) ..
							"," .. (toJson(parseHeader(value[1].Value)):sub(2, -1)))
					else
						header = parseHeader(value[1].Value)
					end
				elseif i > 2 then
					binary = binary .. parseBase64(value[1].Value)
				end
			end
			return header, binary
		end
	end
	return header, binary
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
				if index == 2 then
					if #header > 0 then
						-- badly stitch together two json tables
						header = (header:sub(1, -2) ..
							"," .. (toJson(parseHeader(property.value)):sub(2, -1)))
					else
						header = parseHeader(property.value)
					end
				elseif index > 2 then
					binary = binary .. parseBase64(property.value)
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
				if i == 2 then
					if #header > 0 then
						header = (header:sub(1, -2) ..
							"," .. (toJson(parseHeader(property[1].Value)):sub(2, -1)))
					else
						header = parseHeader(property[1].Value)
					end
				elseif i > 2 then
					binary = binary .. parseBase64(property[1].Value)
				end
			end
		end
	end
	--printTable(header,5)
	return header, binary
end

function SkullAPI.makeSkull(header, binary)
	local item =
	[=[minecraft:player_head[profile={id:[I;-457632696,995642399,-2093362161,1978444996],properties:%s}]]=]
	local properties = ""

	local function addEntry(name, value)
		properties = properties .. "{name:'" .. name .. "',value:'" .. value .. "'},"
	end

	addEntry("textures",
		"e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGYzMjNiYzk4Nzk2MGExNjQxYmY3MGIzNDIxNDY2NGRlOWEyM2NjNGIxNDRjMzNhZWYxZjlmYzYyMDg2NTA1NyJ9fX0=")


	if header then
		addEntry("textures1", toBase64(toJson(header)))
	end
	local c = 0
	if binary then
		for i = 1, #binary, BINARY_CHUNK_SIZE do
			c = c + 1
			addEntry("textures" .. c, toBase64(binary:sub(i, i + BINARY_CHUNK_SIZE - 1)))
			if c > 16-2 then
				print("ERROR: Reached max binary texture size")
				return
			end
		end
	end
	print(c,"textures")
	properties = "[" .. properties:sub(1, -2):gsub("'", '"') .. "]"
	host:setClipboard("count: " .. c)
	item = item:format(properties)
	print(#item,"size")
	if #item > 512000 then
		print("ERROR: Head size too big")
		return
	end
	return item
end

--──── DEBUG ────────────────────────────────────────────--


local function display(...)
	if #{ ... } > 0 then
		--label:setText(printTable({ ... }, 6, true):gsub("\t", ":   "))
	end
	label:setText(select(1, ...))
end


--────  SKULLS  ────────────────────────────────────────────────────────--

---@type table<string,GN.Skull.Identity>
local IDENTITIES = {}
---@type table<string,GN.Skull.Instance>
local skulls = {}

---@type table<string,GN.Skull.Instance[]>
local identityInstances = {}
local blockInstances = {}
local etcInstances = {}

local lastModel

local first = false

local time = 0

local deltaFrame = 0
events.WORLD_RENDER:register(function(delta)
	first = true
end)


if true then
	events.ON_PLAY_SOUND:register(function(id, pos, volume, pitch, loop, category, path)
		if path and id == "minecraft:block.stone.break" then
			local breakLocation = tostring(pos:floor())
			if skulls[breakLocation] then
				if not world.getBlockState(pos).id:find("head$") then
					local instance = skulls[breakLocation]
					skulls[breakLocation] = nil
					if instance then
						for name, cfg in pairs(instance.header) do
							if IDENTITIES[name] and IDENTITIES[name].exit then
								IDENTITIES[name].exit(instance, cfg)
							end
							identityInstances[name][instance.hash] = nil
						end
					end
				end
			end
		end
	end)
end

local lastSystemTime = client:getSystemTime()
local lastTickTime = 0
events.SKULL_RENDER:register(function(delta, block, item, entity, ctx)
	if first then
		first = false
		time = time + 1

		local systemTime = client:getSystemTime()
		deltaFrame = (systemTime - lastSystemTime) / 1000
		lastSystemTime = systemTime
		
		local tick = world.getTime()
		if (tick ~= lastTickTime) then
			lastTickTime = tick
			for name, instances in pairs(identityInstances) do
				local identity = IDENTITIES[name]
				for key, instance in pairs(instances) do
					if identity.tick then
						identity.tick(instance, instance.header[name] or {})
					end
				end
			end
		end

		if delta == 1 then -- edge case where skull has no delta tick
			delta = client:getFrameTime()
		end
		for name, instances in pairs(identityInstances) do
			local identity = IDENTITIES[name]
			for key, instance in pairs(instances) do
				if identity.world_frame then
					identity.world_frame(instance, instance.header[name] or {}, delta, deltaFrame)
				end
			end
		end

		for key, instance in pairs(blockInstances) do
			if time - instance.lastSeen > DISCARD_THRESHOLD then
				local pos = instance.pos
				local breakLocation = tostring(pos:floor())

				if skulls[breakLocation] then
					if not world.getBlockState(pos).id:find("head$") then
						local instance = skulls[breakLocation]
						if instance then
							skulls[breakLocation] = nil
							instance.model:remove()
							skulls[instance.hash] = nil
							for name, cfg in pairs(instance.header) do
								if IDENTITIES[name].exit then
									IDENTITIES[name].exit(instance, cfg)
								end
								identityInstances[name][instance.hash] = nil
							end
						end
					end
				end
			end
		end

		for key, instance in pairs(etcInstances) do
			if time - instance.lastSeen > DISCARD_THRESHOLD then
				instance.model:remove()
				skulls[instance.hash] = nil
				for name, cfg in pairs(instance.header) do
					if IDENTITIES[name].exit then
						IDENTITIES[name].exit(instance, cfg)
					end
					identityInstances[name][instance.hash] = nil
					etcInstances[instance.hash] = nil
				end
			end
		end
	end
	if lastModel then
		lastModel:setVisible(false)
	end
	local hash = ""
	if ctx == "BLOCK" then
		hash = tostring(block:getPos())
		if skulls[hash] then
			local instance = skulls[hash]
			instance.model:setVisible(true)
			lastModel = instance.model
			instance.block = block
			instance.lastSeen = time
			
			for name, cfg in pairs(instance.header) do
				local identity = IDENTITIES[name]
				if identity.frame then
					identity.frame(instance, cfg or {}, delta, deltaFrame)
				end
			end
			
		else
			local header, binary = getDataBlock(block)
			local ok, result = pcall(parseJson, header)
			if ok then
				header = result
			else
				header = nil
			end
			header = header or { default = {} }

			local instance = {
				header = header,
				hash = hash,
				pos = block:getPos(),
				model = SKULL_PARTS:newPart(hash):setVisible(false),
				binary = binary,
				ctx = ctx,
				block = block,
				lastSeen = time,
			}
			blockInstances[hash] = instance
			skulls[hash] = instance

			for name, value in pairs(header) do
				local identity = IDENTITIES[name]
				if identity then
					if identity.init then
						identity.init(instance, instance.header[name] or {})
					end
					identityInstances[name] = identityInstances[name] or {}
					identityInstances[name][hash] = instance
				end
			end
		end
	elseif item then
		hash = hash .. item:toStackString() .. (entity and entity:getUUID() or "")
		if skulls[hash] then
			local instance = skulls[hash]
			instance.model:setVisible(true)
			lastModel = instance.model
			instance.lastSeen = time
		else
			local header, binary = getItemData(item)
			local ok, result = pcall(parseJson, header)
			if ok then
				header = result
			else
				header = nil
			end
			header = header or { default = {} }

			local instance = {
				header = header,
				hash = hash,
				model = SKULL_PARTS:newPart(hash):setVisible(false),
				binary = binary,
				ctx = ctx,
				item = item,
				entity = entity,
				lastSeen = time,
			}
			etcInstances[hash] = instance
			skulls[hash] = instance

			for name, value in pairs(header) do
				local identity = IDENTITIES[name]
				if identity then
					if identity.init then
						identity.init(instance, instance.header[name] or {})
					end
					identityInstances[identity.id][hash] = instance
				end
			end
		end
	end
	--display(avatar:getCurrentInstructions()-benchmark-5) -- END OF BENCHMARK
end)


--────  IDENTITY_LOADER  ────────────────────────────────────────────────────────--

---@param entry GN.Skull.Identity
function SkullAPI.newIdentity(entry)
	local identity = entry
	IDENTITIES[identity.id] = identity
	identityInstances[identity.id] = {}
end

return SkullAPI
