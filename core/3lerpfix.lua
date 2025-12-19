if host:isHost() then
	function math.lerp(a,b,t)
		assert(type(a) == type(b),"invalid a and b type given,\n ("..type(a)..", "..type(b)..")")
		assert(type(t) == "number","invalid t type given, ("..type(t)..")")
		return a + (b - a) * t
	end
end