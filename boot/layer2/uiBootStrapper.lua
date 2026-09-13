if host:isHost() then
	local ok, result = pcall(require,"scripthost.gui")
else
	function notify()
		
	end
end