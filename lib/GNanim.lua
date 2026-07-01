local GNanimAPI = {}

---@alias AnimationGroup.Selector fun(self:AnimationGroup)

---@type table<string,AnimationGroup.Selector>
local SELECTORS = {
	ALL = function (self)
		for index, value in ipairs(self.entries) do
			value:play()
		end
	end,
	ROUND_ROBIN = function (self)
		if self.last then
			self.last:stop()
		end
		self.i = self.i and ((self.i + 1) % #self.entries) or 0
		self.last = self.entries[self.i + 1]:play()
	end
}

---@alias AnimationGroup.Selector.Preset string
---| "ALL"
---| "ROUND_ROBIN"

---@class AnimationGroup : Animation
---@field package selector AnimationGroup.Selector
---@field package entries Animation[]
local AnimationGroup = {}
AnimationGroup.__index = function (t,i)
	local entries = rawget(t,"entries")
	local out = rawget(t,i)
	if out then
		return out
	elseif AnimationGroup[i] then
		return AnimationGroup[i]
	elseif type(i) == "number" then
		return entries[i]
	else
		if entries[1][i] then
			return function (self,...)
				-- getter handler, only handle one
				local out = entries[1][i](entries[1],...)
				if type(out) ~= "Animation" then
					return out
				end
				-- setter handler, apply to the rest
				for j = 2, #entries, 1 do
					local v = entries[j]
					v[i](v,...)
				end
				return t
			end
		end
	end
end

function AnimationGroup:play()
	if self.selector then
		self.selector(self)
	end
	return self
end

---@param selector AnimationGroup.Selector.Preset | AnimationGroup.Selector
---@param ... Animation|Animation[]
---@return AnimationGroup
function GNanimAPI.newGroup(selector,...)
	local t = type(selector)
	if t == "function" then
		selector = SELECTORS[selector]
	elseif t == "string" then
		selector = SELECTORS[selector]
	else
		error("invalid selector type: " .. t, 2)
	end
	local first = select(1,...)
	local list
	if type(first) == "table" then
		list = first
	else
		list = {...}
	end

	local self = {
		mode = 0,
		selector = selector,
		entries = list,
	}
	
	return setmetatable(self,AnimationGroup)
end


return GNanimAPI