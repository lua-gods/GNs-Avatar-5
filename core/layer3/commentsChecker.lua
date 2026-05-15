---EXISTS
if host:isHost() and getScript then
	COMMENTS_MISSING = getScript(table.concat({...},"/")):find("EXISTS") and true or false
end