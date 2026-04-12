---EXISTS
if host:isHost() then
	COMMENTS_MISSING = getScript(table.concat({...},"/")):find("EXISTS") and true or false
end