---@meta
do return end -- don't execute ever
--- • Spiritual successor to GoofyPlugin
---@class SillyAPI
---@field profiler SillyProfiler
---@field backports BackportsAPI
---@field vehicle SillyVehicleAPI
---@field ping function
local SillyAPI --[[@as SillyAPI]]
silly = SillyAPI
--- Disconnects you from the game, with the specified message.
---@return nil
function SillyAPI:disconnect() end

--- Disconnects you from the game, with the specified message.
---@param msg string
---@return nil
function SillyAPI:disconnect(msg) end

--- Sends meow in chat, because half of figura are cats in disguise.
---@return nil
function SillyAPI:cat() end

--- Returns the current version of SillyPlugin.
---@return string
function SillyAPI:getVersion() end

--- Sets the figura permissions of a user.
--- Pass nil to value to reset to category defaults.
---@param name string
---@param permissionKey string
---@param value boolean
---@return nil
function SillyAPI:setPermission(name, permissionKey, value) end

--- Sets the figura permissions of a user.
--- Pass nil to value to reset to category defaults.
---@param name string
---@param permissionKey string
---@param value number
---@return nil
function SillyAPI:setPermission(name, permissionKey, value) end

--- Sets the figura permissions of a user.
--- Pass nil to value to reset to category defaults.
---@param name string
---@param permissionKey string
---@return nil
function SillyAPI:setPermission(name, permissionKey) end

--- Gets the value of the JVM's nanosecond clock.
--- Only useful for checking how long something takes.
---@return number
function SillyAPI:getNanoTime() end

--- Returns an object that contains timing information for a given avatar. Defaults to yourself.
---@param name string
---@return SillyProfiler
function SillyAPI:getProfiler(name) end

--- Returns an object that contains timing information for a given avatar. Defaults to yourself.
---@return SillyProfiler
function SillyAPI:getProfiler() end

--- Returns if cheats are presently enabled.
---@return boolean
function SillyAPI:cheatsEnabled() end

--- Sets your friction. False to disable friction.
--- Requires cheats.
---@param friction boolean
---@return SillyAPI
function SillyAPI:setFriction(friction) end

--- Sets your friction. False to disable friction.
--- Requires cheats.
---@param friction number
---@return SillyAPI
function SillyAPI:setFriction(friction) end

--- Gets the error text from another avatar.
--- Returns nil if there is no error or if the avatar isnt loaded.
---@param name string
---@return string
function SillyAPI:getError(name) end

--- Disables or enables gravity.
--- Requires cheats.
---@param gravity boolean
---@return SillyAPI
function SillyAPI:setGravity(gravity) end

--- Gets the serverside NBT of a block in the world.
--- Returns nil if the block isnt a block entity.
--- Requires OP level >= 2.
---@param pos Vector3
---@param callback function
---@return nil
function SillyAPI:getBlockEntity(pos, callback) end

--- Sets your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param pos Vector3
---@return nil
function SillyAPI:setPos(pos) end

--- Sets your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:setPos(x, y, z) end

--- Sets your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@param sendPacket boolean
---@return nil
function SillyAPI:setPos(x, y, z, sendPacket) end

--- Sets a fake block in the world.
--- Setting a block to nil removes the fake one.
--- Requires cheats (but runs on clients!)
---@param pos Vector3
---@param block BlockState
---@return nil
function SillyAPI:setBlock(pos, block) end

--- Sets a fake block in the world.
--- Setting a block to nil removes the fake one.
--- Requires cheats (but runs on clients!)
---@param pos Vector3
---@param block string
---@return nil
function SillyAPI:setBlock(pos, block) end

--- Sets a fake block in the world.
--- Setting a block to nil removes the fake one.
--- Requires cheats (but runs on clients!)
---@param blockstate BlockState
---@return nil
function SillyAPI:setBlock(blockstate) end

--- Sets your player's rotation.
--- Requires cheats.
---@param rot Vector2
---@return nil
function SillyAPI:setRot(rot) end

--- Sets your player's rotation.
--- Requires cheats.
---@param x number
---@param y number
---@return nil
function SillyAPI:setRot(x, y) end

--- Sets your player's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyAPI:setVelocity(velocity) end

--- Sets your player's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:setVelocity(x, y, z) end

--- Gets the debug data Figura puts in the F3 menu.
---@return string
function SillyAPI:getFiguraDebugString() end

--- Sets whether or not you get pushed by other entities.
---@param collisions boolean
---@return SillyAPI
function SillyAPI:setEntityCollisions(collisions) end

--- Transforms the GUI's rendering by the given Matrix4. Passing nil resets it.
---@param mat Matrix4
---@return SillyAPI
function SillyAPI:setGuiMatrix(mat) end

--- Sets the figura permission category of a user.
--- Pass nil to reset the user to the default permission category.
---@param name string
---@param category string
---@return nil
function SillyAPI:setPermissionCategory(name, category) end

--- Sets the figura permission category of a user.
--- Pass nil to reset the user to the default permission category.
---@param name string
---@return nil
function SillyAPI:setPermissionCategory(name) end

--- Updates the size of the avatar figura shows you.
--- Only useful in NBT-transforming contexts (like using addScript)
---@return nil
function SillyAPI:updateAvatarSize() end

--- Tells you what bumpscocity does.
---@return string
function SillyAPI:whatDoesBumpscocityDo() end

--- Gets the current bumpscocity.
---@return number
function SillyAPI:getBumpscocity() end

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@param state boolean
---@return SillyAPI
function SillyAPI:setHudElementVisible(element, state) end

--- Sets the visibility of a hud element.
---@param elements table
---@param state boolean
---@return SillyAPI
function SillyAPI:setHudElementVisible(elements, state) end

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@return SillyAPI
function SillyAPI:setHudElementVisible(element) end

--- Sets if your player should act like a spectator.
--- Requires cheats.
---@param state boolean
---@return nil
function SillyAPI:setNoclip(state) end

--- Sets whether or not fake blocks are enabled locally.
--- Defaults to true.
---@param state boolean
---@return SillyAPI
function SillyAPI:setFakeBlocksEnabled(state) end

--- Runs figura's code minifiers on the provided string. Defaults to the current set level.
---@param script string
---@param level string
---@return string
function SillyAPI:formatScript(script, level) end

--- Runs figura's code minifiers on the provided string. Defaults to the current set level.
---@param script string
---@return string
function SillyAPI:formatScript(script) end

--- Forces subscribing to an avatar's pings. Useful for cross-server cross-avatar communication.
---@param uuid string
---@param state boolean
---@return SillyAPI
function SillyAPI:setSubscribePings(uuid, state) end

--- Sets your player's body rotation.
--- This is purely visual, and does not need cheats.
---@param rot number
---@return SillyAPI
function SillyAPI:setBodyRot(rot) end

--- Gets info about who placed a fake block at a position.
---@param pos Vector3
---@return table
function SillyAPI:getFakeBlockInfo(pos) end

--- Gets info about who placed a fake block at a position.
---@param x number
---@param y number
---@param z number
---@return table
function SillyAPI:getFakeBlockInfo(x, y, z) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@param mayFly boolean
---@return nil
function SillyAPI:setFly(mayFly) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@return nil
function SillyAPI:setFly() end

--- Returns the nameplates of another avatar.
---@param username string
---@return table
function SillyAPI:getAvatarNameplate(username) end

--- avatar:getColor() except for other avatars.
---@param username string
---@return string
function SillyAPI:getAvatarColor(username) end

--- Loads an avatar from your avatar folder.
---@param path string
---@return nil
function SillyAPI:loadLocalAvatar(path) end

--- Gets the permissions of an avatar. Defaults to yourself.
---@param name string
---@return table
function SillyAPI:getPermissions(name) end

--- Gets the permissions of an avatar. Defaults to yourself.
---@return table
function SillyAPI:getPermissions() end


--- • Useful 0.1.6 features, backported.
---
--- • Exists under the global "silly_backports", or under "silly.backports".
---
--- • Also see FOX's Misc Figura Backport!
---@class BackportsAPI
---@field PRE_RENDER Event
local BackportsAPI --[[@as BackportsAPI]]
silly_backports = BackportsAPI
--- Takes a path to the script and returns the contents of the script.
--- This is different from using avatar:getNBT since the NBT stores byte arrays instead of a string
---@param scriptName string
---@return string
function BackportsAPI:getScript(scriptName) end

--- Takes a path to the script, the contents of the script, and what side the script should be added to.
--- If the contents are nil, then the script is removed from the avatar.
--- Side must be either "NBT", "RUNTIME", or "BOTH". If nil, it will default to "BOTH".
---@param scriptName string
---@return nil
function BackportsAPI:addScript(scriptName) end

--- Takes a path to the script, the contents of the script, and what side the script should be added to.
--- If the contents are nil, then the script is removed from the avatar.
--- Side must be either "NBT", "RUNTIME", or "BOTH". If nil, it will default to "BOTH".
---@param scriptName string
---@param scriptContents string
---@return nil
function BackportsAPI:addScript(scriptName, scriptContents) end

--- Takes a path to the script, the contents of the script, and what side the script should be added to.
--- If the contents are nil, then the script is removed from the avatar.
--- Side must be either "NBT", "RUNTIME", or "BOTH". If nil, it will default to "BOTH".
---@param scriptName string
---@param scriptContents string
---@param side string
---@return nil
function BackportsAPI:addScript(scriptName, scriptContents, side) end

--- Returns a table of all scripts in the avatar with the name as the index and the contents as the value. If a string is supplied then all scripts starting with the string will be returned
---@return table
function BackportsAPI:getScripts() end

--- Returns the UUID of the avatar that is calling your stored functions, or 'nil' if there is none (usually because you're not calling it from within a stored function)
---@return string
function BackportsAPI:getCaller() end


--- • Silly's Vehicle API
---@class SillyVehicleAPI
local SillyVehicleAPI --[[@as SillyVehicleAPI]]

--- Sets your vehicle's position.
--- Requires cheats.
---@param pos Vector3
---@return nil
function SillyVehicleAPI:setPos(pos) end

--- Sets your vehicle's position.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyVehicleAPI:setPos(x, y, z) end

--- Sets your vehicle's rotation.
--- Requires cheats.
---@param rot Vector2
---@return nil
function SillyVehicleAPI:setRot(rot) end

--- Sets your vehicle's rotation.
--- Requires cheats.
---@param x number
---@param y number
---@return nil
function SillyVehicleAPI:setRot(x, y) end

--- Sets your vehicle's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyVehicleAPI:setVelocity(velocity) end

--- Sets your vehicle's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyVehicleAPI:setVelocity(x, y, z) end


--- • Silly Nanosecond Profiler
---@class SillyProfiler
local SillyProfiler --[[@as SillyProfiler]]

--- Returns a table of each timing.
--- Pass true to only get the last execution.
---@param onlyLast boolean
---@return table
function SillyProfiler:getTimes(onlyLast) end

--- Returns a table of each timing.
--- Pass true to only get the last execution.
---@return table
function SillyProfiler:getTimes() end

--- Gets the time it took to execute the tick event the last 60 times.
---@return table
function SillyProfiler:getTickTimes() end

--- Gets the time it took to execute the render event the last 60 times.
---@return table
function SillyProfiler:getRenderEventTimes() end

--- Gets the time it took to render the avatar the last 60 times.
---@return table
function SillyProfiler:getRenderTimes() end

--- Gets the time it took to execute the world tick event the last 60 times.
---@return table
function SillyProfiler:getWorldTickTimes() end

--- Gets the time it took to execute the world render event the last 60 times.
---@return table
function SillyProfiler:getWorldRenderTimes() end


--- • Silly Lua GuiGraphics Wrapper
---@class LuaGraphicsAPI
local LuaGraphicsAPI --[[@as LuaGraphicsAPI]]

--- Draws a texture to the screen.
---@param texture Texture
---@param pos Vector2
---@param region Vector4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blit(texture, pos, region) end

--- Draws a texture to the screen.
---@param texture Texture
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blit(texture, pos) end

--- Draws a texture to the screen.
---@param resourceLocation string
---@param pos Vector2
---@param region Vector4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blit(resourceLocation, pos, region) end

--- Draws a texture to the screen.
---@param resourceLocation string
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blit(resourceLocation, pos) end

--- Returns if this LuaGraphics instance can no longer be used.
---@return boolean
function LuaGraphicsAPI:isRevoked() end

--- Discards anything rendered outside this box.
--- Pass nil to disable.
--- (Multiple scissors can be on at once, passing nil will only disable the latest one!)
---@param region Vector4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:setScissors(region) end

--- Discards anything rendered outside this box.
--- Pass nil to disable.
--- (Multiple scissors can be on at once, passing nil will only disable the latest one!)
---@param x number
---@param y number
---@param z number
---@param w number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:setScissors(x, y, z, w) end

--- Discards anything rendered outside this box.
--- Pass nil to disable.
--- (Multiple scissors can be on at once, passing nil will only disable the latest one!)
---@return LuaGraphicsAPI
function LuaGraphicsAPI:setScissors() end

--- Draws a string to the screen.
---@param string string
---@param pos Vector2
---@param width number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitString(string, pos, width) end

--- Draws a string to the screen.
---@param string string
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitString(string, pos) end

--- Draws a string to the screen.
---@param string string
---@param x number
---@param y number
---@param width number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitString(string, x, y, width) end

--- Draws a string to the screen.
---@param string string
---@param x number
---@param y number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitString(string, x, y) end

--- Draws an item to the screen.
---@param stackString string
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitItem(stackString, pos) end

--- Draws an item to the screen.
---@param stackString string
---@param x number
---@param y number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitItem(stackString, x, y) end

--- Draws an item to the screen.
---@param itemStack ItemStack
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitItem(itemStack, pos) end

--- Draws an item to the screen.
---@param itemStack ItemStack
---@param x number
---@param y number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitItem(itemStack, x, y) end

--- Pushes a matrix onto the Pose Stack.
--- This will affect all subsequent blits up until the pose is popped.
---@param matrix Matrix4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:pushPoseMatrix(matrix) end

--- Removes the latest value of the Pose Stack.
--- See: LuaGraphics:pushPoseMatrix()
---@return LuaGraphicsAPI
function LuaGraphicsAPI:popPose() end

--- Draws an entity to the screen.
---@param entity LivingEntity
---@param pos Vector2
---@param rot Vector3
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitEntity(entity, pos, rot) end


--- @alias SillyGUIElement "HOTBAR" | "EXPERIENCE_BAR" | "JUMP_METER" | "SELECTED_ITEM_NAME" | "PLAYER_HEALTH" | "PLAYER_HUNGER" | "VEHICLE_HEALTH" | "VIGNETTE" | "SPYGLASS_OVERLAY" | "TEXTURE_OVERLAY" | "PORTAL_OVERLAY" | "EFFECTS" | "CHAT" | "BOSS_HEALTH_OVERLAY" | "PLAYER_TAB_OVERLAY" | "SUBTITLE_OVERLAY" | "ARMOR_BAR"



---@class EventsAPI
local event = {}

---@class Event.ERROR: Event
local ERROR
---@class Event.GUI_RENDER: Event
local GUI_RENDER

---@alias Event.ERROR.func fun(err: string): boolean
---@alias Event.GUI_RENDER.func fun(graphics: LuaGraphicsAPI, delta: number)


---@generic self
---@param self self
---@param func Event.ERROR.func
---@param name? string
---@return self
function ERROR:register(func, name) end

---@generic self
---@param self self
---@param func Event.GUI_RENDER.func
---@param name? string
---@return self
function GUI_RENDER:register(func, name) end

event.ERROR = nil ---@type Event.ERROR | Event.ERROR.func
event.error = nil ---@type Event.ERROR | Event.ERROR.func
event.GUI_RENDER = nil ---@type Event.GUI_RENDER | Event.GUI_RENDER.func
event.gui_render = nil ---@type Event.GUI_RENDER | Event.GUI_RENDER.func
