
---@param id Minecraft.soundID
---@param pitch number?
---@param volume number?
function soundUI(id,pitch,volume)
	sounds:playSound(id,client:getCameraPos()+client:getCameraDir(),volume or 1,pitch or 1)
end