if host:isHost() then
	local ok, result = pcall(require,"scripthost.gui")
	if not ok then
		print(result)
	end
else
	function notify()
		
	end
end