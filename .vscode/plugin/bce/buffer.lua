---A Bytecode Buffer used by the BCE module.
---@class Plugin.BCE.BCBuffer
---@field package bcstr string
---@field bc ubyte[]
---@field pos integer
---@field modified boolean
---@field stack integer[]
---@field marker_count integer
---@field markers {[string]: integer?}
local BCBuffer = {}
local BCBufferMT = {
  __index = BCBuffer,
  ---@param self Plugin.BCE.BCBuffer
  __tostring = function(self)
    self:flush()
    return self.bcstr
  end
}

---@type {[table]: ubyte[]}
local proxied = setmetatable({}, {__mode = "k"})

local function bcnext(tbl, key)
  local k, v = next(proxied[tbl], key)
  if v ~= nil then return k, v end
end

local function bciter(tbl, i)
  local v = proxied[tbl][i]
  if v ~= nil then return i + 1, v end
end

local BufferBCMT = {
  __index = function(self, key) return proxied[self][key] end,
  __newindex = function(self, key, value)
    if not math.tointeger(key) then
      error(("bad index to buffer (integer expected, got %s)"):format(type(value)))
    elseif key < 1 then
      error(("buffer index %d is out of bounds"):format(key), 2)
    elseif value ~= nil and not math.tointeger(value) then
      error(("bad value to buffer index %d (integer expected, got %s)"):format(key, type(value)))
    end

    if self.owner.debug then
      if value then print(("bc[%d] = %02X"):format(key, value)) else print(("bc[%d] = nil"):format(key)) end
      if value > 0xFF or value < 0x00 then print(debug.traceback("big value", 2)) end
    end
    proxied[self][key] = value and (value & 0xFF) or nil
    self.owner.modified = true
  end,
  __len = function(self) return #proxied[self] end,
  __pairs = function(self) return bcnext, self, nil end,
  __ipairs = function(self) return bciter, self, 0 end
}

setmetatable(BCBuffer, {
  ---@param bc string | ubyte[]
  __call = function(_, bc)
    local bcstr
    if type(bc) == "string" then
      bcstr = bc
      bc = {bc:byte(1, #bc)}
    else
      local copy = {}
      for i, byte in ipairs(bc) do
        if math.type(byte) ~= "integer" then error(("value %d is not an integer"):format(i), 2) end
        copy[i] = byte & 0xFF
      end
      bc = copy
      bcstr = string.char(table.unpack(copy))
    end
    ---@cast bc ubyte[]

    local self; self = setmetatable({
      bcstr = bcstr,
      pos = 1, modified = false,
      stack = {},
      marker_count = 0, markers = {}
    }, BCBufferMT)
    self.bc = setmetatable({owner = self}, BufferBCMT)

    proxied[self.bc] = bc
    return self
  end
})

---Push a position to the stack.  
---If `pos` is `nil`, nothing is pushed as a shortcut for `if pos then BCP:pushPos(pos, marker) end`
---@param pos? integer
---@return integer stackpos
function BCBuffer:pushPos(pos, marker)
  if not pos then return #self.stack - self.marker_count end
  local stack = self.stack
  if marker then
    stack[#stack+1] = marker
    self.markers[marker] = (self.markers[marker] or 0) + 1
    self.marker_count = self.marker_count + 1
  end
  stack[#stack+1] = self.pos
  self.pos = pos
  return #stack - self.marker_count
end

if false then
  ---Pop a position from the stack.  
  ---If a marker is given but doesn't exist in the stack, nothing happens.
  ---@param marker? string
  ---@return integer? pos
  function BCBuffer:popPos(marker) end
end

---Pop a position from the stack.  
---If a marker is given but doesn't exist in the stack, nothing happens.
---
---This overload is provided to give the same shortcut that `BCP:pushPos()` has.
---@param pos? integer
---@param marker string
---@return integer? pos
function BCBuffer:popPos(pos, marker)
  if not marker then
    marker = pos
  elseif not pos then
    return nil
  end
  local stack = self.stack
  local res
  if marker then -- If a marker was given, return the position directly after the marker.
    local mrk_count = self.markers[marker]
    if not mrk_count then return nil end
    repeat res = table.remove(stack) until stack[#stack] == marker
    table.remove(stack)
    self.marker_count = self.marker_count - 1
    self.markers[marker] = mrk_count > 1 and (mrk_count - 1) or nil
  elseif #stack > 0 then -- If no marker was given but the stack has a position, pop and return it.
    res = table.remove(stack)
    while type(stack[#stack]) == "string" do
      local mrk = table.remove(stack)
      local mrk_count = self.markers[mrk]
      self.marker_count = self.marker_count - 1
      self.markers[mrk] = mrk_count > 1 and (mrk_count - 1) or nil
    end
  else -- If the stack is empty, reset the current position and return the old position.
    res = self.pos
    self.pos = 1
    return res
  end

  self.pos = res
  return res
end

---Clears all position data. (Including the position stack.)
function BCBuffer:clearPos()
  self.pos = 1
  local stack = self.stack
  while stack[1] ~= nil do table.remove(stack) end

  self.marker_count = 0
  local markers = self.markers
  for k in pairs(markers) do markers[k] = nil end
end

---Reads one byte.
---@param pos? integer
---@return ubyte
function BCBuffer:readByte(pos)
  local start = pos or self.pos
  if not pos then self.pos = self.pos + 1 end
  return self.bc[start]
end

---Reads `len` bytes.
---@param len integer
---@param pos? integer
---@return ubyte ...
function BCBuffer:readBytes(len, pos)
  local start = pos or self.pos
  if not pos then self.pos = self.pos + len end
  return table.unpack(self.bc, start, start + len - 1)
end

---Reads `n` signed bytes.
---@param n integer
---@param pos? integer
---@return sbyte ...
function BCBuffer:readSbytes(n, pos)
  self:flush()
  local start = pos or self.pos
  local bytes = string.char(table.unpack(self.bc, start, start + n - 1))
  if not pos then self.pos = self.pos + n end
  return ("b"):rep(n):unpack(bytes)
end

---Reads an unsigned integer of `size` bytes.  
---Leave nil for native size.
---@param size? integer
---@param pos? integer
---@return uint
function BCBuffer:readUint(size, pos)
  self:flush()
  local start = pos or self.pos
  local res, stop = ("I" .. (size or "")):unpack(self.bcstr, start)
  if not pos then self.pos = stop end
  return res
end

---Reads a signed integer of `size` bytes.  
---Leave nil for native size.
---@param size? integer
---@param pos? integer
---@return sint
function BCBuffer:readInt(size, pos)
  self:flush()
  local start = pos or self.pos
  local res, stop = ("i" .. (size or "")):unpack(self.bcstr, start)
  if not pos then self.pos = stop end
  return res
end

---Reads a VarInt.
---@param pos? integer
---@return varint
function BCBuffer:readVarInt(pos)
  self:flush()
  local bytes = self.bcstr:match("^([\x00-\x7F]*[\x80-\xFF])", pos or self.pos)
  if not bytes then
    self:throw("could not find varint", 2)
  elseif #bytes > 9 then
    local len = #bytes
    self:throw("varint was too long (max of 9 expected, got %d)", 2, len, len, len)
  end

  local res = 0
  for _, b in ipairs{bytes:byte(1, -1)} do res = (res << 7) | (b & 0x7F) end

  if not pos then self.pos = self.pos + #bytes end
  return res
end

---Reads a float.
---@param pos? integer
---@return float
function BCBuffer:readFloat(pos)
  self:flush()
  local start = pos or self.pos
  if not pos then self.pos = self.pos + 4 end
  return (("f"):unpack(self.bcstr, start))
end

---Reads a double.
---@param pos? integer
---@return double
function BCBuffer:readDouble(pos)
  self:flush()
  local start = pos or self.pos
  if not pos then self.pos = self.pos + 8 end
  return (("d"):unpack(self.bcstr, start))
end

---Reads a floating-point number of `size` bytes.  
---Leave nil for Lua Number size.
---@param size? integer
---@param pos? integer
---@return luanumber
function BCBuffer:readNumber(size, pos)
  self:flush()
  local start = pos or self.pos
  local mod = size == 4 and "f" or size == 8 and "d" or size == nil and "n"
    or error(("invalid number size (4/8 expected, got %s)"):format(size), 2)
  local res, stop = mod:unpack(self.bcstr, start)
  if not pos then self.pos = stop end
  return res
end

---Reads a string `n` characters long.
---@param n integer
---@param pos? integer
---@return string
function BCBuffer:readString(n, pos)
  self:flush()
  local start = pos or self.pos
  if not pos then self.pos = self.pos + n end
  return self.bcstr:sub(start, start + n - 1)
end

---Reads a string prefixed with its length.
---
---Null strings return `false`.  
---If `nonull` is set, they return `""` instead.
---@param nonull? boolean
---@param pos? integer
---@return luastring
function BCBuffer:readVarString(nonull, pos)
  self:pushPos(pos, "buf:readVarString")
  local varint = self:readVarInt()
  if varint == 0 then
    self:popPos(pos, "buf:readVarString")
    return nonull and "" or false
  end

  local str = self:readString(varint - 1)
  self:popPos(pos, "buf:readVarString")
  return str
end

---Reads a [format string](command:extension.lua.doc?["en-us/54/manual.html/6.4.2"]).
---@param fmt string
---@param pos? integer
---@return any ...
function BCBuffer:readFmt(fmt, pos)
  self:flush()
  local res = {fmt:unpack(self.bcstr, pos or self.pos)}
  local stop = table.remove(res)
  if not pos then self.pos = stop end
  return table.unpack(res)
end

---Reads a [Lua Pattern](command:extension.lua.doc?["en-us/54/manual.html/6.4.1"]).  
---All Lua Patterns act as if they are prefixed with `^` if they don't already have it.
---@param pattern string
---@param pos? integer
---@return any ...
function BCBuffer:readMatch(pattern, pos)
  self:flush()
  pattern = pattern:gsub("^%^?(.-)(%$?)$", "^%1()%2", 1)
  local res = {self.bcstr:match(pattern, pos or self.pos)}
  local stop = table.remove(res)
  if not stop then return end
  if not pos then self.pos = stop end
  return table.unpack(res)
end

---Writes one byte.
---@param byte ubyte
---@param pos? integer
function BCBuffer:writeByte(byte, pos)
  self.modified = true
  self.bc[pos or self.pos] = byte
  if not pos then self.pos = self.pos + 1 end
end

---Writes multiple signed or unsigned bytes.
---@param bytes (ubyte | sbyte)[]
---@param pos? integer
function BCBuffer:writeBytes(bytes, pos)
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  self.modified = true
  if not pos then self.pos = self.pos + #bytes end
end

---Writes an unsigned integer of `size` bytes.  
---Leave nil for native size.
---@param int uint
---@param size? integer
---@param pos? integer
function BCBuffer:writeUint(int, size, pos)
  local bytes = {("I" .. (size or "")):pack(int):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a signed integer of `size` bytes.  
---Leave nil for native size.
---@param int sint
---@param size? integer
---@param pos? integer
function BCBuffer:writeInt(int, size, pos)
  local bytes = {("i" .. (size or "")):pack(int):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a VarInt.
---@param int varint
---@param pos? integer
function BCBuffer:writeVarInt(int, pos)
  if int >> 63 == 1 then error("value is too big to fit in a varint (value has the 64th bit set)", 2) end
  local bytes = {(int & 0x7F) | 0x80}

  int = int >> 7
  while int ~= 0 do
    table.insert(bytes, 1, int & 0x7F)
    int = int >> 7
  end

  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a float.
---@param flt float
---@param pos? integer
function BCBuffer:writeFloat(flt, pos)
  local bytes = {("f"):pack(flt):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a double.
---@param dbl double
---@param pos? integer
function BCBuffer:writeDouble(dbl, pos)
  local bytes = {("d"):pack(dbl):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a floating-point number of `size` bytes.  
---Leave nil for Lua size.
---
---Only 4-byte and 8-byte floating-point numbers are supported.
---@param num luanumber
---@param size? integer
---@param pos? integer
function BCBuffer:writeNumber(num, size, pos)
  local mod = size == 4 and "f" or size == 8 and "d" or size == nil and "n"
    or error(("invalid number size (4/8 expected, got %s)"):format(size), 2)
  local bytes = {mod:pack(num):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Writes a string.
---@param str string
---@param pos? integer
function BCBuffer:writeString(str, pos)
  local bytes = {str:byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #str end
end

---Writes a string prefixed with its length.
---
---If `nonull` is set, null strings cannot be written and a blank string will be written instead.
---@param str luastring
---@param nonull? boolean
---@param pos? integer
function BCBuffer:writeVarString(str, nonull, pos)
  self:pushPos(pos, "buf:writeVarString")
  if not str then
    self:writeVarInt(nonull and 1 or 0)
    self:popPos(pos, "buf:writeVarString")
    return
  end

  self:writeVarInt(#str + 1)
  self:writeString(str)
  self:popPos(pos, "buf:writeVarString")
end

---Writes a [format string](command:extension.lua.doc?["en-us/54/manual.html/6.4.2"]).
---@param fmt string
---@param args any[]
---@param pos? integer
function BCBuffer:writeFmt(fmt, args, pos)
  local bytes = {fmt:pack(table.unpack(args)):byte(1, -1)}
  self.modified = true
  table.move(bytes, 1, #bytes, pos or self.pos, self.bc)
  if not pos then self.pos = self.pos + #bytes end
end

---Ends the bytecode at the pointer position.
---@param pos? integer
function BCBuffer:eof(pos)
  self.modified = true
  for i = pos or self.pos, #self.bc do self.bc[i] = nil end
  if pos and self.pos > pos then self.pos = pos end
end

---If the buffer has been modified, applies the changes to the internal string for the methods that use it.
---
---This should be unneccesary to run manually as all methods that use the internal string will attempt to run this
---first.
function BCBuffer:flush()
  if self.modified then
    self.bcstr = string.char(table.unpack(self.bc))
    self.modified = false
  end
end

---Throws an error message `msg` formatted with varargs.
---
---Blames the position at `(CURRENT_POSITION - size)` and sets the buffer's position to
---`(CURRENT_POSITION - size - shift)` in case this error is caught.
---@param msg string
---@param level? integer
---@param size? integer
---@param shift? integer
---@param ... any
function BCBuffer:throw(msg, level, size, shift, ...)
  local pos = self.pos - (size or 0)
  self.pos = pos - (shift or 0)

  error(("buf[0x%04X]: " .. msg):format(pos - 1, ...), (level or 1) + 1)
end

---@cast BCBuffer +ConstructorF1<Plugin.BCE.BCBuffer, string | ubyte[]>


return BCBuffer
