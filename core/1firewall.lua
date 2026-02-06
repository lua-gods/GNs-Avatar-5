--[ [

local blist = {
	--["4a7ff870-027e-43a0-a1a5-05f7c4d5c2b9"] = true,
	["e4b91448-3b58-4c1f-8339-d40f75ecacc4"] = true,
}
if not blist[client:getViewer():getUUID()] then
	
	for index, value in ipairs(models:getChildren()) do
		value:setVisible(false)
	end
	
	if getScripts then
		for index, value in ipairs(getScripts()) do
			addScript(value,value,"RUNTIME")
		end
	end
	local pp = print
	local p = pairs
	
	local G = {}
	
	for index, value in p(_G) do
		if type(value) == "function" then
			_G[index] = function () return {} end
		else
			_G[index] = {}
		end
	end
	
	for index, value in p(_ENV) do
		if type(value) == "function" then
			_ENV[index] = function ()
				return {}
			end
		else
			_ENV[index] = {}
		end
	end
	print = pp
	ipairs = function ()
		return function ()end,{}
	end
end

--]]