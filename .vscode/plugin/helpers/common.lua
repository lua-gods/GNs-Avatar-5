local furi = require("file-uri")
local fs = require("bee.filesystem")
local scope = require("workspace.scope")

---@class Plugin.Common
local this = {}


local root_cache = {}

---Gets the uri to the folder contining the avatar that would be handling the given file.
---@param uri string
---@return string?
function this.avatarRoot(uri)
  local workspace = scope.getScope(uri).uri
  if not workspace or uri:sub(1, #workspace) ~= workspace then return nil end

  if root_cache[uri] then return root_cache[uri] end

  local cur_path = fs.path(furi.decode(workspace))
  local ajs_path = cur_path / "avatar.json"

  if (fs.exists(ajs_path) and not fs.is_directory(ajs_path)) then
    local cur_uri = furi.encode(cur_path:string())
    root_cache[uri] = cur_uri
    return cur_uri
  end

  local path = furi.decode(uri):sub(#cur_path:string() + 1):gsub("[^/\\]+$", "", 1)

  for word in path:gmatch("[^/\\]+") do
    cur_path = cur_path / word
    ajs_path = cur_path / "avatar.json"

    if (fs.exists(ajs_path) and not fs.is_directory(ajs_path)) then
      local cur_uri = furi.encode(cur_path:string())
      root_cache[uri] = cur_uri
      return cur_uri
    end
  end


  return nil
end

return this
