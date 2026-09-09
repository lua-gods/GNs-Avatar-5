---EXISTS
if host:isHost() and getScript then
	local out = getScript(table.concat({...},"/"))
	COMMENTS_MISSING = (out and out:find("EXISTS")) and true or false
end