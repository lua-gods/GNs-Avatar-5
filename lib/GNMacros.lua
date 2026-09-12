---@diagnostic disable: undefined-field
--[[______   __
  / ____/ | / / Name: GN MACROS LIBRARY v2.0.0 public beta
 / / __/  |/ /  Desc: encapsulates events and initialization into a togglable macro.
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- GN Event > https://discord.com/channels/1129805506354085959/1492967289312641095
]]
local Event = require("./GNEvent") ---@type GN.Event

---@class GN.MacrosRewriteAPI
local MacrosAPI = {}

---@alias GN.MacrosRewrite.init fun(events: GN.MacrosRewrite.EventsAPI,...:any)

---@class GN.MacrosRewrite
---@field active boolean
---@field init GN.MacrosRewrite.init
---@field events GN.MacrosRewrite.EventsAPI?
---@field hooks table<string,function[]>
local Macros = {}
Macros.__index = Macros


---@class GN.MacrosRewrite.EventsAPI : EventsAPI
---@field ON_EXIT GN.Event

local eventsMetatable = {}

eventsMetatable.__index = function(self, index)
	index = tostring(index):lower()
	local out = rawget(self, tostring(index):lower())
	if not out then
		local owner = rawget(self, "owner")
		
		local event = Event.new()
		local hook = function(...)
			if owner.active then -- avoids events like tick from triggering after ON_EXIT
				local out = event:invoke(...)
				return out[next(out)] ---TODO: find a better way to handle this
			end
		end
		
		if events[index] then
			owner.hooks[index] = owner.hooks[index] or {}
			local hooks = owner.hooks[index]
			hooks[#hooks + 1] = hook
			
			events[index]:register(hook)
		end
		
		rawset(self, index, event)
		return event
	end
	return out
end

---@param init GN.MacrosRewrite.init
---@return GN.MacrosRewrite
function MacrosAPI.new(init)
	local self = {
		active = false,
		init = init,
		isActive = false,
		hooks = {},
	}

	setmetatable(self, Macros)
	return self
end

function Macros:setActive(active,...)
	if self.active ~= active then
		self.active = active
		if active then
			local fakeEvents = setmetatable({ owner = self }, eventsMetatable)
			self.events = fakeEvents
			self.init(fakeEvents,...)
			local function entityInitHandler()
				if self.events.ENTITY_INIT then
					self.events.ENTITY_INIT:invoke()
				end
				events.TICK:remove(entityInitHandler)
			end
			events.TICK:register(entityInitHandler)
		else
			for name, funs in pairs(self.hooks) do
				for _, fun in pairs(funs) do
					events[name]:remove(fun)
				end
			end
			
			if self.events.ON_EXIT then
				self.events.ON_EXIT:invoke()
			end
			
			self.events = nil
			self.hooks = {}
		end
	end
end

return MacrosAPI
