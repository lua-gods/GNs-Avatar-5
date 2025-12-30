---@meta _
---@diagnostic disable: codestyle-check

---@type string, string[]
local path, iargs = ...

local hook = require("hook")
local activews = require("helpers.activews")

local args = require("helpers.args")(iargs)
---@diagnostic disable-next-line: invisible
activews.args[path] = args


pcall(require, "plugin-debug")
require("mixins")
require("addons")

local logger = require("helpers.logger")("main")

---==================================================================================================================---

---@type {[string]: boolean}
local blocked_uris = {[""] = true}

---@param uri string
---@param text? string
---@return boolean
local function pluginBlocked(uri, text)
  if not text then return blocked_uris[uri] or false end

  local isblocked = not not (
    text:match("^%s*%-%-%-@meta _")
    or text:match("^%s*%-%-%-@noplugin")
    or text:match("^%s*%-%-%-@meta[^\n]*\n%s*%-%-%-@noplugin")
  )

  blocked_uris[uri] = isblocked

  return isblocked
end


local requires
local function collectRequires(cb_requires)
  if type(cb_requires) == "table" then
    for _, v in ipairs(cb_requires) do
      if type(v) == "string" then requires[#requires + 1] = v end
    end
  end
end

function ResolveRequire(ws_uri, modname, uri)
  if pluginBlocked(uri) then return nil end
  --;print("ResolveRequire", uri)
  requires = {}
  hook.foreach("ResolveRequire", collectRequires, ws_uri, modname, uri)
  return #requires > 0 and requires or nil
end

local _ <close> = activews.set(path)
hook.runall("OnPluginLoaded", path, args)
local argstr = #iargs > 0 and ("[\"" .. table.concat(iargs, "\", \"") .. "\"]") or "[]"
logger:info("PLUGIN LOADED AT <%s>\nwith args %s", path, argstr)
