events.TICK:register(function ()
	if player:getVehicle() then
		silly.vehicle:setRot(0,player:getRot().y)
	end
end)