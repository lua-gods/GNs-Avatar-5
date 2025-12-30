
---Miscellaneous utility functions used by the base plugin.
---@class Plugin.Util
local this = {}

---Removes newlines from a multi-line string. Use literal `\n` to add a newline instead.
---
---If the string is not multi-line, this does nothing.
---@param str string
---@return string
function this.nonewlines(str)
  if not (str and str:match("^[ \t]")) then return str end
  return (str
    :gsub("^[ \t]*", "")
    :gsub("\r?\n[ \t]*", "")
    :gsub("\\n", "\n"))
end

---Removes base indentation from a multi-line string.
---
---If the string is not multi-line, this does nothing.
---@param str string
---@return string
function this.reindent(str)
  if not (str and str:match("^[ \t]")) then return str end
  local sp = "\r?\n" .. str:match("^([ \t]*)"):gsub("(.)", "%1?")
  return (str
    :gsub("^[ \t]*", "")
    :gsub(sp, "\n")
    :gsub("\r?\n[ \t]*$", ""))
end

---Escapes text for use in HTML titles.
---@param str string
---@return string
function this.escapetitle(str)
  return str and str:gsub("\r?\n", "&#10;"):gsub('"', "&#34;") or str
end

---Creates a set from an array.
---@generic T
---@param arr T[]
---@return Set<T>
function this.set(arr)
  local ret = {}
  for i = 1, #arr do ret[arr[i]] = true end
  return ret
end

---Inserts reversed (value-key) pairs from the key-value pairs currently in the table.
---@generic K, V
---@param tbl {[K]: V}
function this.enum(tbl)
  local temp = {}
  for k, v in pairs(tbl) do temp[v] = k end
  for k, v in pairs(temp) do tbl[k] = v end
end

---Gets an upvalue from a function by name.
---
---Returns `nil` if no upvalue with the name was found.
---@param f function
---@param n string
---@return integer?
---@return any
function this.getupvalue(f, n)
  local name, value
  for i = 1, 255 do
    name, value = debug.getupvalue(f, i)
    if name == n then return i, value end
    if name == nil then break end
  end

  return nil
end

---Sets an upvalue from a function by name.
---
---Returns `nil` if no upvalue with the name was found.
---@param f function
---@param n string
---@param v any
---@return integer? index
function this.setupvalue(f, n, v)
  local name
  for i = 1, 255 do
    name = debug.getupvalue(f, i)
    if name == n then
      debug.setupvalue(f, i, v)
      return i
    end
    if name == nil then break end
  end

  return nil
end


return this
