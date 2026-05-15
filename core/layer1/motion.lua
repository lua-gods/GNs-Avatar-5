-- overrides silly:setPos, setVelocity with host:setPos, setVelocity

if not host.setPos then return end
local ogSilly = silly
local proxySilly = {}

local gncommon = require("lib.GNcommon")

proxySilly.setPos = function (self,x,y,z) host:setPos(x,y,z) end
proxySilly.setVelocity = function (self,x,y,z) host:setVelocity(gncommon.vec3(x,y,z):unpack()) end

setmetatable(proxySilly,{
	__index = function (t,i)
		return rawget(t,i) or ogSilly[i]
	end
})
silly = proxySilly