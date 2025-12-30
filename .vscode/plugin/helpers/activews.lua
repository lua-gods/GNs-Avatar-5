local scope = require("workspace.scope")

local FALLBACK = "<fallback>"

---@class Plugin.ActiveWS
---@field package args {[string]: Plugin.Args}
---@field package stack [string, {[1]: integer}][]
local this = {
  stack = {},
  args = {[FALLBACK] = {}},
  FALLBACK = FALLBACK
}

---Holds a workspace in scope until it is closed.
---
---Can be closed early with `:close()` if needed.
---@class Plugin.ActiveWS.Scope
local Scope = {}
local ScopeMT = {
  __index = Scope,

  ---@param self Plugin.ActiveWS.Scope
  __close = function(self)
    if self[1] and self[1][1] then
      table.remove(this.stack, self[1][1])
      for i = self[1][1], #this.stack do
        this.stack[i][2][1] = i
      end
    end
  end
}

function Scope:close()
  ScopeMT.__close(self)
  self[1] = nil
  setmetatable(self, nil)
end

---Gets the currently active workspace.
---
---Returns `"<fallback>"` if no workspace is active.
---@return string uri
---@nodiscard
function this.get() return #this.stack > 0 and this.stack[#this.stack][1] or FALLBACK end

---Gets the arguments of the currently active workspace.
---@return Plugin.Args
---@nodiscard
function this.getArgs() return this.args[this.get()] end

---Adds the given workspace to the stack and returns a closable "scope" object.
---
---Once the scope object is closed it will automatically remove its active workspace from the stack.
---@param uri? string
---@return Plugin.ActiveWS.Scope
---@nodiscard
function this.set(uri)
  local ws_uri = scope.getScope(uri).uri

  local next_i = #this.stack + 1
  local index = {next_i}
  local ws_scope = setmetatable({index}, ScopeMT)
  this.stack[next_i] = {ws_uri, index}
  return ws_scope
end

return this
