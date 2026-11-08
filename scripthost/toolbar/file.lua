local Macro = require("lib.GNMacros")

local IMPORTERS = {
	ogg = function (path)
		oggHead(path,{loop=true})
	end,
	nbs = function (path)
		nbsHead(path)
	end
}


---@param btn GNUI.Widget.Button
return Macro.new(function (self, events, screen, GNUI, btn)
	silly:promptFile(function (absolutePath,b,c,d)
		print(absolutePath,b,c,d)
		if absolutePath then
			local resourcePath = absolutePath:match("/data/(.+)$")
			local extension = resourcePath:match("%.([^.]+)$")
			local importer = IMPORTERS[extension]
			if importer then
				importer(resourcePath)
				notify("Importing "..extension.." file")
			else
				notify("No importer found for extension: "..extension)
			end
		end
		if btn.down then
			btn:release()
		end
		self:setActive(false)
	end)
end)