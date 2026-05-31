local Sync = require "lib.GNSync"

Sync.changes.color:register(function (value)
	local value = vec(table.unpack(value))
	models.player:setColor(value.xyz)
	models.player:setPrimaryRenderType(value.w == 1 and "CUTOUT_CULL" or "TRANSLUCENT")
	models.player:setOpacity(value.w)
end)