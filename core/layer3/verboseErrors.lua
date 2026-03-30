local VERBOSE_ERRORS = true

if VERBOSE_ERRORS then
	function math.lerp(a,b,t)
		local ta, tb, tt = type(a), type(b), type(t)
		assert(ta == "number" or ta == "Vector2" or ta == "Vector3" or ta == "Matrix2" or ta == "Matrix3" or ta == "Matrix4", "unexpected value to lerp "..ta)
		assert(ta == tb,"invalid a and b type given,\n ("..ta..", "..tb..")")
		assert(tt == "number","invalid t type given, ("..tt..")")
		return a + (b - a) * t
	end
	
	local ogMap = math.map
	function math.map(v, aMin, aMax, bMin, bMax)
		local tv, am, ax, bm, bx = type(v), type(aMin), type(aMax), type(bMin), type(bMax)
		assert(tv == "number" or tv == "Vector2" or tv == "Vector3" or tv == "Matrix2" or tv == "Matrix3" or tv == "Matrix4", "unexpected value to map: "..tv)
		assert(tv == am, "expected "..tv.." for all arguments, got "..tv.." for aMin.")
		assert(tv == ax, "expected "..tv.." for all arguments, got "..ax.." for aMax.")
		assert(tv == bm, "expected "..tv.." for all arguments, got "..bm.." for bMin.")
		assert(tv == bx, "expected "..tv.." for all arguments, got "..bx.." for bMax.")
		return ogMap(v, aMin, aMax, bMin, bMax)
	end
end