local model = models.player.Nameplate
local offset = vec(0,38,0)*0.0625
events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then

		local pos = model:getAnimPos()*0.0625
		nameplate.ENTITY:setPivot(pos+offset)
	end
end)