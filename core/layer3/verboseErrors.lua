if not host:isHost() then return end
local VERBOSE_ERRORS = true

if VERBOSE_ERRORS then
	
	local function assert(condition,statement)
		if not condition then
			error(statement, 3)
		end
	end
	
	function math.lerp(a,b,t)
		local ta, tb, tt = type(a), type(b), type(t)
		assert(ta == "number" or ta == "Vector2" or ta == "Vector3" or ta == "Matrix2" or ta == "Matrix3" or ta == "Matrix4", "unexpected value to lerp "..ta)
		assert(ta == tb,"tried to lerp invalid types,\n ("..ta..", "..tb..")")
		assert(tt == "number","tried to lerp with invalid t type, ("..tt..")")
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