
---@class GN.KeymapAPI
local KeymapAPI = {}

local registry = {}

local KEYBIND_LOOKUP = {}
local key = keybinds:newKeybind(".","key.keyboard.a")
for _, keyString in ipairs(client.getEnum("keybinds")) do
	KEYBIND_LOOKUP[keyString] = key:setKey(keyString):getID()
end


---@class GN.Keymap
local Keymap = {}
Keymap.__index = Keymap


---@param fun fun():boolean?
function Keymap:onPress(fun)
	self.press = fun
end


---@param fun fun():boolean?
function Keymap:onRelease(fun)
	self.release = fun
end


local id = 0
---@param ... Minecraft.keyCode
---@return GN.Keymap
function KeymapAPI:newKeymap(...)
	local pos = registry
	id = id + 1
	-- locate or pave the path to the key
	for _, stringName in ipairs{...} do
		local id = KEYBIND_LOOKUP[stringName]
		pos[id] = pos[id] or {back=pos}
		pos = pos[id]
	end
	
	local self = {}
	setmetatable(self, Keymap)
	pos.keymaps = pos.keymaps or {}
	local keymapID = #pos.keymaps+1
	pos.keymaps[keymapID] = self
	return self
end

local registryPos = {}

local depth = 0
events.KEY_PRESS:register(function (key, state, modifiers)
	if state == 1 then
		if not registryPos[key] then
			registryPos[key] = {back=registryPos}
		end
		registryPos = registryPos[key]
		local capture
		if registryPos.keymaps then
			for key, value in pairs(registryPos.keymaps) do
				if value.press then
					capture = capture or value.press()
				end
			end
		end
		depth = depth + 1
		return capture
	elseif state == 0 then
		local capture
		if registryPos.keymaps then
			for key, value in pairs(registryPos.keymaps) do
				if value.release then
					capture = capture or value.release()
				end
			end
		end
		depth = depth - 1
		registryPos = registryPos.back or registry
		if depth == 0 then
			registryPos = registry
		end
		return capture
	end
end)


return KeymapAPI