local function getPath()
	return select(2, pcall(function() error("", 1) end)):match("^([^\n:]*):")
end

function warn(...)
	local ok, result = pcall(toJson,{
		{
			text = "[warn] : " .. tostring(getPath()):gsub("/", " > ") .. " > \n",
			color = "yellow",
		},
		{
			text = "  " .. table.concat({ ... }, "\n  ") .. "\n",
			color = "gray",
		},
	})
	if ok then
		printJson(result)
	end
end
