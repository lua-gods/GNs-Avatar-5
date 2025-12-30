local bcedata = require("data.bcedata")
local util = require("util")

local OP_DATA = bcedata.OP_DATA
local TYPE = bcedata.TYPE
local OP = bcedata.OP
local BCBuffer = require("bce.buffer")

local MAGIC <const> = "\x1bLua"
local ERR_DATA <const> = "\x19\x93\r\n\x1a\n"
local INT_TEST <const> = 0x5678
local NUM_TEST <const> = 370.5

local s8_OFFSET <const> = 0xFE // 2
local s17_OFFSET <const> = 0x1FFFE // 2
local s25_OFFSET <const> = 0x1FFFFFE // 2

local VALID_INT_SIZES = util.set{2, 4, 8}

local VALID_NUM_SIZES = util.set{4, 8}


--====================================================================================================================--
--=====  HEADER  =====================================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.Header
---@field owner Plugin.BCE.BCObject
---@field magic string
---@field version [ub4, ub4]
---@field format ubyte
---@field err_data string
---@field inst_size ubyte
---@field int_size ubyte
---@field num_size ubyte
---@field int_test luainteger
---@field num_test luanumber
---@field nupvalues ubyte
local Header = {}
local HeaderMT = {__index = Header}

setmetatable(Header, {
  __metatable = HeaderMT,

  ---@param obj Plugin.BCE.BCObject
  __call = function(_, obj)
    local self = setmetatable({owner = obj}, HeaderMT)
    local buf = obj.buf

    self.magic = buf:readString(4)
    if self.magic ~= MAGIC then
      buf:throw("invalid magic number (%q expected, got %q)", 2, 4, 0, MAGIC, self.magic)
    end

    local version = buf:readByte()
    self.version = {version >> 4, version & 0xF}

    self.format = buf:readByte()

    self.err_data = buf:readString(6)
    if self.err_data ~= ERR_DATA then
      buf:throw("error check failed (%q expected, got %q)", 2, 6, 6, ERR_DATA, self.err_data)
    end

    self.inst_size = buf:readByte()
    if self.inst_size ~= 4 then
      buf:throw("instruction size is invalid (4 expected, got %d)", 2, 1, 12, self.inst_size)
    end

    self.int_size = buf:readByte()
    if not VALID_INT_SIZES[self.int_size] then
      local valid = table.concat(VALID_INT_SIZES, "/")
      buf:throw("integer size is invalid (%s expected, got %d)", 2, 1, 13, valid, self.int_size)
    end

    self.num_size = buf:readByte()
    if not VALID_NUM_SIZES[self.num_size] then
      local valid = table.concat(VALID_NUM_SIZES, "/")
      buf:throw("number size is invalid (%s expected, got %d)", 2, 1, 14, valid, self.num_size)
    end

    self.int_test = buf:readInt(self.int_size)
    if self.int_test ~= INT_TEST then
      buf:throw(
        "integer test failed (%d expected, got %d)",
        2, self.int_size, 15,
        INT_TEST, self.int_test
      )
    end

    self.num_test = buf:readNumber(self.num_size)
    if self.num_test ~= NUM_TEST then
      buf:throw(
        "number test failed (%s expected, got %s)",
        2, self.num_size, 15,
        NUM_TEST, self.num_test
      )
    end

    self.nupvalues = buf:readByte()

    return self
  end
})

---Compiles this header to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to the given buffer.
---@param buf? Plugin.BCE.BCBuffer
function Header:compile(buf)
  buf = buf or self.owner.buf

  buf:writeString(self.magic)
  buf:writeByte((self.version[1] << 4) | (self.version[2] & 0xF))
  buf:writeByte(self.format)
  buf:writeString(self.err_data)
  buf:writeByte(self.inst_size)
  buf:writeByte(self.int_size)
  buf:writeByte(self.num_size)
  buf:writeInt(self.int_test, self.int_size)
  buf:writeNumber(self.num_test, self.num_size)
  buf:writeByte(self.nupvalues)
end

---@cast Header +ConstructorF1<Plugin.BCE.Header, Plugin.BCE.BCObject>



--====================================================================================================================--
--=====  INSTRUCTION  ================================================================================================--
--====================================================================================================================--

---Contains tuples of bit shifts, bit masks, and offsets.
---@type {["op" | Plugin.BCE.Instruction.arg]: [integer, integer, integer]}
local instarg = {
  op  = {00, 0x000007F, 0},
  A   = {07, 0x00000FF, 0},
  B   = {16, 0x00000FF, 0},
  sB  = {16, 0x00000FF, s8_OFFSET},
  C   = {24, 0x00000FF, 0},
  sC  = {24, 0x00000FF, s8_OFFSET},
  k   = {15, 0x0000001, 0},
  Bx  = {15, 0x001FFFF, 0},
  sBx = {15, 0x001FFFF, s17_OFFSET},
  Ax  = {07, 0x1FFFFFF, 0},
  sJ  = {07, 0x1FFFFFF, s25_OFFSET}
}

---@alias Plugin.BCE.Instruction.arg "A" | "B" | "sB" | "C" | "sC" | "k" | "Bx" | "sBx" | "Ax" | "sJ"

---@class Plugin.BCE.Instruction.args
---Unsigned 8-bit argument A.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                                    ^^^^^^^^^^^^^^^
---> ```
---@field A ub8
---Unsigned 8-bit argument B.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                  ^^^^^^^^^^^^^^^
---> ```
---@field B ub8
---Signed 8-bit argument sB.  
---The real value of this argument is `(unsigned bits) - 127`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                  ^^^^^^^^^^^^^^^
---> ```
---@field sB sb8
---Unsigned 8-bit argument C.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^
---> ```
---@field C ub8
---Signed 8-bit argument sC.  
---The real value of this argument is `(unsigned bits) - 127`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^
---> ```
---@field sC sb8
---Flag k.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                                  ^
---> ```
---@field k boolean
---Unsigned 17-bit argument Bx.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field Bx ub17
---Signed 17-bit argument sBx.  
---The real value of this argument is `(unsigned bits) - 65535`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field sBx sb17
---Unsigned 25-bit argument Ax.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field Ax ub25
---Signed 25-bit argument sJ.  
---The real value of this argument is `(unsigned bits) - 16777215`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field sJ sb25

---@class Plugin.BCE.Instruction.argOptions
---Unsigned 8-bit argument A.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                                    ^^^^^^^^^^^^^^^
---> ```
---@field A? ub8
---Unsigned 8-bit argument B.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                  ^^^^^^^^^^^^^^^
---> ```
---@field B? ub8
---Signed 8-bit argument sB.  
---The real value of this argument is `(unsigned bits) - 127`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                  ^^^^^^^^^^^^^^^
---> ```
---@field sB? sb8
---Unsigned 8-bit argument C.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^
---> ```
---@field C? ub8
---Signed 8-bit argument sC.  
---The real value of this argument is `(unsigned bits) - 127`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^
---> ```
---@field sC? sb8
---Flag k.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                                  ^
---> ```
---@field k? boolean
---Unsigned 17-bit argument Bx.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field Bx? ub17
---Signed 17-bit argument sBx.  
---The real value of this argument is `(unsigned bits) - 65535`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field sBx? sb17
---Unsigned 25-bit argument Ax.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field Ax? ub25
---Signed 25-bit argument sJ.  
---The real value of this argument is `(unsigned bits) - 16777215`.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
---> ```
---@field sJ? sb25

---@class Plugin.BCE.Instruction: Plugin.BCE.Instruction.args
---@field owner Plugin.BCE.BCObject
---@field proto Plugin.BCE.Proto
---@field mode Plugin.BCE.mode
---The opcode of this instruction.
---> ```
---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
--->                                                    ^^^^^^^^^^^^^
---> ```
---@field op Plugin.BCE.op
---This is the Ax argument of the EXTRARG instruction following this instruction.  
---Contains 0 if none is found.
---@field EXTRAARG ub25
---@field package _value uint
local Instruction = {}
local InstructionMT = {
  ---@param self Plugin.BCE.Instruction
  ---@type Plugin.BCE.Instruction
  __index = function(self, key)
    if key == "EXTRAARG" then
      return self.proto:eachInstruction("op", OP.EXTRAARG, function(inst, i)
        if self.proto:I(i - 1) == self then return inst.Ax end
      end) or 0
    elseif key == "mode" then
      return OP_DATA[self._value & 0x7F].mode
    elseif instarg[key] then
      local d = instarg[key]
      local v = ((self._value >> d[1]) & d[2]) - d[3]
      return key ~= "k" and v or (v ~= 0)
    elseif Instruction[key] ~= nil then
      return Instruction[key]
    else
      return rawget(self, key)
    end
  end,
  ---@param self Plugin.BCE.Instruction
  __newindex = function(self, key, value)
    if key == "k" and type(value) == "boolean" then value = value and 1 or 0 end
    if type(value) ~= "number" then
      error(("bad value to '%s' (number expected, got '%s')"):format(key, type(value)), 2)
    end

    if key == "EXTRAARG" then
      local extraarg = self.proto:eachInstruction("op", OP.EXTRAARG, function(inst, i)
        if self.proto:I(i - 1) == self then return inst end
      end)
      if not extraarg then error("instruction is not followed by EXTRAARG instruction", 2) end

      local d = instarg.Ax
      extraarg._value = ~(~extraarg._value | (d[2] << d[1])) | (((value + d[3]) & d[2]) << d[1])
    elseif key == "mode" then
      error("cannot modify key 'mode' as it is controlled by key 'op'", 2)
    elseif instarg[key] then
      local d = instarg[key]

      -- Set the bits to be modified to 0, then inserts the new bits
      self._value = ~(~self._value | (d[2] << d[1])) | (((value + d[3]) & d[2]) << d[1])
    else
      error(("cannot set invalid key '%s'"):format(key), 2)
    end
  end
}

setmetatable(Instruction, {
  __metatable = InstructionMT,

  ---@param obj Plugin.BCE.BCObject
  __call = function(_, obj, proto)
    local buf = obj.buf
    return setmetatable({
      owner = obj,
      proto = proto,
      _value = buf:readUint(obj.header.inst_size)
    }, InstructionMT)
  end
})

---Compiles this instruction to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to a given buffer.
---@param buf Plugin.BCE.BCBuffer
function Instruction:compile(buf)
  buf = buf or self.owner.buf
  buf:writeUint(self._value, self.owner.header.inst_size)
end

---@cast Instruction +ConstructorF2<Plugin.BCE.Instruction, Plugin.BCE.BCObject, Plugin.BCE.Proto>



--====================================================================================================================--
--=====  CONSTANT  ===================================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.Constant
---@field owner Plugin.BCE.BCObject
---@field type Plugin.BCE.typetag
---@field value luaprimitive
local Constant = {}
local ConstantMT = {__index = Constant}

setmetatable(Constant, {
  __metatable = ConstantMT,

  ---@param obj Plugin.BCE.BCObject
  __call = function(_, obj)
    local self = setmetatable({owner = obj}, ConstantMT)
    local buf = obj.buf

    ---@type Plugin.BCE.typetag
    local cvari = buf:readByte()
    self.type = cvari

    if cvari == TYPE.VNIL then
      return self
    elseif cvari == TYPE.VTRUE or cvari == TYPE.VFALSE then
      self.value = cvari == TYPE.VTRUE
      return self
    elseif cvari == TYPE.VNUMINT then
      self.value = buf:readInt(obj.header.int_size)
      return self
    elseif cvari == TYPE.VNUMFLT then
      self.value = buf:readNumber(obj.header.num_size)
      return self
    elseif cvari == TYPE.VSHRSTR or cvari == TYPE.VLNGSTR then
      self.value = buf:readVarString(true)
      return self
    end

    buf:throw("unknown constant type %d", 2, 1, 0, cvari)
  end
})

---Gets the value stored in this constant.
---@return luaprimitive
function Constant:get() return self.value end

---Sets the value stored in this constant.
---
---This is preferred to doing it manually as this function also sets the constant type and stops invalid values.
---@param value luaprimitive
function Constant:set(value)
  local vtype = type(value)
  if vtype == "nil" then
    self.type = TYPE.VNIL
    self.value = nil
  elseif vtype == "boolean" then
    self.type = value and TYPE.VTRUE or TYPE.VFALSE
    self.value = value
  elseif vtype == "number" then
    self.type = math.type(value) == "integer" and TYPE.VNUMINT or TYPE.VNUMFLT
    self.value = value
  elseif vtype == "string" then
    self.type = #value <= 40 and TYPE.VSHRSTR or TYPE.VLNGSTR
    self.value = value
  else
    error("only nil, boolean, number, and string values may be used as constants", 2)
  end
end

---Compiles this instruction to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to a given buffer.
---@param buf? Plugin.BCE.BCBuffer
function Constant:compile(buf)
  buf = buf or self.owner.buf

  local cvari = self.type
  buf:writeByte(cvari)

  if cvari == TYPE.VNIL or cvari == TYPE.VTRUE or cvari == TYPE.VFALSE then
    return
  elseif cvari == TYPE.VNUMINT then
    buf:writeInt(self.value --[[@as luainteger]], self.owner.header.int_size)
    return
  elseif cvari == TYPE.VNUMFLT then
    buf:writeNumber(self.value --[[@as luanumber]], self.owner.header.num_size)
    return
  elseif cvari == TYPE.VSHRSTR or cvari == TYPE.VLNGSTR then
    buf:writeVarString(self.value --[[@as string]], true)
    return
  else
    buf:throw("unknown constant type %d", 2, 1, 0, cvari)
  end
end

---@cast Constant +ConstructorF1<Plugin.BCE.Constant, Plugin.BCE.BCObject>



--====================================================================================================================--
--=====  UPVALUE  ====================================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.Upvalue
---@field owner Plugin.BCE.BCObject
---@field proto Plugin.BCE.Proto
---@field name? luastring
---@field in_stack boolean
---@field index ubyte
---@field kind ubyte
---If this exists, this upvalue will be replaced by the numbered upvalue from the function when the containing prototype
---is built.  
---This only does something on the "main" prototype.
---@field inject? ["VUPVAL", function, integer] | ["VLOCAL", any]
local Upvalue = {}
local UpvalueMT = {__index = Upvalue}

setmetatable(Upvalue, {
  __metatable = UpvalueMT,

  ---@param obj Plugin.BCE.BCObject
  __call = function(_, obj)
    local buf = obj.buf
    return setmetatable({
      owner = obj,
      in_stack = buf:readByte() ~= 0,
      index = buf:readByte(),
      kind = buf:readByte()
    }, UpvalueMT)
  end
})

---Compiles this upvalue to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to a given buffer.
---@param buf? Plugin.BCE.BCBuffer
function Upvalue:compile(buf)
  buf = buf or self.owner.buf

  buf:writeByte(self.in_stack and 1 or 0)
  buf:writeByte(self.index)
  buf:writeByte(self.kind)
end

---@cast Upvalue +ConstructorF1<Plugin.BCE.Upvalue, Plugin.BCE.BCObject>



--====================================================================================================================--
--=====  DEBUG INFO  =================================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.DebugInfo
---@field owner Plugin.BCE.BCObject
---@field proto Plugin.BCE.Proto
---Determines the line number of each instruction relative to the previous instruction.  
---The first instruction is relative to the start of the file.
---@field lineinfo sbyte[]
---Contains the absolute position of some instructions to speed up location checks.
---@field abslineinfo {pc: varint, line: varint}[]
---Contains the names and scopes of local variables in the prototype.
---@field locvar {varname: luastring, startpc: varint, endpc: varint}[]
local DebugInfo = {}
local DebugInfoMT = {__index = DebugInfo}

setmetatable(DebugInfo, {
  __metatable = DebugInfoMT,

  ---@param obj Plugin.BCE.BCObject
  ---@param proto Plugin.BCE.Proto
  __call = function(_, obj, proto)
    local self = setmetatable({
      owner = obj,
      proto = proto
    }, DebugInfoMT)
    local buf = obj.buf

    self.lineinfo = {buf:readSbytes(buf:readVarInt())}

    local n = buf:readVarInt()
    local t = {}
    self.abslineinfo = t
    for i = 1, n do t[i] = {pc = buf:readVarInt(), line = buf:readVarInt()} end

    n = buf:readVarInt()
    t = {}
    self.locvar = t
    for i = 1, n do
      t[i] = {
        varname = buf:readVarString(),
        startpc = buf:readVarInt(), endpc = buf:readVarInt()
      }
    end

    if buf:readVarInt() > 0 then
      for _, upv in ipairs(proto.upv) do
        upv.name = buf:readVarString()
      end
    end

    return self
  end
})


---Compiles this debug info to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to a given buffer.
---@param buf? Plugin.BCE.BCBuffer
function DebugInfo:compile(buf)
  buf = buf or self.owner.buf

  buf:writeVarInt(#self.lineinfo)
  buf:writeBytes(self.lineinfo)

  buf:writeVarInt(#self.abslineinfo)
  for _, ali in ipairs(self.abslineinfo) do
    buf:writeVarInt(ali.pc)
    buf:writeVarInt(ali.line)
  end

  buf:writeVarInt(#self.locvar)
  for _, ali in ipairs(self.locvar) do
    buf:writeVarString(ali.varname)
    buf:writeVarInt(ali.startpc)
    buf:writeVarInt(ali.endpc)
  end

  local upvalues = self.proto.upv
  if upvalues[1] and upvalues[1].name ~= nil then
    buf:writeVarInt(#upvalues)
    for _, upv in ipairs(upvalues) do buf:writeVarString(upv.name) end
  else
    buf:writeVarInt(0)
  end
end

---@cast DebugInfo +ConstructorF2<Plugin.BCE.DebugInfo, Plugin.BCE.BCObject, Plugin.BCE.Proto>



--====================================================================================================================--
--=====  FUNCTION PROTOTYPE  =========================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.Proto
---@field owner Plugin.BCE.BCObject
---@field parent? Plugin.BCE.Proto
---@field source luastring
---@field linedefined varint
---@field lastlinedefined varint
---@field nparams ubyte
---@field is_vararg boolean
---@field maxstacksize ubyte
---@field inst Plugin.BCE.Instruction[]
---@field const Plugin.BCE.Constant[]
---@field upv Plugin.BCE.Upvalue[]
---@field proto Plugin.BCE.Proto[]
---@field debuginfo Plugin.BCE.DebugInfo
local Proto = {}
local ProtoMT = {__index = Proto}

setmetatable(Proto, {
  __metatable = ProtoMT,

  ---@param obj Plugin.BCE.BCObject
  ---@param parent? Plugin.BCE.Proto
  __call = function(_, obj, parent)
    ---@cast Proto +ConstructorF2<Plugin.BCE.Proto, Plugin.BCE.BCObject, Plugin.BCE.Proto?>

    local self = setmetatable({
      owner = obj,
      parent = parent
    }, ProtoMT)
    local buf = obj.buf

    self.source = buf:readVarString()
    self.linedefined = buf:readVarInt()
    self.lastlinedefined = buf:readVarInt()
    self.nparams = buf:readByte()
    self.is_vararg = buf:readByte() ~= 0
    self.maxstacksize = buf:readByte()

    local n = buf:readVarInt()
    local t = {}
    self.inst = t
    for i = 1, n do t[i] = Instruction(obj, self) end

    n = buf:readVarInt()
    t = {}
    self.const = t
    for i = 1, n do t[i] = Constant(obj) end

    n = buf:readVarInt()
    t = {}
    self.upv = t
    for i = 1, n do t[i] = Upvalue(obj) end

    n = buf:readVarInt()
    t = {}
    self.proto = t
    for i = 1, n do t[i] = Proto(obj, self) end

    self.debuginfo = DebugInfo(obj, self)

    return self
  end
})

---Gets the `n`th instruction.  
---This is 0-indexed.
---@param n integer
---@return Plugin.BCE.Instruction?
function Proto:I(n) return self.inst[n + 1] end

if false then
  ---Gets the value of the `n`th constant.  
  ---This is 0-indexed.
  ---@param n integer
  ---@return luaprimitive
  function Proto:K(n) end

  ---Sets the `n`th constant to the given value.  
  ---This is 0-indexed.
  ---@param n integer
  ---@param v luaprimitive
  function Proto:K(n, v) end
end

---@implementation
---@param self Plugin.BCE.Proto
---@param n integer
---@param ... luaprimitive
---@return luaprimitive?
Proto[("K")] = function(self, n, ...)
  if select("#", ...) > 0 then
    while #self.const <= n do
      self.const[#self.const+1] = setmetatable(
        {owner = self.owner, type = TYPE.VNIL, value = nil},
        ConstantMT
      )
    end
    self.const[n + 1]:set((...))
  elseif self.const[n + 1] then
    return self.const[n + 1]:get()
  else
    return nil
  end
end

---Gets the `n`th upvalue.  
---This is 0-indexed.
---@param n integer
---@return Plugin.BCE.Upvalue?
function Proto:U(n)
  return self.upv[n + 1]
end

---Gets the `n`th prototype.  
---This is 0-indexed.
---@param n integer
---@return Plugin.BCE.Proto?
function Proto:P(n)
  return self.proto[n + 1]
end

---Finds every instruction with the given key and value.
---
---Return a non-nil value in the callback to stop early and return that value.
---@generic R
---@param key "op" | "A" | "B" | "sB" | "C" | "sC" | "k" | "Bx" | "sBx" | "Ax" | "sJ" | "_value"
---@param value integer
---@param cb fun(inst: Plugin.BCE.Instruction, pc: integer): R?
---@return R?
function Proto:eachInstruction(key, value, cb)
  if key == "k" then value = value ~= 0 end

  local ret
  for i, inst in ipairs(self.inst) do
    if inst[key] == value then
      ret = cb(inst, i - 1)
      if ret ~= nil then return ret end
    end
  end
end

---Adds `n` parameter slots to the prototype. Shifting all registers to accomodate them.
---
---If `n` is `nil`, it will default to `1`.
---@param n? integer
function Proto:addParameter(n)
  n = n or 1

  self:shiftRegisters(n, self.nparams, 0)
  self.nparams = self.nparams + n
end

---Shifts all references to all registers `from` and above `n` time(s) starting at instruction `start`.
---
---`n` defaults to 1 if not specified.  
---`from` and `start` default to `0` if not specified.
---@param n? integer
---@param from? integer
---@param start? integer
function Proto:shiftRegisters(n, from, start)
  n = n or 1
  from = from or 0
  start = start or 0
  local I = self.inst
  for i = start + 1, #I do
    local inst = I[i]
    for arg, rule in pairs(OP_DATA[inst.op]) do
      if ((rule == "register") or (rule == "regconst" and not inst.k)) and inst[arg] >= from then
        inst[arg] = inst[arg] + n
        if inst[arg] >= self.maxstacksize then self.maxstacksize = inst[arg] + 1 end
      end
    end
  end
end

---Inserts an instruction into this prototype at the given position.
---
---`injump` determines if this instruction should be placed inside a jump if it is at the edge of one.
---@param op Plugin.BCE.op
---@param i? integer
---@param arg? Plugin.BCE.Instruction.argOptions
---@param injump? boolean
function Proto:insertInstruction(op, i, arg, injump)
  local I = self.inst
  if not i then i = #I end
  i = i + 1
  local res = setmetatable({
    owner = self.owner,
    proto = self,
    _value = op
  }, InstructionMT)
  if arg then for k, v in pairs(arg) do res[k] = v end end
  table.insert(I, i, res)

  local i_shift = i - 1
  -- Adjust jump instructions that move forward into the inserted instruction.
  for j = 1, i - 1 do
    local inst = I[j]
    for jarg, rule in pairs(OP_DATA[inst.op]) do
      if rule == "jump" and inst[jarg] > 0 then
        local jmp_target = j + inst[jarg]
        if jmp_target > i_shift or (injump and jmp_target == i_shift) then
          inst[jarg] = inst[jarg] + 1
        end
      elseif rule == "jumpback" and inst[jarg] < 0 then
        local jmp_target = j - inst[jarg]
        if jmp_target > i_shift or (injump and jmp_target == i_shift) then
          inst[jarg] = inst[jarg] - 1
        end
      end
    end
  end

  i_shift = i + 1
  -- Adjust jump instructions that move backward into the inserted instruction.
  for j = i + 1, #I do
    local inst = I[j]
    for jarg, rule in pairs(OP_DATA[inst.op]) do
      if rule == "jumpback" and inst[jarg] > 0 then
        local jmp_target = j - inst[jarg]
        if jmp_target < i_shift or (injump and jmp_target == i_shift) then
          inst[jarg] = inst[jarg] + 1
        end
      elseif rule == "jump" and inst[jarg] < 0 then
        local jmp_target = j + inst[jarg]
        if jmp_target < i_shift or (injump and jmp_target == i_shift) then
          inst[jarg] = inst[jarg] - 1
        end
      end
    end
  end

  -- Update debug information.
  if #self.debuginfo.lineinfo > 0 then table.insert(self.debuginfo.lineinfo, i, 0) end
  if #self.debuginfo.abslineinfo > 0 then
    for _, ali in ipairs(self.debuginfo.abslineinfo) do
      if ali.pc >= i then ali.pc = ali.pc + 1 end
    end
  end
  if #self.debuginfo.locvar > 0 then
    for _, loc in ipairs(self.debuginfo.locvar) do
      if loc.startpc >= i then
        loc.startpc = loc.startpc + 1
        loc.endpc = loc.endpc + 1
      elseif loc.endpc >= i then
        loc.endpc = loc.endpc + 1
      end
    end
  end

end

---Adds `n` upvalues to the prototype.
---
---If `n` is `nil`, it will default to `1`.
---@param n? integer
function Proto:addUpvalue(n)
  n = n or 1

  if not self.parent then self.owner.header.nupvalues = self.owner.header.nupvalues + n end

  local U = self.upv
  local len = #U
  for i = len + 1, len + n do
    U[i] = setmetatable({
      owner = self.owner,
      name = "?",
      in_stack = false,
      index = 0,
      kind = 0
    }, UpvalueMT)
  end
end

---Modifies upvalue `to` of this prototype. The purpose of `from` changes depending on how this method is used.  
---Both `to` and `from` are 0-based.
---
---While this function is limited to existing upvalues, setting `to` to one value above the top upvalue will cause this
---method to create a new upvalue automatically.
---
---If `name` is set, the name of the upvalue will be updated to the given name.  
---If it is not set and a valid name could be found, that name will be used instead.  
---If a valid name could not be found, the name of the upvalue will not change.
---
---* **Used on "main" prototype, `instack == false`**  
---  `from` is the index or name of the upvalue to take from the current closure.  
---  This is a direct merge, any modifications to upvalue `from` will update upvalue `to` and vise versa.
---
---+ **Used on "main" prototype, `instack == true`**  
---  `from` is the index or name of the local variable in the current context to take the value from.  
---  This is not a merge, if the local variable is changed, the upvalue will not update with it and vise versa.
---
---* **Used on other prototype, `instack == false`**  
---  `from` is the index or name of the upvalue to take from the parent prototype.  
---  Names only work if debug information was collected with the bytecode.
---
---+ **Used on other prototype, `instack == true`**  
---  `from` is the register index to take from the parent prototype.  
---  Names do not work here, it is recommended to use `name` to set one.
---@param to integer
---@param instack boolean
---@param from integer | string
---@param name? string
function Proto:setUpvalue(to, instack, from, name)
  if to < 0 or to > #self.upv then
    error(("upvalue %d is out of bounds for this prototype"):format(to), 2)
  end
  local newupvalue = to == #self.upv
  to = to + 1

  local value

  if not self.parent then -- "main" prototype
    if instack then -- context local
      local loc_name
      if type(from) == "string" then
        for i = 1, 255 do
          loc_name, value = debug.getlocal(2, i)
          if loc_name == from or loc_name == nil then
            from = i - 1
            break
          end
        end

        if loc_name == nil then
          error(
            ("local variable named '%s' is not in scope, does not exist, or was optimized away"):format(from),
            2
          )
        end
      else
        loc_name, value = debug.getlocal(2, from + 1)
        if loc_name == nil then
          error(
            ("local variable %d is not in scope, does not exist, or was optimized away"):format(from),
            2
          )
        end
      end

      if newupvalue then Proto:addUpvalue() end
      self.upv[to].inject = {"VLOCAL", value}
      if (name or loc_name) and #self.upv > 0 and self.upv[1].name ~= nil then
        self.upv[to].name = name or loc_name
      end
      return
    else -- context upvalue
      local func = debug.getinfo(2, "f").func
      local up_name
      if type(from) == "string" then
        for i = 1, 255 do
          up_name, value = debug.getupvalue(func, i)
          if up_name == from or up_name == nil then
            from = i - 1
            break
          end
        end

        if up_name == nil then
          error(("upvalue named '%s' does not exist or was optimized away"):format(from), 2)
        end
      else
        up_name, value = debug.getupvalue(func, from + 1)
        if up_name == nil then
          error(("upvalue %d does not exist or was optimized away"):format(from), 2)
        end
      end

      if newupvalue then Proto:addUpvalue() end
      self.upv[to].inject = {"VUPVAL", func, from + 1}
      if (name or up_name) and #self.upv > 0 and self.upv[1].name ~= nil then
        self.upv[to].name = name or up_name
      end
      return
    end
  else -- other prototype
    local parent = self.parent
    ---@cast parent -?

    if instack then -- parent register
      if type(from) == "string" then
        error(("cannot use name '%s' here, registers do not have names"):format(from), 2)
      end

      local proto_id
      for id, proto in ipairs(parent.proto) do
        if proto == self then
          proto_id = id
          break
        end
      end

      -- Should only happen if the structure was tampered with.
      if not proto_id then error("this prototype does not exist in its parent's prototype list", 2) end

      local max_reg
      for _, inst in ipairs(parent.inst) do
        if inst.op == OP.CLOSURE and inst.Bx == proto_id then
          max_reg = inst.A
          break
        end
      end

      -- Should only happen if the instructions were tampered with.
      if not max_reg then error("this prototype is never created in its parent's instructions", 2) end

      if from < 0 or from > max_reg then
        error(("register %d is out of bounds in the parent prototype"):format(from), 2)
      end

      if newupvalue then Proto:addUpvalue() end
      local upv = self.upv[to]
      upv.in_stack = true
      upv.index = from
      upv.kind = 0
      if name and #self.upv > 0 and self.upv[1].name ~= nil then self.upv[to].name = name end
      return
    else -- parent upvalue
      if type(from) == "string" then
        if #self.upv == 0 or self.upv[1].name == nil then
          error(
            ("cannot use name '%s' here, parent prototype does not provide debug information"):format(from),
            2
          )
        end

        for i, upv in ipairs(parent.upv) do
          if upv.name == from then
            from = i
            break
          end
        end

        if type(from) == "string" then
          error(("upvalue named '%s' does not exist or was optimized away"):format(from), 2)
        end
      elseif not parent.upv[from] then
        error(("upvalue %d is out of bounds in the parent prototype"):format(from), 2)
      end

      if newupvalue then Proto:addUpvalue() end
      local upv = self.upv[to]
      upv.in_stack = false
      upv.index = from
      upv.kind = 0
      if #self.upv > 0 and self.upv[1].name ~= nil then
        local parent_upvname = parent.upv[from].name
        local valid_name = name or (parent_upvname ~= "?" and parent_upvname ~= "" and parent_upvname)
        if valid_name then self.upv[to].name = valid_name end
      end
      return
    end
  end
end

---Compiles this debug info to the buffer.
---
---While this is meant for internal use, this can be used to compile just this object to a given buffer.
---@param buf? Plugin.BCE.BCBuffer
function Proto:compile(buf)
  local obuf = buf
  buf = buf or self.owner.buf

  buf:writeVarString(self.source)
  buf:writeVarInt(self.linedefined)
  buf:writeVarInt(self.lastlinedefined)
  buf:writeByte(self.nparams)
  buf:writeByte(self.is_vararg and 1 or 0)
  buf:writeByte(self.maxstacksize)

  buf:writeVarInt(#self.inst)
  for _, inst in ipairs(self.inst) do inst:compile(obuf) end

  buf:writeVarInt(#self.const)
  for _, const in ipairs(self.const) do const:compile(obuf) end

  buf:writeVarInt(#self.upv)
  for _, upv in ipairs(self.upv) do upv:compile(obuf) end

  buf:writeVarInt(#self.proto)
  for _, proto in ipairs(self.proto) do proto:compile(obuf) end

  self.debuginfo:compile(obuf)
end

---@cast Proto +ConstructorF2<Plugin.BCE.Proto, Plugin.BCE.BCObject, Plugin.BCE.Proto?>



--====================================================================================================================--
--=====  OBJECT  =====================================================================================================--
--====================================================================================================================--

---@class Plugin.BCE.BCObject
---@field buf Plugin.BCE.BCBuffer
---@field header Plugin.BCE.Header
---@field main Plugin.BCE.Proto
local BCObject = {}
local BCObjectMT = {__index = BCObject}

setmetatable(BCObject, {
  __metatable = ProtoMT,

  ---@param content function | string | ubyte[] | Plugin.BCE.BCBuffer
  __call = function(_, content)
    local self = setmetatable({}, BCObjectMT)
    ---@type function?
    local func

    local typec = type(content)
    if typec == "function" then
      self.buf = BCBuffer(string.dump(content))
      func = content
    elseif typec == "string" then
      self.buf = BCBuffer(content)
    elseif typec == "table" then
      if math.tointeger(content[1]) then
        self.buf = BCBuffer(content)
      elseif content.readSbytes then
        self.buf = content
      else
        error("cannot convert given value to bytecode buffer", 2)
      end
    else
      error("cannot convert given value to bytecode buffer", 2)
    end

    self.header = Header(self)
    self.main = Proto(self)

    if func then
      for i, upv in ipairs(self.main.upv) do upv.inject = {"VUPVAL", func, i} end
    end

    return self
  end
})

---Attempts to build the function stored in this object.
---@param env? table
---@return function?
---@return string? error_message
function BCObject:build(env)
  self.buf.pos = 1

  self.header:compile()
  self.main:compile()

  self.buf:eof()

  local f, e = load(tostring(self.buf), "Rebuilt Function", "b", env)
  if not f then return nil, e end

  local inject
  for i, upv in ipairs(self.main.upv) do
    if upv.inject then
      inject = upv.inject
      if inject[1] == "VLOCAL" then
        debug.setupvalue(f, i, inject[2])
      elseif inject[1] == "VUPVAL" then
        debug.upvaluejoin(f, i, inject[2], inject[3])
      end
    end
  end

  return f
end

---@cast BCObject +ConstructorF1<Plugin.BCE.BCObject, function | string | ubyte[] | Plugin.BCE.BCBuffer>


return {
  Header = Header,
  Instruction = Instruction,
  Constant = Constant,
  Upvalue = Upvalue,
  DebugInfo = DebugInfo,
  Proto = Proto,
  BCObject = BCObject
}
