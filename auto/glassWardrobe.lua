# flags: host_only

events.WORLD_RENDER:register(function (delta)
	local isFiguraWardrobe = (host:getScreen() == "org.figuramc.figura.gui.screens.WardrobeScreen")
	renderer:setPostEffect(isFiguraWardrobe and "bokeh" or nil)
end)