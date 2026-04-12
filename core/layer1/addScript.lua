---@diagnostic disable: undefined-global
if not addScript then
	if silly_backports then
		addScript = function(...) return silly_backports.addScript(silly_backports, ...) end
		getScript = function(...) return silly_backports.getScript(silly_backports, ...) end
		getScripts = function(...) return silly_backports.getScripts(silly_backports, ...) end
	else
		if host:isHost() then
			warn("addScript method not found, disabling feature", "all scripts will be uploaded")
		end
		addScript = function() end
		getScript = function() end
		getScripts = function() end
	end
end
