Lua
---@meta
do return end -- don't execute ever
--- • Spiritual successor to GoofyPlugin
---@class SillyAPI
---@field compats SillyCompatsAPI
---@field profiler SillyProfiler
---@field backports BackportsAPI
---@field collection SillyCollectionAPI
---@field vehicle SillyVehicleAPI
local SillyAPI --[[@as SillyAPI]]
silly = SillyAPI
--- Disconnects you from the game, with the specified message.
---@return nil
function SillyAPI:disconnect() end

--- Disconnects you from the game, with the specified message.
---@param msg string
---@return nil
function SillyAPI:disconnect(msg) end

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

--- Returns the current version of SillyPlugin.
---@return string
function SillyAPI:getVersion() end

--- Sends meow in chat, because half of figura are cats in disguise.
---@return nil
function SillyAPI:cat() end

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

--- Turns a string of code into a list of AST tokens.
---@param code string
---@return table
function SillyAPI:tokenize(code) end

--- Gets the value of the JVM's nanosecond clock.
--- Only useful for checking how long something takes.
---@return number
function SillyAPI:getNanoTime() end

--- Returns the server ping of the specified target (defaults to yourself)
---@param uuid string
---@return number
function SillyAPI:getLatency(uuid) end

--- Returns the server ping of the specified target (defaults to yourself)
---@return number
function SillyAPI:getLatency() end

--- Returns an object that contains timing information for a given avatar. Defaults to yourself.
---@param name string
---@return SillyProfiler
function SillyAPI:getProfiler(name) end

--- Returns an object that contains timing information for a given avatar. Defaults to yourself.
---@return SillyProfiler
function SillyAPI:getProfiler() end

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

--- Sets your player's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyAPI:setVel(velocity) end

--- Sets your player's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:setVel(x, y, z) end

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

--- Applies emojis to the text component.
---@param text string
---@return string
function SillyAPI:applyEmojis(text) end

--- Gets the error text from another avatar.
--- Returns nil if there is no error or if the avatar isnt loaded.
---@param name string
---@return string
function SillyAPI:getError(name) end

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

--- Sets your friction. False to disable friction.
--- Requires cheats.
---@param friction boolean
---@param inAir boolean
---@return SillyAPI
function SillyAPI:setFriction(friction, inAir) end

--- Sets your friction. False to disable friction.
--- Requires cheats.
---@param friction number
---@param inAir boolean
---@return SillyAPI
function SillyAPI:setFriction(friction, inAir) end

--- Sets whether or not fake blocks are enabled locally.
--- Defaults to true.
---@param state boolean
---@return SillyAPI
function SillyAPI:setFakeBlocksEnabled(state) end

--- Sets whether or not fake blocks are enabled locally.
--- Defaults to true.
---@param state boolean
---@return SillyAPI
function SillyAPI:setBlocksEnabled(state) end

--- Runs figura's code minifiers on the provided string. Defaults to the current set level.
---@param script string
---@param level SillyFormatLevel
---@return string
function SillyAPI:formatScript(script, level) end

--- Runs figura's code minifiers on the provided string. Defaults to the current set level.
---@param script string
---@return string
function SillyAPI:formatScript(script) end

--- Makes a table read-only.
---@param tbl table
---@return table
function SillyAPI:freezeTable(tbl) end

--- Sets the day time locally.
--- Requires cheats.
---@param time number
---@return SillyAPI
function SillyAPI:setDayTime(time) end

--- Sets the day time locally.
--- Requires cheats.
---@return SillyAPI
function SillyAPI:setDayTime() end

--- Returns the *true* velocity of your player.
--- May not be accurate on others' ends
---@return Vector3
function SillyAPI:getDeltaMovement() end

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

--- Gets info about who placed a fake block at a position.
---@param pos Vector3
---@return table
function SillyAPI:getBlockInfo(pos) end

--- Gets info about who placed a fake block at a position.
---@param x number
---@param y number
---@param z number
---@return table
function SillyAPI:getBlockInfo(x, y, z) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@param mayFly boolean
---@param isFly boolean
---@return nil
function SillyAPI:setFly(mayFly, isFly) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@param mayFly boolean
---@return nil
function SillyAPI:setFly(mayFly) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@return nil
function SillyAPI:setFly() end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@param mayFly boolean
---@param isFly boolean
---@return nil
function SillyAPI:setCanFly(mayFly, isFly) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@param mayFly boolean
---@return nil
function SillyAPI:setCanFly(mayFly) end

--- Allows overriding if you can fly or not.
--- Requires cheats.
---@return nil
function SillyAPI:setCanFly() end

--- Returns a table of username -> uuid.
--- Effectively the inverse of getPlayerNames()
---@return table
function SillyAPI:getPlayersUUIDs() end

--- Returns a table of uuid -> username.
--- Effectively the inverse of getPlayerUUIDs()
---@return table
function SillyAPI:getPlayerNames() end

--- Adds to your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param pos Vector3
---@return nil
function SillyAPI:addPos(pos) end

--- Adds to your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:addPos(x, y, z) end

--- Adds to your player's position.
--- sendPacket controls whether or not to send a MovePlayer packet instead.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@param sendPacket boolean
---@return nil
function SillyAPI:addPos(x, y, z, sendPacket) end

--- adds to your player's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyAPI:addVelocity(velocity) end

--- adds to your player's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:addVelocity(x, y, z) end

--- adds to your player's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyAPI:addVel(velocity) end

--- adds to your player's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyAPI:addVel(x, y, z) end

--- Adds to your player's rotation.
--- Requires cheats.
---@param rot Vector2
---@return nil
function SillyAPI:addRot(rot) end

--- Adds to your player's rotation.
--- Requires cheats.
---@param x number
---@param y number
---@return nil
function SillyAPI:addRot(x, y) end

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

--- Sets visibility of a player.
---@param player string
---@param visible boolean
---@return SillyAPI
function SillyAPI:setPlayerVisible(player, visible) end

--- Gets the memory used by your avatar.
--- Requires "Track script memory usage" in settings.
---@return number
function SillyAPI:getMemoryUsage() end

--- Gets the living objects tracked by Sillyplugin in your avatar.
--- Requires "Track script memory usage" in settings.
---@return table
function SillyAPI:getAliveObjects() end

--- Returns false if you are hidden via silly:setPlayerVisible.
--- This is NOT a visibility check.
---@return boolean
function SillyAPI:isPlayerVisible() end

--- Sends an info message to the game's log.
---@param msg string
---@return nil
function SillyAPI:logAsInfo(msg, ...) end

--- Sends an error message to the game's log.
---@param msg string
---@return nil
function SillyAPI:logAsError(msg, ...) end

--- Swaps two slots. `slotB` MUST be in the hotbar (0-8), or `40` for offhand.
--- Requires cheats.
---@param slotA string
---@param slotB string
---@return nil
function SillyAPI:swapSlot(slotA, slotB) end

--- Swaps two slots. `slotB` MUST be in the hotbar (0-8), or `40` for offhand.
--- Requires cheats.
---@param slotA number
---@param slotB string
---@return nil
function SillyAPI:swapSlot(slotA, slotB) end

--- Swaps two slots. `slotB` MUST be in the hotbar (0-8), or `40` for offhand.
--- Requires cheats.
---@param slotA string
---@param slotB number
---@return nil
function SillyAPI:swapSlot(slotA, slotB) end

--- Swaps two slots. `slotB` MUST be in the hotbar (0-8), or `40` for offhand.
--- Requires cheats.
---@param slotA number
---@param slotB number
---@return nil
function SillyAPI:swapSlot(slotA, slotB) end

--- Opens a native system file prompter.
---@param callback function
---@param filterDesc string
---@param allowMultiple boolean
---@return nil
function SillyAPI:promptFile(callback, ..., filterDesc, allowMultiple) end

--- Opens a native system file prompter.
---@param callback function
---@param filterDesc string
---@return nil
function SillyAPI:promptFile(callback, ..., filterDesc) end

--- Opens a native system file prompter.
---@param callback function
---@return nil
function SillyAPI:promptFile(callback, ...) end

--- Opens a native system file prompter.
---@param callback function
---@return nil
function SillyAPI:promptFile(callback) end

--- Gets the raw string of a text component.
---@param text string
---@return string
function SillyAPI:getRawString(text) end

--- Gets the boss bars your client can see.
---@return table
function SillyAPI:getBossBars() end

--- Stops your avatar's execution.
---@return nil
function SillyAPI:stopAvatar() end

--- Stops your avatar's execution.
---@param msg string
---@return nil
function SillyAPI:stopAvatar(msg) end

--- Gets the resource location of another player's skin.
--- A callback is only required if a name is passed instead of a PlayerAPI.
--- There are no guarantees as to whether or not the callback will be fired.
---@param player Player
---@return string
function SillyAPI:getSkin(player) end

--- Gets the resource location of another player's skin.
--- A callback is only required if a name is passed instead of a PlayerAPI.
--- There are no guarantees as to whether or not the callback will be fired.
---@param name string
---@param callback function
---@return Texture
function SillyAPI:getSkin(name, callback) end

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

--- Sets whether or not a keybind is pressed.
--- Requires cheats.
---@param id Minecraft.keybind
---@param state boolean
---@return nil
function SillyAPI:setBindPressed(id, state) end

--- Sets the position of your mouse.
--- Doesnt work on Wayland.
--- Requires cheats.
---@param x number
---@param y number
---@return nil
function SillyAPI:setMousePos(x, y) end

--- Sets the position of your mouse.
--- Doesnt work on Wayland.
--- Requires cheats.
---@param pos Vector2
---@return nil
function SillyAPI:setMousePos(pos) end

--- Transforms a texture into a base64 string, using a more space-efficient method than <Texture>:save()
---@param texture Texture
---@return string
function SillyAPI:saveTextureIndexed(texture) end

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

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@param state boolean
---@return SillyAPI
function SillyAPI:setRenderHudElement(element, state) end

--- Sets the visibility of a hud element.
---@param elements table
---@param state boolean
---@return SillyAPI
function SillyAPI:setRenderHudElement(elements, state) end

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@return SillyAPI
function SillyAPI:setRenderHudElement(element) end

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@param state boolean
---@return SillyAPI
function SillyAPI:setHudElementDisabled(element, state) end

--- Sets the visibility of a hud element.
---@param elements table
---@param state boolean
---@return SillyAPI
function SillyAPI:setHudElementDisabled(elements, state) end

--- Sets the visibility of a hud element.
---@param element SillyGUIElement
---@return SillyAPI
function SillyAPI:setHudElementDisabled(element) end

--- Sets if your player should act like a spectator.
--- Requires cheats.
---@param state boolean
---@return nil
function SillyAPI:setNoclip(state) end

--- Clears all fake blocks this avatar has placed.
---@return nil
function SillyAPI:clearFakeBlocks() end

--- Gets the window you're focusing.
---@param override string
---@return table
function SillyAPI:getFocusedWindow(override) end

--- Gets the window you're focusing.
---@return table
function SillyAPI:getFocusedWindow() end

--- Sets your gravity.
--- Requires cheats.
---@param gravity boolean
---@return SillyAPI
function SillyAPI:setGravity(gravity) end

--- Sets your gravity.
--- Requires cheats.
---@param gravity number
---@return SillyAPI
function SillyAPI:setGravity(gravity) end

--- Gets the serverside NBT of a block in the world.
--- Returns nil if the block isnt a block entity.
--- Requires OP level >= 2.
---@param pos Vector3
---@param callback function
---@return nil
function SillyAPI:getBlockEntity(pos, callback) end

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

--- Gets the permissions of an avatar. Defaults to yourself.
---@param name string
---@return table
function SillyAPI:getPermissions(name) end

--- Gets the permissions of an avatar. Defaults to yourself.
---@return table
function SillyAPI:getPermissions() end


--- • Useful 0.1.7 features, backported.
---
--- • Exists under the global "silly_backports", or under "silly.backports".
---
--- • Also see FOX's Misc Figura Backport!
---@class BackportsAPI
---@field PRE_RENDER Event
local BackportsAPI --[[@as BackportsAPI]]
silly_backports = BackportsAPI
--- Wraps a Texture in a BackportedTexture.
---@param tex Texture
---@return Texture
function BackportsAPI:wrapTexture(tex) end

--- Returns the UUID of the avatar that is calling your stored functions, or 'nil' if there is none (usually because you're not calling it from within a stored function)
---@return string
function BackportsAPI:getCaller() end

--- Takes a path to the script and returns the contents of the script.
--- This is different from using avatar:getNBT since the NBT stores byte arrays instead of a string
---@param scriptName string
---@return string
function BackportsAPI:getScript(scriptName) end

--- Returns a table of all scripts in the avatar with the name as the index and the contents as the value. If a string is supplied then all scripts starting with the string will be returned
---@return table
function BackportsAPI:getScripts() end

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


--- • Silly's Vehicle API
---
--- • Access with `silly.vehicle`
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

--- Sets your vehicle's velocity.
--- Requires cheats.
---@param velocity Vector3
---@return nil
function SillyVehicleAPI:setVel(velocity) end

--- Sets your vehicle's velocity.
--- Requires cheats.
---@param x number
---@param y number
---@param z number
---@return nil
function SillyVehicleAPI:setVel(x, y, z) end

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


--- • Silly Nanosecond Profiler
---
--- • Access with `silly.profiler` or `silly:getProfiler(name/uuid)`
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

--- Returns the memory usage of the avatar this profiler points to.
--- Requires "Track script memory usage" in settings.
---@return number
function SillyProfiler:getMemoryUsage() end


--- • Silly Lua GuiGraphics Wrapper
---
--- • Access with events.GUI_RENDER
---@class LuaGraphicsAPI
local LuaGraphicsAPI --[[@as LuaGraphicsAPI]]

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

--- Draws a string to the screen, with support for hovertext.
---@param string string
---@param pos Vector2
---@param width number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitStringWithHover(string, pos, width) end

--- Draws a string to the screen, with support for hovertext.
---@param string string
---@param pos Vector2
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitStringWithHover(string, pos) end

--- Draws a string to the screen, with support for hovertext.
---@param string string
---@param x number
---@param y number
---@param width number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitStringWithHover(string, x, y, width) end

--- Draws a string to the screen, with support for hovertext.
---@param string string
---@param x number
---@param y number
---@return LuaGraphicsAPI
function LuaGraphicsAPI:blitStringWithHover(string, x, y) end

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

--- Pushes a tint color to the stack.
--- Beware that tinting is incredibly unreliable, and requires some wrestling to get it to do what you want.
---@param col Vector4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:pushTint(col) end

--- Pops a tint color from the stack.
--- See the warning on <LuaGraphicsAPI>:pushTint
---@return LuaGraphicsAPI
function LuaGraphicsAPI:popTint() end

--- Pushes a matrix onto the Pose Stack.
--- This will affect all subsequent blits up until the pose is popped.
---@param matrix Matrix4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:pushPoseMatrix(matrix) end

--- Pushes a matrix onto the Pose Stack.
--- This will affect all subsequent blits up until the pose is popped.
---@param matrix Matrix4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:pushPose(matrix) end

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

--- Fills a region on the screen with a color.
---@param color Vector3
---@param region Vector4
---@return LuaGraphicsAPI
function LuaGraphicsAPI:fill(color, region) end


--- • Various useful functions for tables
---
--- • from Goofyplugin
---@class SillyCollectionAPI
local SillyCollectionAPI --[[@as SillyCollectionAPI]]

--- Gets the quotient of all inputted numbers
---@param tbl table
---@return any
function SillyCollectionAPI.quotient(tbl) end

--- Gets the difference of all inputted numbers
---@param tbl table
---@return any
function SillyCollectionAPI.difference(tbl) end

--- Runs a function on each element of the array
---@param tbl table
---@param func function
---@return table
function SillyCollectionAPI.each(tbl, func) end

--- Gets the sum of all inputted numbers
---@param tbl table
---@return any
function SillyCollectionAPI.sum(tbl) end

--- Gets the product of all inputted numbers
---@param tbl table
---@return any
function SillyCollectionAPI.product(tbl) end

--- Transforms each element of the array in-place
---@param tbl table
---@param func function
---@return table
function SillyCollectionAPI.map(tbl, func) end

--- Returns elements of the array matching a given predicate
---@param tbl table
---@param func function
---@return table
function SillyCollectionAPI.filter(tbl, func) end

--- Runs a function on each element and concatenates the resulting arrays
---@param tbl table
---@param func function
---@return table
function SillyCollectionAPI.flatMap(tbl, func) end


--- • figura.docs.silly.snd
---@class SillySoundEventData
---@field id string
---@field subtitle string
---@field volume number
---@field pitch number
---@field pos Vector3
---@field looping boolean
---@field channels number
---@field owner string
---@field category string
---@field file string
---@field cancelled boolean
local SillySoundEventData --[[@as SillySoundEventData]]

--- Cancels the sound being played.
---@return nil
function SillySoundEventData:cancel() end


--- • Sillyplugin's SVC compat API.
---
--- • Access via silly.compats.svc (if simple voice chat is installed)
---@class SillyVoicechatCompatAPI
local SillyVoicechatCompatAPI --[[@as SillyVoicechatCompatAPI]]

--- Returns a percentage between 0-100 on how loud someone is, on average.
---@param uuid string
---@return number
function SillyVoicechatCompatAPI:getVolume(uuid) end

--- Returns a percentage between 0-100 on how loud someone is, on average.
---@param uuid string
---@param raw boolean
---@return number
function SillyVoicechatCompatAPI:getVolume(uuid, raw) end

--- Returns a percentage between 0-100 on how loud someone is, on average.
---@return number
function SillyVoicechatCompatAPI:getVolume() end

--- Sets whether or not you're muted.
---@param state boolean
---@return nil
function SillyVoicechatCompatAPI:setMuted(state) end

--- Sets whether or not you are deafened.
---@param state boolean
---@return nil
function SillyVoicechatCompatAPI:setDeafened(state) end

--- Returns whether or not a player is deafened.
---@param uuid string
---@return boolean
function SillyVoicechatCompatAPI:isDeafened(uuid) end

--- Returns whether or not a player is deafened.
---@return boolean
function SillyVoicechatCompatAPI:isDeafened() end

--- Returns whether or not a player is talking.
---@param uuid string
---@return boolean
function SillyVoicechatCompatAPI:isTalking(uuid) end

--- Returns whether or not a player is talking.
---@return boolean
function SillyVoicechatCompatAPI:isTalking() end

--- Returns whether or not you're muted.
--- Only works on host.
---@return boolean
function SillyVoicechatCompatAPI:isMuted() end

--- Returns whether or not a player is disconnected from SVC.
---@param uuid string
---@return boolean
function SillyVoicechatCompatAPI:isDisconnected(uuid) end

--- Returns whether or not a player is disconnected from SVC.
---@return boolean
function SillyVoicechatCompatAPI:isDisconnected() end


--- • Accesses the Vivecraft compatibility API.
---
--- • Most methods accept an optional player UUID; if omitted, they return the avatar owner's VR data.
---
--- • Access with `silly.compats.vivecraft`
---@class VivecraftCompatAPI
local VivecraftCompatAPI --[[@as VivecraftCompatAPI]]

--- Returns true if Vivecraft's VR runtime has been initialized on this client.
---@return boolean
function VivecraftCompatAPI:isVRInitialized() end

--- Returns true if the target player is currently in VR.
--- Defaults to the avatar owner if no UUID is given.
---@return boolean
function VivecraftCompatAPI:isVRActive() end

--- Returns true if the target player is currently in VR.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return boolean
function VivecraftCompatAPI:isVRActive(uuid) end

--- Returns the target player's current world scale multiplier in VR.
--- Defaults to the avatar owner if no UUID is given.
---@return number
function VivecraftCompatAPI:getWorldScale() end

--- Returns the target player's current world scale multiplier in VR.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return number
function VivecraftCompatAPI:getWorldScale(uuid) end

--- Returns the target player's current full body tracking mode as a string.
--- Defaults to the avatar owner if no UUID is given.
---@return string
function VivecraftCompatAPI:getFBTMode() end

--- Returns the target player's current full body tracking mode as a string.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return string
function VivecraftCompatAPI:getFBTMode(uuid) end

--- Returns the position of the target player's VR headset in world space.
--- Defaults to the avatar owner if no UUID is given.
---@return Vector3
function VivecraftCompatAPI:getHeadPos() end

--- Returns the position of the target player's VR headset in world space.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHeadPos(uuid) end

--- Returns the look direction of the target player's VR headset.
--- Defaults to the avatar owner if no UUID is given.
---@return Vector3
function VivecraftCompatAPI:getHeadDir() end

--- Returns the look direction of the target player's VR headset.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHeadDir(uuid) end

--- Returns the rotation of the target player's VR headset as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
---@return Vector3
function VivecraftCompatAPI:getHeadRot() end

--- Returns the rotation of the target player's VR headset as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHeadRot(uuid) end

--- Returns the position of the given hand or body part on the target player in world space.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getHandPos(hand) end

--- Returns the position of the given hand or body part on the target player in world space.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHandPos(hand, uuid) end

--- Returns true if the target player is using left-handed mode in VR.
--- Defaults to the avatar owner if no UUID is given.
---@return boolean
function VivecraftCompatAPI:isLeftHanded() end

--- Returns true if the target player is using left-handed mode in VR.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return boolean
function VivecraftCompatAPI:isLeftHanded(uuid) end

--- Returns the position of the given body part on the target player in world space.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getBodyPartPos(bodyPart) end

--- Returns the position of the given body part on the target player in world space.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getBodyPartPos(bodyPart, uuid) end

--- Returns true if the target player is currently seated in VR.
--- Defaults to the avatar owner if no UUID is given.
---@return boolean
function VivecraftCompatAPI:isSeated() end

--- Returns true if the target player is currently seated in VR.
--- Defaults to the avatar owner if no UUID is given.
---@param uuid string
---@return boolean
function VivecraftCompatAPI:isSeated(uuid) end

--- Returns the direction of the given hand or body part on the target player.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getHandDir(hand) end

--- Returns the direction of the given hand or body part on the target player.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHandDir(hand, uuid) end

--- Returns the rotation of the given hand or body part on the target player as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getHandRot(hand) end

--- Returns the rotation of the given hand or body part on the target player as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param hand SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getHandRot(hand, uuid) end

--- Returns the rotation of the given body part on the target player as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getBodyPartRot(bodyPart) end

--- Returns the rotation of the given body part on the target player as a Vector3 of pitch, yaw, and roll, extracted from the part's quaternion.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getBodyPartRot(bodyPart, uuid) end

--- Returns a table containing all available VR body part data for the target player.
--- Defaults to the avatar owner if no UUID is given.
--- The table includes `fbtMode`, `leftHanded`, `seated`, and a subtable for each body part with `pos`, `rot`, `dir`, and `rot4`.
---@return table
function VivecraftCompatAPI:getPoseData() end

--- Returns a table containing all available VR body part data for the target player.
--- Defaults to the avatar owner if no UUID is given.
--- The table includes `fbtMode`, `leftHanded`, `seated`, and a subtable for each body part with `pos`, `rot`, `dir`, and `rot4`.
---@param uuid string
---@return table
function VivecraftCompatAPI:getPoseData(uuid) end

--- Triggers a haptic pulse on the local client's body part.
--- Only the avatar owner/host can trigger haptics.
--- See the SillyVRBodyPart enum for valid names.
--- Duration, frequency, amplitude, and delay are optional and default to 0.1, 160, 1.0, and 0 respectively.
---@param bodyPart SillyVRBodyPart
---@param duration number
---@param frequency number
---@param amplitude number
---@param delay number
---@return nil
function VivecraftCompatAPI:triggerHaptic(bodyPart, duration, frequency, amplitude, delay) end

--- Sets whether Vivecraft should animate the vanilla player model parts for this avatar.
--- When set to false, the avatar will use vanilla animations for arms/legs instead of VR tracking data, visible to anyone rendering the wearer.
--- Defaults to true.
---@param value boolean
---@return nil
function VivecraftCompatAPI:setVivecraftAnim(value) end

--- Returns whether Vivecraft is currently allowed to animate the vanilla player model parts for this avatar.
---@return boolean
function VivecraftCompatAPI:getVivecraftAnim() end

--- Returns the direction of the given body part on the target player.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@return Vector3
function VivecraftCompatAPI:getBodyPartDir(bodyPart) end

--- Returns the direction of the given body part on the target player.
--- Defaults to the avatar owner if no UUID is given.
--- See the SillyVRBodyPart enum for valid names.
---@param bodyPart SillyVRBodyPart
---@param uuid string
---@return Vector3
function VivecraftCompatAPI:getBodyPartDir(bodyPart, uuid) end


--- @alias SillyGUIElement "HOTBAR" | "EXPERIENCE_BAR" | "JUMP_METER" | "SELECTED_ITEM_NAME" | "PLAYER_HEALTH" | "PLAYER_HUNGER" | "VEHICLE_HEALTH" | "VIGNETTE" | "SPYGLASS_OVERLAY" | "TEXTURE_OVERLAY" | "PORTAL_OVERLAY" | "EFFECTS" | "CHAT" | "BOSS_HEALTH_OVERLAY" | "PLAYER_TAB_OVERLAY" | "SUBTITLE_OVERLAY" | "ARMOR_BAR"
--- @alias SillyFormatLevel "NONE" | "LIGHT" | "HEAVY" | "AST"
--- @alias SillyVRBodyPart "HEAD" | "MAIN_HAND" | "OFF_HAND" | "LEFT_FOOT" | "RIGHT_FOOT" | "WAIST" | "LEFT_KNEE" | "RIGHT_KNEE" | "LEFT_ELBOW" | "RIGHT_ELBOW"

---@class EventsAPI
local event = {}

---@class Event.ERROR: Event
local ERROR
---@class Event.GUI_RENDER: Event
local GUI_RENDER
---@class Event.SILLY_SOUND_EVENT: Event
local SILLY_SOUND_EVENT

---@alias Event.ERROR.func fun(err: string): boolean
---@alias Event.GUI_RENDER.func fun(graphics: LuaGraphicsAPI, delta: number)
---@alias Event.SILLY_SOUND_EVENT.func fun(dt: SillySoundEventData)


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

---@generic self
---@param self self
---@param func Event.SILLY_SOUND_EVENT.func
---@param name? string
---@return self
function SILLY_SOUND_EVENT:register(func, name) end

event.ERROR = nil ---@type Event.ERROR | Event.ERROR.func
event.error = nil ---@type Event.ERROR | Event.ERROR.func
event.GUI_RENDER = nil ---@type Event.GUI_RENDER | Event.GUI_RENDER.func
event.gui_render = nil ---@type Event.GUI_RENDER | Event.GUI_RENDER.func
event.SILLY_SOUND_EVENT = nil ---@type Event.SILLY_SOUND_EVENT | Event.SILLY_SOUND_EVENT.func
event.silly_sound_event = nil ---@type Event.SILLY_SOUND_EVENT | Event.SILLY_SOUND_EVENT.func

---@class SillyCompatsAPI
---@field svc SillyVoicechatCompatAPI?
---@field vivecraft VivecraftCompatAPI?


