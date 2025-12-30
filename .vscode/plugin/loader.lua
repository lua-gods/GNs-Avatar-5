---@meta _
---@type function, string
local _, uri, iargs = ...

local path, path_error = package.searchpath("main", package.path)
if not path then error(path_error) end

local func, func_error = loadfile(path, "t")
if not func then error(func_error) end

xpcall(func, function(e)
  print(debug.traceback(e))
end, uri, iargs)
