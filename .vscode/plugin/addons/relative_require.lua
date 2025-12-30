local common = require("helpers.common")
local furi = require("file-uri")
local hook = require("hook")

---@param workspace string
---@param root string
---@param file string
---@param relative string
---@return string?
local function module_path(workspace, root, file, relative)
  if file:sub(1, #workspace) ~= workspace then return end

  for word in relative:gmatch("[^/\\]+") do
    if word == ".." then
      if #file <= #root then return "" end
      file = file:gsub("/[^/\\]*$", "", 1)
    elseif word ~= "." then
      file = file .. "/" .. word:gsub("%.", "/")
    end
  end

  return furi.encode(file .. ".lua")
end

hook.add("ResolveRequire", "RelativeRequire", 1000, function(ws_uri, modname, uri)
  --printf("RESOLVE:\n  %s\n  %s \n  %s", ws_uri, uri, modname)

  local pkg_uri
  local root = common.avatarRoot(uri)
  --printf("ROOT: %s", root)
  if not root then return end

  if modname:match("^%.%.?/") then
    pkg_uri = module_path(
      furi.decode(ws_uri):gsub("\\", "/"),
      furi.decode(root):gsub("\\", "/"),
      furi.decode(uri):gsub("\\", "/"):gsub("/[^/]*$", "", 1),
      modname
    )
  else
    local root_path = furi.decode(root):gsub("\\", "/")
    pkg_uri = module_path(
      furi.decode(ws_uri):gsub("\\", "/"),
      root_path,
      root_path,
      modname:gsub("^[./\\]", "", 1):gsub("[.\\]", "/")
    )
  end

  return pkg_uri and {pkg_uri} or nil
end)

--hook.add("OnSetText", "RelativeRequire", 100, function(uri, text)
--  ---@type LuaLS.Plugin.diff[]
--  local diffs = {}
--
--  for _, pattern in ipairs(patterns) do
--    for start, module_name, finish in text:gmatch(pattern) do
--      if module_name:match("^%.?%.[/\\]") then
--        local root = scope.getScope(uri).uri
--        print("-------------------------")
--        print("uri", uri)
--        print("root", root)
--        print("module", module_name)
--        if root then
--          local req_path = package_path(
--            furi.decode(root):gsub("\\", "/"),
--            furi.decode(uri):gsub("\\", "/"):gsub("/[^/]*$", "", 1),
--            module_name:gsub("%.lua$", "", 1)
--          )
--          print("result", req_path)
--
--          diffs[#diffs + 1] = {
--            start = start,
--            finish = finish - 1,
--            text = req_path
--          }
--        end
--      end
--    end
--  end
--
--  return diffs
--end)

