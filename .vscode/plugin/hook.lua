
---@class Plugin.Hook
local this = {}

---@type {[string]: {names: {[string]: true}, [integer]: Plugin.Hook.callback}}
local hooks = {}

---@class Plugin.Hook.callback
---@field name string
---@field priority integer
---@field func function

---Adds a new callback to the given hook.
---
---Callbacks with duplicate names are ignored to avoid the same callback being added multiple times.
---@overload fun(hook: "OnSetText", name: string, priority: integer, func: fun(uri: uri, text: string): LuaLS.Plugin.diff[]?)
---@overload fun(hook: "OnTransformAst", name: string, priority: integer, func: fun(uri: uri, ast: parser.object))
---@overload fun(hook: "OnDocBuild", name: string, priority: integer, func: fun(uri: uri, ast: parser.object))
---@overload fun(hook: "PreCompileNode", name: string, priority: integer, func: fun(uri: uri, source: parser.object))
---@overload fun(hook: "OnCompileNode", name: string, priority: integer, func: fun(uri: uri, node: vm.node, source: parser.object))
---@overload fun(hook: "OnCompileFunctionParam", name: string, priority: integer, func: fun(default: fun(func: parser.object, param: parser.object): true?, func: parser.object, param: parser.object): true?)
---@overload fun(hook: "ResolveRequire", name: string, priority: integer, func: fun(ws_uri: uri, modname: string, uri: uri): string[]?)
---@overload fun(hook: "OnRequestHints", name: string, priority: integer, func: fun(uri: uri, hints: core.hint.result[], start: integer, finish: integer))
---@overload fun(hook: "OnRequestCompletion", name: string, priority: integer, func: fun(uri: uri, items: table[], params: table, incomplete: boolean))
---@overload fun(hook: "OnResolveCompletion", name: string, priority: integer, func: fun(uri: uri, item: table))
---@overload fun(hook: "OnGetHover", name: string, priority: integer, func: fun(uri: uri, md: markdown, source: parser.object, level: integer, maxLevel: integer))
---@overload fun(hook: "OnCompileGlobals", name: string, priority: integer, func: fun(uri: uri, ast: parser.object))
---@overload fun(hook: "OnSemanticToken", name: string, priority: integer, func: fun(uri: uri, src_type: string, source: parser.object, options: Plugin.Mixin.SemanticTokens.Options, results: Plugin.Mixin.SemanticTokens.Result[]): Plugin.Mixin.SemanticTokens.Result[]?)
---@overload fun(hook: "OnTraceChild", name: string, priority: integer, func: fun(uri: uri, action_type: string, tracer: vm.tracer, action: parser.object, topNode: vm.node, outNode?: vm.node): (topNode: vm.node?, outNode: vm.node?))
---@overload fun(hook: "OnPluginLoaded", name: string, priority: integer, func: fun(uri: uri, args: Plugin.Args))
function this.add(hook, name, priority, func)
  if not hooks[hook] then hooks[hook] = {names = {}} end
  local hook_table = hooks[hook]
  if hook_table.names[name] then return end

  local callback = {
    name = name,
    priority = priority,
    func = func
  }

  local len = #hook_table
  if len < 1 then
    hook_table[1] = callback
    hook_table.names[name] = true
    return
  end

  for i, cb in ipairs(hook_table) do
    if (priority == cb.priority and name < cb.name) or (priority > cb.priority) then
      table.insert(hook_table, i, callback)
      hook_table.names[name] = true
      return
    end
  end

  hook_table[#hook_table+1] = callback
  hook_table.names[name] = true
end

---Removes the callback with the given parameters from the given hook.
---@param hook string
---@param name string
---@param priority integer
---@return boolean
function this.remove(hook, name, priority)
  if not hooks[hook] then return false end
  local hook_table = hooks[hook]
  if not hook_table.names[name] then return false end

  for i, callback in ipairs(hook_table) do
    if callback.name == name and callback.priority == priority then
      table.remove(hook_table, i)
      hook_table.names[name] = nil
      return true
    end
  end

  return false
end

---Checks if the given hook has no callbacks.
---@param hook string
---@return boolean
function this.empty(hook)
  return not hooks[hook] or #hooks[hook] == 0
end

---Runs all callbacks in the given hook until one returns a value.
---
---Supplied arguments are passed on to the callbacks.
---@overload fun(hook: "OnSetText", uri: uri, text: string): LuaLS.Plugin.diff[]?
---@overload fun(hook: "OnTransformAst", uri: uri, ast: parser.object)
---@overload fun(hook: "OnDocBuild", uri: uri, ast: parser.object)
---@overload fun(hook: "PreCompileNode", uri: uri, source: parser.object)
---@overload fun(hook: "OnCompileNode", uri: uri, node: vm.node, source: parser.object)
---@overload fun(hook: "OnCompileFunctionParam", default: fun(func: parser.object, param: parser.object): true?, func: parser.object, param: parser.object): true?
---@overload fun(hook: "ResolveRequire", ws_uri: uri, modname: string, uri: uri): string[]?
---@overload fun(hook: "OnRequestHints", uri: uri, hints: core.hint.result[], start: integer, finish: integer)
---@overload fun(hook: "OnRequestCompletion", uri: uri, items: table[], params: table, incomplete: boolean)
---@overload fun(hook: "OnResolveCompletion", uri: uri, item: table)
---@overload fun(hook: "OnGetHover", uri: uri, md: markdown, source: parser.object, level: integer, maxLevel: integer)
---@overload fun(hook: "OnCompileGlobals", uri: uri, ast: parser.object)
---@overload fun(hook: "OnSemanticToken", uri: uri, src_type: string, source: parser.object, options: Plugin.Mixin.SemanticTokens.Options, results: Plugin.Mixin.SemanticTokens.Result[]): Plugin.Mixin.SemanticTokens.Result[]?
---@overload fun(hook: "OnTraceChild", uri: uri, action_type: string, tracer: vm.tracer, action: parser.object, topNode: vm.node, outNode?: vm.node): (topNode: vm.node?, outNode: vm.node?)
---@overload fun(hook: "OnPluginLoaded", uri: uri, args: Plugin.Args)
function this.run(hook, ...)
  if not hooks[hook] then return end
  for _, callback in ipairs(hooks[hook]) do
    local ret = table.pack(callback.func(...))
    if ret.n > 0 then
      return table.unpack(ret, 1, ret.n)
    end
  end
end

---Runs all callbacks in the given hook.  
---Nothing is returned from this unlike `hook.run()`.
---
---Supplied arguments are passed on to the callbacks.
---@overload fun(hook: "OnSetText", uri: uri, text: string)
---@overload fun(hook: "OnTransformAst", uri: uri, ast: parser.object)
---@overload fun(hook: "OnDocBuild", uri: uri, ast: parser.object)
---@overload fun(hook: "PreCompileNode", uri: uri, source: parser.object)
---@overload fun(hook: "OnCompileNode", uri: uri, node: vm.node, source: parser.object)
---@overload fun(hook: "OnCompileFunctionParam", default: fun(func: parser.object, param: parser.object): true?, func: parser.object, param: parser.object)
---@overload fun(hook: "ResolveRequire", ws_uri: uri, modname: string, uri: uri)
---@overload fun(hook: "OnRequestHints", uri: uri, hints: core.hint.result[], start: integer, finish: integer)
---@overload fun(hook: "OnRequestCompletion", uri: uri, items: table[], params: table, incomplete: boolean)
---@overload fun(hook: "OnResolveCompletion", uri: uri, item: table)
---@overload fun(hook: "OnGetHover", uri: uri, md: markdown, source: parser.object, level: integer, maxLevel: integer)
---@overload fun(hook: "OnCompileGlobals", uri: uri, ast: parser.object)
---@overload fun(hook: "OnSemanticToken", uri: uri, src_type: string, source: parser.object, options: Plugin.Mixin.SemanticTokens.Options, results: Plugin.Mixin.SemanticTokens.Result[])
---@overload fun(hook: "OnTraceChild", uri: uri, action_type: string, tracer: vm.tracer, action: parser.object, topNode: vm.node, outNode?: vm.node)
---@overload fun(hook: "OnPluginLoaded", uri: uri, args: Plugin.Args)
function this.runall(hook, ...)
  if not hooks[hook] then return end
  for _, callback in ipairs(hooks[hook]) do
    callback.func(...)
  end
end

---Passes the result of running each callback in the given hook to the given function.
---
---Supplied arguments are passed on to the callbacks
---@overload fun(hook: "OnSetText", func: fun(value?: LuaLS.Plugin.diff[]), uri: uri, text: string)
---@overload fun(hook: "OnTransformAst", func: fun(), uri: uri, ast: parser.object)
---@overload fun(hook: "OnDocBuild", func: fun(), uri: uri, ast: parser.object)
---@overload fun(hook: "PreCompileNode", func: fun(), uri: uri, source: parser.object)
---@overload fun(hook: "OnCompileNode", func: fun(), uri: uri, node: vm.node, source: parser.object)
---@overload fun(hook: "OnCompileFunctionParam", func: fun(value?: true), default: fun(func: parser.object, param: parser.object): true?, func: parser.object, param: parser.object)
---@overload fun(hook: "ResolveRequire", func: fun(value?: string[]), ws_uri: uri, modname: string, uri: uri)
---@overload fun(hook: "OnRequestHints", func: fun(), uri: uri, hints: core.hint.result[], start: integer, finish: integer)
---@overload fun(hook: "OnRequestCompletion", func: fun(), uri: uri, items: table[], params: table, incomplete: boolean)
---@overload fun(hook: "OnResolveCompletion", func: fun(), uri: uri, item: table)
---@overload fun(hook: "OnGetHover", func: fun(), uri: uri, md: markdown, source: parser.object, level: integer, maxLevel: integer)
---@overload fun(hook: "OnCompileGlobals", func: fun(), uri: uri, ast: parser.object)
---@overload fun(hook: "OnSemanticToken", func: fun(results?: Plugin.Mixin.SemanticTokens.Result[]), uri: uri, src_type: string, source: parser.object, options: Plugin.Mixin.SemanticTokens.Options, results: Plugin.Mixin.SemanticTokens.Result[])
---@overload fun(hook: "OnTraceChild", func: fun(topNode?: vm.node, outNode?: vm.node), uri: uri, action_type: string, tracer: vm.tracer, action: parser.object, topNode: vm.node, outNode?: vm.node)
---@overload fun(hook: "OnPluginLoaded", func: fun(), uri: uri, args: Plugin.Args)
function this.foreach(hook, func, ...)
  if not hooks[hook] then return end
  for _, callback in ipairs(hooks[hook]) do
    func(callback.func(...))
  end
end

---Runs all callbacks and inserts the result of a callback into the next one.  
---If a callback returns nothing, the next callback will instead use the result of the previous callback.
---
---Supplied arguments are passed on to the first callback.
---@overload fun(hook: "OnSetText", uri: uri, text: string): LuaLS.Plugin.diff[]?
---@overload fun(hook: "OnTransformAst", uri: uri, ast: parser.object)
---@overload fun(hook: "OnDocBuild", uri: uri, ast: parser.object)
---@overload fun(hook: "PreCompileNode", uri: uri, source: parser.object)
---@overload fun(hook: "OnCompileNode", uri: uri, node: vm.node, source: parser.object)
---@overload fun(hook: "OnCompileFunctionParam", default: fun(func: parser.object, param: parser.object): true?, func: parser.object, param: parser.object): true?
---@overload fun(hook: "ResolveRequire", ws_uri: uri, modname: string, uri: uri): string[]?
---@overload fun(hook: "OnRequestHints", uri: uri, hints: core.hint.result[], start: integer, finish: integer)
---@overload fun(hook: "OnRequestCompletion", uri: uri, items: table[], params: table, incomplete: boolean)
---@overload fun(hook: "OnResolveCompletion", uri: uri, item: table)
---@overload fun(hook: "OnGetHover", uri: uri, md: markdown, source: parser.object, level: integer, maxLevel: integer)
---@overload fun(hook: "OnCompileGlobals", uri: uri, ast: parser.object)
---@overload fun(hook: "OnSemanticToken", uri: uri, src_type: string, source: parser.object, options: Plugin.Mixin.SemanticTokens.Options, results: Plugin.Mixin.SemanticTokens.Result[]): Plugin.Mixin.SemanticTokens.Result[]?
---@overload fun(hook: "OnTraceChild", uri: uri, action_type: string, tracer: vm.tracer, action: parser.object, topNode: vm.node, outNode?: vm.node): (topNode: vm.node?, outNode: vm.node?)
---@overload fun(hook: "OnPluginLoaded", uri: uri, args: {[string]: boolean | number | string})
function this.chain(hook, ...)
  if not hooks[hook] then return ... end
  local values = table.pack(...)
  for _, callback in ipairs(hooks[hook]) do
    local cb_values = table.pack(callback.func(table.unpack(values, 1, values.n)))
    if cb_values.n > 0 then
      values = cb_values
    end
  end

  return table.unpack(values, 1, values.n)
end

return this
