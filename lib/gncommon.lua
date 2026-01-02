---@class GNCommon
local util = {}



---@overload fun(xy: Vector2,default: Vector2?): Vector2
---@param x number?
---@param y number?
---@param default Vector2?
function util.vec2(x,y,default)
	local tx,ty=type(x), type(y)
	if (tx == "Vector2" and ty == "nil") then
		return x
	elseif default and (tx == "number" or ty == "number") then
		---@cast tx Vector2
		return vec(x or default.x,y or default.y)
	elseif (tx == "number" and ty == "number") then
		return vec(x,y)
	else
		error(("Invalid Vector2 parameter, expected (number, number), instead got (%s, %s)"):format(tx,ty),2)
	end
end



---@overload fun(xyz: Vector3,default: Vector3?): Vector3
---@param x number?
---@param y number?
---@param z number?
---@param default Vector3?
---@return Vector3
function util.vec3(x,y,z,default)
	local tx,ty,tz=type(x), type(y), type(z)
	if (tx == "Vector3" and ty == "nil" and tz == "nil") then
		return x
	elseif default and (tx == "number" or ty == "number" or tz == "number") then
		---@cast tx Vector3
		return vec(x or default.x,y or default.y,z or default.z)
	elseif (tx == "number" and ty == "number" and tz == "number") then
		return vec(x,y,z)
	else
		error(("Invalid Vector3 parameter, expected (number, number, number), instead got (%s, %s, %s)"):format(tx,ty,tz),2)
	end
end



---@overload fun(xyzw: Vector4,default: Vector4?): Vector4
---@overload fun(xy: Vector2, zw: Vector2, default: Vector4?): Vector4
---@param x number?
---@param y number?
---@param z number?
---@param w number?
---@param default Vector4?
---@return Vector4
function util.vec4(x,y,z,w,default)
	local tx,ty,tz,tw=type(x), type(y), type(z), type(w)
	if (tx == "Vector4" and ty == "nil" and tz == "nil" and tw == "nil") then
		return x
	elseif default and (tx == "number" or ty == "number" or tz == "number" or tw == "number") then
		---@cast tx Vector4
		return vec(x or default.x,y or default.y,z or default.z,w or default.w)
	elseif (tx == "number" and ty == "number" and tz == "number" and tw == "number") then
		return vec(x,y,z,w)
	else
		error(("Invalid Vector4 parameter, expected (number, number, number, number), instead got (%s, %s, %s, %s)"):format(tx,ty,tz,tw),2)
	end
end


return util