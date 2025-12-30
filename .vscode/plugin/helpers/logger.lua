
---@type Plugin.Logger
local logger

local debug_enabled = package.loaded["plugin-debug"] ~= nil

local getTable do
  local str_subs = {
    pattern = "[\0\a\b\f\n\r\t\v\"\\]",
    ["\0"] = "\\0", ["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n",
    ["\r"] = "\\r", ["\t"] = "\\t", ["\v"] = "\\v", ["\""] = '\\"', ["\\"] = "\\\\",
  }

  local tgt_subs = {
    pattern = "[\0\a\b\f\n\r\t\v\"\\]",
    ["\n"] = "↲", ["\t"] = "↹",
  }
  local function make_ukey(a, b)
    local root, tgt
    if b == nil then
      tgt = a
      root = ""
    else
      tgt = b
      root = a == nil and "" or (a .. ".")
    end

    local typ = type(tgt)
    if typ == "string" then
      ---@cast tgt string
      tgt = '"' .. tgt:gsub(str_subs.pattern, str_subs) .. '"'
    elseif typ == "table" or typ == "userdata" then
      local name, id = tostring(tgt):match("^(%w+): 0*(%x+)$")
      if id then
        if name == typ then
          local mt = getmetatable(tgt)
          name = type(mt) == "table" and (mt.type or mt.__name or mt.__type) or typ
        end
        tgt = ("%s<0x%" .. ((#id + 3) // 4 * 4) .. "s>"):format(name, id):gsub(" ", "0")
      else
        local mt = getmetatable(tgt)
        if type(mt) == "table" then
          tgt = ("%s<%s>"):format(
            type(mt) == "table" and (mt.type or mt.__name or mt.__type) or "table",
            tostring(tgt):gsub(tgt_subs.pattern, tgt_subs)
          )
        end
      end
    elseif typ == "function" then
      local id = tostring(tgt):match("^function: 0*(%x+)$")
      if id then
        local name = debug.getlocal(tgt, 1) == "self" and "method" or "function"
        tgt = ("%s<0x%" .. ((#id + 3) // 4 * 4) .. "s>"):format(name, id):gsub(" ", "0")
      end
    end

    return root .. ("%s/%s"):format(typ, tostring(tgt))
  end

  local function make_mtinfo(t)
    if type(t) == "string" then return "" end
    local chars = {}
    local mt = getmetatable(t)
    if type(mt) ~= "table" then return mt == nil and "" or " [???]" end

    if mt.__index then chars[#chars+1] = mt.__index == mt and "C" or "I" end
    if mt.__newindex then chars[#chars+1] = "N" end
    if mt.__call then chars[#chars+1] = "F" end
    if mt.__mode then chars[#chars+1] = "W" end
    if mt.__gc then chars[#chars+1] = "G" end
    if mt.__close then chars[#chars+1] = "X" end
    if mt.__tostring then chars[#chars+1] = '"' end
    if mt.__len then chars[#chars+1] = "#" end
    if mt.__pairs then chars[#chars+1] = "p" end
    if mt.__ipairs then chars[#chars+1] = "i" end
    if mt.__unm then chars[#chars+1] = "¬" end
    if mt.__add then chars[#chars+1] = "+" end
    if mt.__sub then chars[#chars+1] = "-" end
    if mt.__mul then chars[#chars+1] = "*" end
    if mt.__div then chars[#chars+1] = "/" end
    if mt.__idiv then chars[#chars+1] = "÷" end
    if mt.__mod then chars[#chars+1] = "%" end
    if mt.__pow then chars[#chars+1] = "^" end
    if mt.__concat then chars[#chars+1] = "." end
    if mt.__bnot then chars[#chars+1] = "!" end
    if mt.__band then chars[#chars+1] = "&" end
    if mt.__bor then chars[#chars+1] = "|" end
    if mt.__bxor then chars[#chars+1] = "~" end
    if mt.__shl then chars[#chars+1] = "«" end
    if mt.__shr then chars[#chars+1] = "»" end
    if mt.__eq then chars[#chars+1] = "=" end
    if mt.__lt then chars[#chars+1] = "<" end
    if mt.__le then chars[#chars+1] = "≤" end

    return #chars > 0 and (" [" .. table.concat(chars, "") .. "]") or " []"
  end

  local sort_order = {
    boolean = 0,
    number = 1,
    string = 2,
    table = 3,
    ["function"] = 4,
    thread = 5,
    userdata = 99
  }
  local sort_method = {
    by_value = function(a, b) return a < b end,
    by_name = function(a, b) return tostring(a) < tostring(b) end
  }
  sort_method[sort_order.boolean] = function(a, b) return a == false or b == true end
  sort_method[sort_order.number] = sort_method.by_value
  sort_method[sort_order.string] = sort_method.by_value
  sort_method[sort_order.table] = sort_method.by_name
  sort_method[sort_order["function"]] = sort_method.by_name
  sort_method[sort_order.thread] = sort_method.by_name
  sort_method[sort_order.userdata] = sort_method.by_name
  local function sort(a, b)
    local atype = sort_order[type(a)] or sort_order.userdata
    local btype = sort_order[type(b)] or sort_order.userdata

    if atype == btype then
      return sort_method[atype](a, b)
    else
      return atype < btype
    end
  end

  ---@param node Plugin.Debug.printNode
  local function getNode(node)
    local k, v = node.key, node.value
    local chld = node.children
    local indent = node.depth

    if chld then
      if #chld <= 0 then
        return ("%s%s: %s%s%s"):format(
          ("  "):rep(indent), make_ukey(k),
          make_ukey(v), make_mtinfo(v), " {<EMPTY>}"
        )
      else
        local strs = {
          ("%s%s: %s%s%s"):format(
            ("  "):rep(indent), make_ukey(k),
            make_ukey(v), make_mtinfo(v), " {"
          )
        }
        for _, cnode in ipairs(chld) do strs[#strs+1] = getNode(cnode) end
        strs[#strs+1] = ("\t"):rep(indent) .. "}"
        return table.concat(strs, "\n")
      end
    end

    return ("%s%s%s: %s%s%s"):format(
      ("  "):rep(indent), node.mtkey and "> " or "", make_ukey(k),
      make_ukey(v), "", ""
    )
  end

  ---@param t any
  ---@param maxdepth? integer
  ---@param aligned? boolean
  ---@param ignored? any[]
  ---@return string?
  function getTable(t, maxdepth, aligned, ignored)
    local strs = {}
    maxdepth = maxdepth or 1

    if type(t) ~= "table" or maxdepth <= 0 then
      return make_ukey(t)
    end

    ---@type {[string]: string | true}
    local DONE = {t = "//ROOT//"}
    if ignored then for _, value in ipairs(ignored) do DONE[value] = true end end

    ---@type Plugin.Debug.printNode
    local TREE = {key = "//ROOT//", value = t, children = {}, depth = 0}

    ---@type Plugin.Debug.printNode[]
    local NEXT = {TREE}

    ---@type any, unknown, Plugin.Debug.printNode[]?, any[], any[], any, Plugin.Debug.printNode, integer
    local tbl, mt, tgt, keys, mtkeys, v, vnode, nextdepth
    for i, node in ipairs(NEXT) do
      if i == 1024 then
        logger:warn("Possible runaway table print! (Hit 1024 nodes!)")
      elseif i == 2048 then
        logger:error("Dangerous amount of nodes hit, denying print! (Hit 2048 nodes!)\nConsider lowering the depth.")
        return
      end
      tbl = node.value
      mt = type(tbl) ~= "string" and getmetatable(tbl)
      tgt = node.children
      DONE[tbl] = true

      keys = {}
      for k in pairs(tbl) do keys[#keys+1] = k end
      table.sort(keys, sort)

      mtkeys = {}
      if type(mt) == "table" and type(mt.__index) == "table" then
        for k in pairs(mt.__index) do
          if rawget(tbl, k) == nil then mtkeys[#mtkeys+1] = k end
        end
        table.sort(mtkeys, sort)
      end

      nextdepth = node.depth + 1
      for _, k in ipairs(keys) do
        v = tbl[k]

        if type(v) == "table" and not DONE[v] and nextdepth < maxdepth then
          ---@type Plugin.Debug.printNode
          vnode = {key = k, value = v, children = {}, depth = nextdepth}
          tgt[#tgt+1] = vnode
          NEXT[#NEXT+1] = vnode
        else
          tgt[#tgt+1] = {key = k, value = v, depth = nextdepth}
        end
      end

      for _, k in ipairs(mtkeys) do
        tgt[#tgt+1] = {key = k, value = mt[k], mtkey = true, depth = nextdepth}
      end
    end

    if #TREE.children <= 0 then
      strs[#strs+1] = make_ukey(t) .. make_mtinfo(t) .. " {<EMPTY>}"
    else
      strs[#strs+1] = make_ukey(t) .. make_mtinfo(t) .. " {"
      for _, node in ipairs(TREE.children) do strs[#strs+1] = getNode(node) end
      strs[#strs+1] = "}"
    end

    if aligned then return table.concat(strs, "\n") end
    return #strs > 1 and ("\n" .. table.concat(strs, "\n")) or strs[1] or ""
  end
end


---A logger instance.
---@class Plugin.Logger
--- The name used by this logger.
---@field name string
--- The line template used by this logger.
---@field line string
local Logger = {
  name = "unnamed",
  line = "${icon} [${time}] [${cname}/${level}]${spacing}",
  cont = "${align}",
  tblcont = "${icon}    ",
  --- The icons used by this logger.
  icon = {DEBUG = "⚙", TABLE = "📦", INFO = "ℹ", WARN = "⚠", ERROR = "❌", CONTINUE = "⬛"}
}
local LoggerMT = {__index = Logger}
local LoggerIconMT = {__index = Logger.icon}

--- This library's own logger.
logger = setmetatable({name = "logger"}, LoggerMT)

---@package
function Logger:_print(level, fmt, ...)
  local str = ((type(fmt) == "string" and select("#", ...) > 0)
    and fmt:format(...)
    or tostring(fmt)
  ):gsub("\r\n", "\n")

  local SPACING <const> = 20
  local clipped_name = ((#self.name + #level) > SPACING)
    and (self.name:sub(1, SPACING - 1) .. "…")
    or self.name

  local time = os.date("%H:%M:%S")
  local line = self.line:gsub("%${(.-)}", {
    icon = self.icon[level],
    time = time,
    name = self.name,
    cname = clipped_name,
    level = level,
    spacing = (" "):rep(math.max(2, SPACING - #self.name - #level + 2))
  })

  local cont_template = level == "TABLE" and self.tblcont or self.cont

  if cont_template == "${align}" then
    local PATTERN <const> = "[\x00-\x08\x0A-\x1F\x21-\x7F\xC2-\xF4][\x80-\xBF]*"

    if str:find("\n", nil, true) then
      local cont = line:match("[^\n]*$")
      local icon_s, icon_e = cont:find(self.icon[level], 1, true)
      if icon_s then
        str = str:gsub(
          "\n",
          "\n" .. cont:sub(1, icon_s - 1):gsub(PATTERN, " ")
          .. self.icon.CONTINUE
          .. cont:sub(icon_e + 1):gsub(PATTERN, " ")
        )
      else
        str = str:gsub("\n", "\n" .. cont:gsub(PATTERN, " "))
      end
    end
  elseif str:find("\n", nil, true) then
    local cont = cont_template:gsub("%${(.-)}", {
      icon = self.icon.CONTINUE,
      time = time,
      name = self.name,
      cname = clipped_name,
      level = level
    })

    str = str:gsub("\n", "\n" .. cont)
  end

  if str:match("^%s-\n") then
    print(line:gsub("(\n?)%s-$", "%1") .. str)
  else
    print(line .. str)
  end
end

---Logs a debug message.
---
---This only works if the `debug-plugin.lua` file exists in the plugin root.
---@param fmt any
---@param ... any
function Logger:debug(fmt, ...)
  if not debug_enabled then return end
  self:_print("DEBUG", fmt, ...)
end

---Logs a table.
---
---This only works if the `debug-plugin.lua` file exists in the plugin root.
---@param tbl any
---@param maxdepth? integer
---@param ignored? any[]
function Logger:table(tbl, maxdepth, ignored)
  if not debug_enabled then return end
  local str = getTable(tbl, maxdepth, self.tblcont == "${align}", ignored)
  if str then self:_print("TABLE", str) end
end


---Logs an info message.
---@param fmt any
---@param ... any
function Logger:info(fmt, ...)
  self:_print("INFO", fmt, ...)
end


---Logs a warning message.
---@param fmt any
---@param ... any
function Logger:warn(fmt, ...)
  self:_print("WARN", fmt, ...)
end


---Logs an error message.
---@param fmt any
---@param ... any
function Logger:error(fmt, ...)
  self:_print("ERROR", fmt, ...)
end


local cache = {}

---@param name string
---@return Plugin.Logger
return function(name)
  if cache[name] then return cache[name] end

  local obj = setmetatable({
    name = name,
    icon = setmetatable({}, LoggerIconMT)
  }, LoggerMT)

  cache[name] = obj
  return obj
end
