---@class HostAPI
local HostAPI = figuraMetatables.HostAPI.__index
local __orig_sendChatMessage = HostAPI.sendChatMessage

---comment
---@param msg string
---@param force_tellraw_store boolean?
---@param selector string?
---@param emoji string?
---@return HostAPI
function HostAPI:sendChatMessage(msg, force_tellraw_store, selector, emoji)
    force_tellraw_store = force_tellraw_store or false
    selector = selector or "@a"
    emoji = emoji or ":oneshot:"
    if (#msg <= 256 and not force_tellraw_store) or not player:getPermissionLevel() == 4 then
        return __orig_sendChatMessage(self, msg)
    end

    local chunks = math.ceil(#msg / 150)
    self:sendChatCommand("/data modify storage gn:chat msg set value []")
    for i = 1, chunks, 1 do
        self:sendChatCommand(("/data modify storage gn:chat msg append value %q"):format(toJson({text=msg:sub((i-1)*150+1, i*150)})))
    end
    self:sendChatCommand('/tellraw ' .. selector .. ' ' .. toJson {
        {text=emoji .. " ", color="#C0FFEE"},
        {
        translate = "%s :|: %s",
        with = {
            avatar:getEntityName(),
            {
                nbt = "msg[]",
                storage = "gn:chat",
                interpret = true, 
                separator = ""
            }
        }
    }})
    return self
end

events.CHAT_SEND_MESSAGE:register(function (message)
    local op = (player:getPermissionLevel() >= 2)
    if not message then return message end
    if (message:sub(1,1) == "!") and op then
        host:sendChatMessage(message:sub(2), true, nil, ":globe:")
        host:appendChatHistory(message)
    elseif (message:sub(1,1) == "^") and op then
        host:sendChatMessage(message:sub(2), true, "@a[distance=..25]", ":circle:")
        host:appendChatHistory(message)
    else
        return message
    end
end)