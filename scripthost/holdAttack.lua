local attack = keybinds:fromVanilla("key.attack")

local SPEED = 5

local counter = 0
events.TICK:register(function ()
	if attack:isPressed() and player:getHeldItem().id:find("sword") then
		counter = counter - 1
		if counter < 1 then
			silly:setBindPressed("key.attack",true)
			counter = SPEED
		end
	else
		counter = 0
	end
end)