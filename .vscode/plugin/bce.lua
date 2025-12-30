local bcedata = require("data.bcedata")
local BCObject = require("bce.object").BCObject

---@class Plugin.BCE
local this = {
  OP = bcedata.OP,
  MODE = bcedata.MODE,
  MODE_MAP = bcedata.MODE_MAP,
  TYPE = bcedata.TYPE
}

---### `[0 .. 1]`
---@alias ub1 integer
---### `[0 .. 15]`
---@alias ub4 integer
---### `[0 .. 255]`
---@alias ub8 integer
---### `[0 .. 131,071]`
---@alias ub17 integer
---### `[0 .. 33,554,431]`
---@alias ub25 integer
---### `[-127 .. 128]`
---@alias sb8 integer
---### `[-65,535 .. 65,536]`
---@alias sb17 integer
---### `[-16,777,215 .. 16,777,216]`
---@alias sb25 integer

---### `[0 .. 255]`
---@alias ubyte integer
---### `[0 .. 65,535]`
---@alias ushort integer
---### `[0 .. 4,294,967,295]`
---@alias uint integer
---### `[0 .. 18,446,744,073,709,551,615]`
---@alias ulong integer

---### `[-128 .. 127]`
---@alias sbyte integer
---### `[-32,768 .. 32,767]`
---@alias sshort integer
---### `[-2,147,483,648 .. 2,147,483,647]`
---@alias sint integer
---### `[-9,223,372,036,854,775,808 .. 9,223,372,036,854,775,807]`
---@alias slong integer

---### `[-3.4e38 .. 3.4e38]`
---@alias float number
---### `[-1.8e308 .. 1.8e308]`
---@alias double number

---@alias luainteger sint | slong
---@alias luanumber float | double
---@alias luastring string | false
---### `[0 .. 9,223,372,036,854,775,807]`
---@alias varint integer

---@alias luaprimitive nil | boolean | luainteger | luanumber | string

---Dumps a function into a Bytecode Object
---@param f function
---@return Plugin.BCE.BCObject
function this.dump(f)
  return BCObject(f)
end


return this
