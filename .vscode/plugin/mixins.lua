---@diagnostic disable: undefined-global

---@type string, string
local _, path = ...

local fs = require("bee.filesystem")
local bce = require("bce")
local mixins_path = path:gsub("[^/]+$", "mixins")

local logger = require("helpers.logger")("mixins")


--[[ OBJECT ID FORMAT

(* Meta identifiers *)
ALL-CHARACTERS = ? All unicode characters ?;
LETTER = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R"
       | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j"
       | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z";
DIGIT = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0";
IDENTIFIER = (LETTER | "_" | "-"), {LETTER | DIGIT | "_"};
INTEGER = DIGIT, {DIGIT};

object-id = module, {redirect};

module = "'", (ALL-CHARACTERS - "'"), {ALL-CHARACTERS - "'"}, "'";

redirect = table-field | table-index | upvalue-name | upvalue-index | local-name | local-index | metatable-access;

table-field = ".", IDENTIFIER;
table-index = "[", ((["-"], INTEGER) | ("'", {ALL-CHARACTERS - "'"}, "'")), "]";
upvalue-name = "^", IDENTIFIER;
upvalue-index = "^", INTEGER;
metatable-access = "@", [IDENTIFIER];
]]--

local function noop() end

---@type {[string]: any}
local object_cache = setmetatable({}, {__mode = "v"})

---@param reason string
---@param str string
local function objid_error(reason, str)
  error(reason .. "\n  HERE -> " .. str, 4)
end

---Gets the object associated with the given object id.  
---Object id syntax is defined below:
---* All object ids must start with a module name surrounded in single quotes.  
---  `'module_name'`
---* After the module name is a number of "redirectors" that inform the mixin where to find the object.
---  * Accessing a table field can be done by adding a dot followed by a normal Lua identifier.  
---    `.identifier`
---  * Table indexing can be done by surrounding a number or single-quoted string in square brackets.  
---    `[123]`, `['string-value']`
---  * Upvalues of functions can be accessed by adding a caret followed by either an index number or Lua identifier.  
---    `^4`, `^plugin`
---  * Metatables can be accessed by adding an at-sign. If a Lua identifier is added then that metatable field will be
---    accessed.  
---    `@`, `@__index`
---
---If only a module name is given then that module name is returned.
---
---Functions may only be returned if `strict` is not set.
---@param str string
---@param strict? false
---@return table | function | string
---@overload fun(str: string, strict: true): (table | string)
local function get(str, strict)
  local ostr = str
  local is_module = false

  if object_cache[str] ~= nil then return object_cache[str] end
  ---@type string, unknown
  local objid, obj
  for cacheid, cache in pairs(object_cache) do
    if str:sub(1, #cacheid) == cacheid then
      objid = cacheid
      str = str:sub(1 + #objid)
      obj = cache
      break
    end
  end

  if not obj then
    objid, obj, str = str:match("^('([^']+)')(.*)")
    if not objid then
      objid_error("could not find module id", ostr)
    end
    local s
    s, obj = pcall(require, obj)
    if not s then objid_error("could not get module: " .. obj, str) end
    is_module = true
  end

  while str ~= "" do
    is_module = false
    local peek = str:sub(1, 1)
    -- Common variables
    ---@type string, string
    local opart, id
    if peek == "." then
      opart, id = str:match("^(%.([%a_][%w_]*))")
      if not id then objid_error("failed to get identifier", str) end
      obj = obj[id]
      if obj == nil then objid_error("no object exists at field", str) end

    elseif peek == "[" then
      if str:sub(2, 2) == "'" then
        opart, id = str:match("^(%['([^']*)'])")
        if not id then objid_error("failed to get string", str) end
        obj = obj[id]
      else
        opart, id = str:match("^(%[(%-?%d+)])")
        if not id then objid_error("failed to get integer", str) end
        obj = obj[tonumber(id)]
      end
      if obj == nil then objid_error("no object exists at index", str) end
    elseif peek == "^" then
      opart, id = str:match("^(^(%d+))")
      if id then
        if type(obj) ~= "function" then
          objid_error("attempt to get upvalue of " .. type(obj) .. " value", str)
        end
        obj = debug.getupvalue(obj, tonumber(upvalue))
        if obj == nil then objid_error("no upvalue exists at index", str) end
      else
        opart, id = str:match("^(^([%a_][%w_]*))")
        if not id then objid_error("failed to get integer or identifier", str) end

        local name, value
        for i = 1, 255 do
          name, value = debug.getupvalue(obj, i)
          if name == nil then objid_error("no upvalue exists with name", str) end
          if name == id then break end
        end
        obj = value
      end
    elseif peek == "@" then
      opart, id = str:match("^(@([%a_][%w_]*))")
      if id then
        local mt = getmetatable(obj)
        if mt == nil then objid_error("object does not have a metatable", str) end
        if type(mt) ~= "table" then objid_error("object has hidden metatable", str) end
        obj = mt[id]
        if obj == nil then objid_error("no object exists at metatable field", str) end
      else
        local mt = getmetatable(obj)
        if mt == nil then objid_error("object does not have a metatable", str) end
        if type(mt) ~= "table" then objid_error("object has hidden metatable", str) end
      end
    else
      objid_error("unknown symbol", str)
    end

    objid = objid .. opart
    object_cache[objid] = obj
    str = str:sub(1 + #opart)
  end

  local tobj = type(obj)
  if strict then
    if not (is_module or tobj == "table") then
      error("object id does not result in a table or module", 3)
    end
  elseif not (is_module or tobj == "table" or tobj == "function") then
    error("object id does not result in a table, function, or module", 3)
  end

  if is_module and type(obj) ~= "table" then obj = ostr:match("^'([^']+)'$") end
  return obj
end

---@class Plugin.Mixins.Annotation
---@field action string
---@field package [Plugin.Mixins.AnnotationSymbol] metatable
---@field package _mixin Plugin.Mixins.Mixin
---@field package _params string[]
---@field package _values any[]
---@field package _str string

---For internal use.
---@class Plugin.Mixins.AnnotationSymbol
local Annotation = {}

local paramtypes = {
  none = {},
  any = {"any"},
  func = {"function"}
}

local function anno_tostring(self)
  return self._str:gsub("${([%w+]+)}", function(k)
    local v = self[k]
    return v == nil and "???" or tostring(v)
  end)
end

local anno_mt_none = {
  __call = function(self)
    return setmetatable({_values = {}}, self[Annotation])
  end,
  __tostring = anno_tostring
}
local anno_mt_target = {
  __call = function(self, target)
    return setmetatable({target = target, _values = {}}, self[Annotation])
  end,
  __tostring = anno_tostring
}

-----==============================================================================================================-----
-----=====  ANNOTATIONS                                                                                       =====-----
-----==============================================================================================================-----

---Sets the options for this mixin.
---* `priority`: Sets the priority of this mixin. Mixins with higher priority run later. Default priority is 0
---
---&nbsp;  
---Annotates 0 values.
---@class Plugin.Mixins.Annotation.Options: Plugin.Mixins.Annotation
---@field action "Options"
---@field priority integer
---@overload fun(opts: Plugin.Mixins.MixinOptions): Plugin.Mixins.Annotation.Options
---@annotation
local Options = (setmetatable({
  [Annotation] = {__tostring = anno_tostring},
  _params = paramtypes.none, _str = "${action}(priority = ${priority})",
  action = "Options", priority = 0
}, {
  __call = function(self, opts)
    if type(opts) ~= "table" then
      ---@cast opts integer
      opts = {priority = opts}
    end
    return setmetatable({priority = opts.priority, _values = {}}, self[Annotation])
  end,
  __tostring = anno_tostring
}))
Options[Annotation].__index = Options

---The value below this annotation will replace the value at the given target index.
---
---If this is used in a module mixin, `target` must be `nil`. The value will instead replace the module itself.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`any`**: The value that will replace the target.
---@class Plugin.Mixins.Annotation.Overwrite: Plugin.Mixins.Annotation
---@field action "Overwrite"
---@field target any
---@overload fun(target: any): Plugin.Mixins.Annotation.Overwrite
---@annotation
local Overwrite = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.any, _str = "${action}(target = ${target})",
    action = "Overwrite", target = nil
  },
  anno_mt_target
))
Overwrite[Annotation].__index = Overwrite

---The function below this annotation will be given the current value at the given target index and will be expected
---to return a new value to replace that value.
---
---If this is used in a module mixin, `target` must be `nil`. The returned value will instead replace the module
---itself.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`fun(old: any, obj?: table): any`**: The function that will run to replace the target.  
---  * **`old: any`**: The current value at the target.
---  * **`obj?: table`**: The table containing the target. This is `nil` if this is used in a module mixin.
---  * **`any`**: The value that will replace the target.
---@class Plugin.Mixins.Annotation.DynamicOverwrite: Plugin.Mixins.Annotation
---@field action "DynamicOverwrite"
---@field target any
---@overload fun(target: any): Plugin.Mixins.Annotation.DynamicOverwrite
---@annotation
local DynamicOverwrite = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.any, _str = "${action}(target = ${target})",
    action = "DynamicOverwrite"
  },
  anno_mt_target
))
DynamicOverwrite[Annotation].__index = DynamicOverwrite

---Redirects calls for the function at the given target index. All arguments passed into the original function will
---instead be passed into the function below this annotation.
---
---Throws an error if a function is not found at the given target index.
---
---If this is used in a module mixin, `target` must be `nil`. The function will redirect the module itself.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`function`**: The function that will be redirected to.
---@class Plugin.Mixins.Annotation.Redirect: Plugin.Mixins.Annotation
---@field action "Redirect"
---@field target any
---@overload fun(target: any): Plugin.Mixins.Annotation.Redirect
---@annotation
local Redirect = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.func, _str = "${action}(target = ${target})",
    action = "Redirect"
  },
  anno_mt_target
))
Redirect[Annotation].__index = Redirect

---The function below this annotation will be given the current function at the given target index and will be
---expected to return a new function to replace that function.
---
---Throws an error if a function is not found at the given target index.
---
---If this is used in a module mixin, `target` must be `nil`. The returned function will redirect the module itself.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`fun(old: function, obj?: table): function`**: The function that will run to redirect the target.  
---  * **`old: function`**: The current function at the target.
---  * **`obj?: table`**: The table containing the target. This is `nil` if this is used in a module mixin.
---  * **`function`**: The function that will be redirected to.
---@class Plugin.Mixins.Annotation.DynamicRedirect: Plugin.Mixins.Annotation
---@field action "DynamicRedirect"
---@field target any
---@overload fun(target: any): Plugin.Mixins.Annotation.DynamicRedirect
---@annotation
local DynamicRedirect = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.func, _str = "${action}(target = ${target})",
    action = "DynamicRedirect"
  },
  anno_mt_target
))
DynamicRedirect[Annotation].__index = DynamicRedirect

---If the method at the given target index is called, the function below this annotation will run instead, being given
---the original function and all of the values passed into it.
---
---Throws an error if a function is not found at the given target index.
---
---If this is used in a module mixin, `target` must be `nil`. The wrapper will wrap the module itself.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`function`**: The function that will wrap the target.  
---  This function will receive an upvalue called `_old` that contains the target function.
---@deprecated Use DynamicRedirect instead
---@class Plugin.Mixins.Annotation.Wrapper: Plugin.Mixins.Annotation
---@field action "Wrapper"
---@field target any
---@overload fun(target: any): Plugin.Mixins.Annotation.Wrapper
---@annotation
local Wrapper = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.func, _str = "${action}(target = ${target})",
    action = "Wrapper"
  },
  anno_mt_target
))
Wrapper[Annotation].__index = Wrapper

---The function below this annotation will be run before the mixin is applied.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`fun(obj: any)`**: The function to run.
---  * **`obj: any`**: The object this mixin is accessing.
---@class Plugin.Mixins.Annotation.Init: Plugin.Mixins.Annotation
---@field action "Init"
---@overload fun(): Plugin.Mixins.Annotation.Init
---@annotation
local Init = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.func, _str = "${action}()",
    action = "Init"
  },
  anno_mt_none
))
Init[Annotation].__index = Init

---The function below this annotation will be run after the mixin is applied.
---
---&nbsp;  
---**Annotates 1 value:**
---* **`fun(obj: any, mxn: Mixin)`**: The function to run.
---  * **`obj: any`**: The object this mixin is accessing.
---  * **`mxn: Mixin`**: The compiled mixin.
---@class Plugin.Mixins.Annotation.PostInit: Plugin.Mixins.Annotation
---@field action "PostInit"
---@overload fun(): Plugin.Mixins.Annotation.PostInit
---@annotation
local PostInit = (setmetatable(
  {
    [Annotation] = {__tostring = anno_tostring},
    _params = paramtypes.func, _str = "${action}()",
    action = "PostInit"
  },
  anno_mt_none
))
PostInit[Annotation].__index = PostInit


---@type Plugin.Mixins.Mixin[]
local active_mixins = {}

local function sort_mixins(a, b)
  if a.priority == b.priority then return a.id < b.id end
  return a.priority < b.priority
end

---@class Plugin.Mixins.MixinOptions
---@field priority integer

---@class Plugin.Mixins.Mixin: Plugin.Mixins.MixinOptions
---@field id integer
---@field objid string
---@field obj table | string
---@field [integer] Plugin.Mixins.Annotation

local id = 0
---@param data (unknown | Plugin.Mixins.Annotation)[]
---@param obj table | string
---@return Plugin.Mixins.Mixin
local function compile_mixin(data, obj)
  local is_module = type(obj) == "string"
  ---@type Plugin.Mixins.Mixin
  local mxn = {
    id = id,
    obj = obj,
    objid = "",
    priority = 0
  }

  local init = {}
  local postinit = {}

  ---@type Plugin.Mixins.Annotation
  local last_anno
  local expected_nvals = 0
  local i = 1
  while true do
    local v = data[i]
    if v == nil and expected_nvals <= 0 then break end

    if type(v) == "table" then
      if v[Annotation] then
        ---@cast v Plugin.Mixins.Annotation

        -- If an annotation did not get all of its values then error.
        if expected_nvals > 0 then
          error(
            ("annotation %s expected %d more %s, got annotation %s"):format(
              last_anno, expected_nvals, expected_nvals == 1 and "value" or "values", v
            ), 3
          )
        end

        -- If an annotation wasn't called, call it now.
        if not v._values then v = v() end

        -- If we are targeting a module, no annotation should be targeting anything.
        ---@diagnostic disable-next-line: undefined-field
        if is_module and v.target then
          error("annotation " .. v .. " cannot have a target in a module value mixin", 3)
        end

        -- Annotation-specific handling.
        if v.action == "Options" then
          ---@cast v Plugin.Mixins.Annotation.Options
          if i ~= 1 then
            error(("unexpected %s at index %d, Options is only allowed at index 1"):format(v, i), 3)
          end

          if v.priority then mxn.priority = v.priority end
        elseif v.action == "Init" then
          ---@cast v Plugin.Mixins.Annotation.Init
          init[#init+1] = v
        elseif v.action == "PostInit" then
          ---@cast v Plugin.Mixins.Annotation.PostInit
          postinit[#postinit+1] = v
        else
          mxn[#mxn+1] = v
        end

        v._mixin = mxn
        last_anno = v
        expected_nvals = #last_anno._params
      elseif expected_nvals > 0 then
        ---@cast v table
        local aparams = last_anno._params
        local aptype = aparams[#aparams - expected_nvals + 1]
        if aptype ~= "any" and aptype ~= "table" then
          error(
            ("unexpected value %d for annotation %s (expected %s, got table)"):format(
              #aparams - expected_nvals + 1, last_anno, aptype
            ), 3
          )
        else
          expected_nvals = expected_nvals - 1
          last_anno._values[#aparams - expected_nvals] = v
        end
      else
        error("unexpected value at index " .. i .. " (expected annotation, got table)", 3)
      end
    elseif expected_nvals > 0 then
      ---@cast v -Plugin.Mixins.Annotation
      local aparams = last_anno._params
      local aptype = aparams[#aparams - expected_nvals + 1]
      if aptype ~= "any" and not aptype:find(type(v), 1, true) then
        error(
          ("unexpected value %d for annotation %s (expected %s, got %s)"):format(
            #aparams - expected_nvals + 1, last_anno, aptype, type(v)
          ), 3
        )
      else
        expected_nvals = expected_nvals - 1
        last_anno._values[#aparams - expected_nvals] = v
      end
    else
      error(("unexpected value at index %d (expected annotation, got table)"):format(i, type(v)), 3)
    end

    i = i + 1
  end

  if expected_nvals > 0 then
    error(
      ("annotation %s expected %d more %s, got end of mixin"):format(
        last_anno, expected_nvals, expected_nvals == 1 and "value" or "values"
      ), 3
    )
  end

  while #init > 0 do
    table.insert(mxn, 1, init[#init])
    init[#init] = nil
  end
  table.move(postinit, 1, #postinit, #mxn + 1, mxn)

  id = id + 1
  return mxn
end

---@type {[string]: fun(anno: Plugin.Mixins.Annotation, obj: table | string)}
local actions = {
  ---@param anno Plugin.Mixins.Annotation.Overwrite
  Overwrite = function(anno, obj)
    if type(obj) == "string" then
      package.loaded[obj] = anno._values[1]
    else
      obj[anno.target] = anno._values[1]
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.DynamicOverwrite
  DynamicOverwrite = function(anno, obj)
    if type(obj) == "string" then
      package.loaded[obj] = anno._values[1](package.loaded[obj])
    else
      obj[anno.target] = anno._values[1](obj[anno.target], obj)
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.Redirect
  Redirect = function(anno, obj)
    if type(obj) == "string" then
      if type(package.loaded[obj]) ~= "function" then
        error(("annotation %s requires a function as the value of module '%s'"):format(anno, obj), 3)
      end
      package.loaded[obj] = anno._values[1]
    else
      if type(obj[anno.target]) ~= "function" then
        error(("annotation %s requires a function at target index %q"):format(anno, anno.target), 3)
      end
      obj[anno.target] = anno._values[1]
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.DynamicRedirect
  DynamicRedirect = function(anno, obj)
    if type(obj) == "string" then
      if type(package.loaded[obj]) ~= "function" then
        error(
          ("annotation %s attempted to redirect non-function value of module '%s'"):format(anno, obj),
          3
        )
      end

      local newf = anno._values[1](package.loaded[obj])
      if type(newf) ~= "function" then
        error(
          ("annotation %s attempted to assign non-function value as redirect for value of module '%s'"):format(
            anno, obj
          ), 3
        )
      end
      package.loaded[obj] = newf
    else
      if type(obj[anno.target]) ~= "function" then
        error(
          ("annotation %s attempted to redirect non-function value at target index %q"):format(
            anno, anno.target
          ), 3
        )
      end

      local newf = anno._values[1](obj[anno.target], obj)
      if type(newf) ~= "function" then
        error(
          ("annotation %s attempted to assign non-function value as redirect for value at target index %q"):format(
            anno, anno.target
          ), 3
        )
      end

      obj[anno.target] = newf
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.Wrapper
  Wrapper = function(anno, obj)
    local f = anno._values[1]
    local upi
    for i = 1, 255 do
      if debug.getupvalue(f, i) == "_old" then
        upi = i
        break
      end
    end

    if not upi then
      local bco = bce.dump(f)
      local Kn
      for i, const in ipairs(bco.main.const) do
        if const.type & 0xF == bce.TYPE.TSTRING and const.value == "_old" then
          Kn = i - 1
          break
        end
      end
      local U0 = bco.main:U(0)
      if Kn and U0 and U0.name == "_ENV" then
        local Un = #bco.main.upv
        upi = Un + 1
        bco.main:addUpvalue()

        bco.main:eachInstruction("op", bce.OP.GETTABUP, function(inst)
          if inst.B == 0 and inst.C == Kn then
            inst.op = bce.OP.GETUPVAL
            inst.B = Un
            inst.C = 0
          end
        end)
        bco.main:eachInstruction("op", bce.OP.SETTABUP, function(inst)
          if inst.k and inst.A == 0 and inst.B == Kn then
            inst.op = bce.OP.MOVE
            inst.A = 0
            inst.B = 0
          end
        end)

        local e
        f, e = bco:build(_ENV)
        if not f then
          error(("annotation %s failed to add upvalue '_old' to wrapper function: %s"):format(anno, e), 3)
        end
      end
    end
    anno._values[1] = f

    if type(obj) == "string" then
      local was = package.loaded[obj]
      if type(was) ~= "function" then
        error(("annotation %s requires a function as the value of module '%s'"):format(anno, obj), 3)
      end

      debug.setupvalue(f, upi, was)
      package.loaded[obj] = f
    else
      local was = obj[anno.target]
      if type(was) ~= "function" then
        error(("annotation %s requires a function at target index %q"):format(anno, anno.target), 3)
      end

      debug.setupvalue(f, upi, was)
      obj[anno.target] = f
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.Init
  Init = function(anno, obj)
    if type(obj) == "string" then
      anno._values[1](package.loaded[obj])
    else
      anno._values[1](obj)
    end
  end,

  ---@param anno Plugin.Mixins.Annotation.PostInit
  PostInit = function(anno, obj)
    if type(obj) == "string" then
      anno._values[1](package.loaded[obj], anno._mixin)
    else
      anno._values[1](obj, anno._mixin)
    end
  end
}

---@param mxn Plugin.Mixins.Mixin
local function apply_mixin(mxn)
  for _, anno in ipairs(mxn) do
    local action = actions[anno.action]
    if action then
      action(anno, mxn.obj)
      logger:debug("Annotation \"%s\"/%s successfully applied!", mxn.objid, anno)
    end
  end
end

local mixin_init = false

---Create a new mixin.
---
---`objid` is a string that eventually points to a table or module.  
---Object id syntax is defined below:
---* All object ids must start with a module name surrounded in single quotes.  
---  `'module_name'`
---* After the module name is a number of "redirectors" that inform the mixin where to find the object.
---  * Accessing a table field can be done by adding a dot followed by a normal Lua identifier.  
---    `.identifier`
---  * Table indexing can be done by surrounding a number or single-quoted string in square brackets.  
---    `[123]`, `['string-value']`
---  * Upvalues of functions can be accessed by adding a caret followed by either an index number or Lua identifier.  
---    `^4`, `^plugin`
---  * Metatables can be accessed by adding an at-sign. If a Lua identifier is added then that metatable field will be
---    accessed.  
---    `@`, `@__index`
---
---Mixins have two modes: Object and Module.
---
---Object mode is used if `objid` points to a table value.  
---In this mode, mixin annotations behave as normal.
---
---Module mode is used if `objid` points to a module that does not contain a table value.  
---In this mode, mixin annotations cannot target an index and will always target the value of the module.
---@param objid string
---@return fun(data: table)
---@keyword
local function mixin(objid)
  if type(objid) ~= "string" then error("requires object identifier", 2) end

  local s, obj = xpcall(get, function(msg)
    logger:error("mixin \"%s\" failed to compile:\n%s", objid, debug.traceback(msg, 4))
  end, objid, true)
  if not s then return noop end

  return function(data)
    local s2, mxn = xpcall(compile_mixin, function(msg)
      logger:error("mixin \"%s\" failed to compile:\n%s", objid, debug.traceback(msg, 4))
    end, data, obj)
    if not s2 then return end
    mxn.objid = objid

    if mixin_init then
      local s3 = xpcall(apply_mixin, function(msg)
        logger:error("mixin \"%s\" failed to apply:\n%s", objid, debug.traceback(msg, 4))
      end, mxn)

      if s3 then logger:info("Mixin \"%s\" successfully applied!", objid) end
    else
      active_mixins[#active_mixins+1] = mxn
    end
  end
end

local this = {
  get = get,
  mixin = mixin,

  Options = Options,
  Overwrite = Overwrite,
  DynamicOverwrite = DynamicOverwrite,
  Redirect = Redirect,
  DynamicRedirect = DynamicRedirect,
  Wrapper = Wrapper,
  Init = Init,
  PostInit = PostInit
}
package.loaded["mixins"] = this


-- Load built-in mixins
for file, status in fs.pairs(mixins_path) do
  if status:type() == "regular" then
    local file_name = file:string():match("([^/]*)%.lua$")
    if file_name then
      local success = xpcall(require, function(err)
        logger:error("Mixin file '%s' failed to load due to a Lua error!\n%s", file_name, debug.traceback(err))
      end, "mixins." .. file_name)

      if success then logger:info("Mixins in mixin file '%s' successfully compiled!", file_name) end
    end
  end
end

table.sort(active_mixins, sort_mixins)
for _, mxn in ipairs(active_mixins) do
  local s = xpcall(apply_mixin, function(msg)
    logger:error("Mixin \"%s\" failed to apply:\n%s", mxn.objid, debug.traceback(msg, 3))
  end, mxn)

  if s then logger:info("Mixin \"%s\" successfully applied!", mxn.objid) end
end
mixin_init = true

return this
