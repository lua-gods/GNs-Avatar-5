local api = {}

---Snaps the given number to the given step
---@param value number
---@param step number
---@return number
function api.snap(value,step)
	return math.floor((value + 0.5) / step) * step
end

---Modulos the angle from -180 to 180
---@param angle number
---@return number
function api.angleDiff(angle)
	return (angle + 180) % 360 - 180
end

return api