---@class Plugin.Args
---@field package ["$args"] {[string]: boolean | number | string}
---@field [string] boolean | number | string

local function argnext(t, k) return next(t["$args"], k) end

local argsMT = {
  __index = function(self, k)
    if type(k) ~= "string" then return nil end
    if k:match("[%a_][%w_]*:[%a_][%w_]*") then
      return self["$args"][k]
    elseif k:match("[%a_][%w_]*") then
      return self["$args"]["plugin:" .. k]
    end
    return nil
  end,
  __newindex = function() error("attempt to modify read-only args", 2) end,
  __pairs = function(self) return argnext, self, nil end
}

---@param iargs string[]
---@return Plugin.Args
return function(iargs)
  local args = {}
  for _, iarg in ipairs(iargs) do
    if type(iarg) == "string" then
      local ns, name, value = iarg:match("^([%a_][%w_]*):([%a_][%w_]*) ?= ?(.*)$")
      if not ns then
        ns = "plugin"
        name, value = iarg:match("^([%a_][%w_]*) ?= ?(.*)$")
      end
      if name and value then
        local key = ns .. ":" .. name
        if value == "true" or value == "false" then
          args[key] = value == "true"
        elseif tonumber(value) then
          args[key] = tonumber(value)
        elseif value:match("^([\"']).*%1$") then
          args[key] = value:sub(2, -2)
        else
          args[key] = value
        end
      else
        ns, name = iarg:match("^([%a_][%w_]*):([%a_][%w_]*)$")
        if not ns then
          ns = "plugin"
          name = iarg:match("^([%a_][%w_]*)$")
        end
        if name then
          args[ns .. ":" .. name] = true
        end
      end
    end
  end

  return setmetatable({["$args"] = args}, argsMT)
end
