---@type string, string
local _, path = ...

local client = require("client")
local fs = require("bee.filesystem")
local hook = require("hook")
local furi = require("file-uri")
local addons_path = path:gsub("[^/]+$", "addons")

local logger = require("helpers.logger")("addons")

local msg_addonError = [[
A plugin addon has errored! Please report this to the author of the plugin addon.
A detailed stack trace has been printed to the Lua Output.
Error: %s
Addon path: %s]]

-- Load built-in addons
for file, status in fs.pairs(addons_path) do
  if status:type() == "regular" then
    local file_name = file:string():match("([^/]*)%.lua$")
    if file_name and file_name ~= "init" then
      require("addons." .. file_name)
      logger:info("Addon '%s' successfully loaded!", file_name)
    end
  end
end

local addonignore = {
  "%.git$",
  "%.git/",
  "%.figura/plugin$",
  "%.figura/plugin/"
}

local MOTW = false

-- Load workspace addons
local function recursiveSearch(dir)
  for file, status in fs.pairs(dir) do
    local file_path = file:string()
    local file_status = status:type()

    local ignored = false
    for _, ignore in ipairs(addonignore) do
      if file_path:match(ignore) then
        ignored = true
        break
      end
    end

    if not ignored then
      if file_status == "directory" then
        recursiveSearch(file_path)
      elseif file_status == "regular" and file_path:match("%.plugin%.[^./\\]+%.lua$") then
        local name = file_path:match("%.plugin%.([^.\\/]+)%.lua$")
        local blocked = false
        local motw_stream = file_path .. ":Zone.Identifer"
        if fs.exists(motw_stream) and not fs.is_directory(motw_stream) then
          local f = io.open(motw_stream, "r")
          local n = f and tonumber(f:read("a"):match("\nZoneId ?= ?(%d+)")) or nil
          if f then f:close() end
          if n and n >= 3 then
            if not MOTW then
              client.showMessage(
                "One or more workspace addons were blocked due to having an untrusted Mark of the Web. "
                .. "If you wish to use these addons, open their properties and unblock them! "
                .. "The blocked addons are listed in the Lua Output."
              )
              MOTW = true
            end
            blocked = true
          end
        end

        if blocked then
          logger:warn("Workspace plugin '%s' was blocked due to being untrusted by the system.", name)
        else
          local success = xpcall(dofile, function(e)
            client.showMessage(msg_addonError:format(
              e,
              fs.absolute(file_path):string():gsub("^[a-z]", string.upper, 1)
            ))
            logger:error("Workspace plugin '%s' failed to apply!\n%s", e, debug.traceback(e))
          end, file_path)

          if success then logger:info("Workspace plugin '%s' successfully applied!", name) end
        end
      end
    end
  end
end

-- This must always have highest priority to allow workspace plugins that also wait for plugin load to run their hook.
hook.add("OnPluginLoaded", "WorkspaceAddons", 99999, function(uri, args)
  if args.allowAddons ~= true then return end
  local ws_path = furi.decode(uri):gsub("\\", "/")
  logger:debug("Loading workspace addons in <%s>", ws_path)
  recursiveSearch(ws_path)
end)
