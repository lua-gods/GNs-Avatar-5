function isTrue(boolean)
	assert(type(boolean) == "boolean", "expected boolean, got "..type(boolean))
	if boolean then
		return true
	else
		return false
	end
end

function isFalse(boolean)
	assert(type(boolean) == "boolean", "expected boolean, got "..type(boolean))
	if boolean then
		return false
	else
		return true
	end
end