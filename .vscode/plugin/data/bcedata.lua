local mm = {
  [0] = "__index", "__newindex",
  "__gc", "__mode",
  "__len",
  "__eq",
  "__add", "__sub", "__mul", "__mod", "__pow", "__div", "__idiv",
  "__band", "__bor", "__bxor",
  "__shl", "__shr",
  "__unm", "__bnot",
  "__lt", "__le",
  "__concat",
  "__call",
  "__close"
}


---@enum Plugin.BCE.mode
local MODE = {
  ---The default mode for opcodes.  
  ---Instruction uses the `A`, `B`, and `C` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~ C ~~~~~^ ^~~~~~ B ~~~~~^   ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iABC = 0x00,
  ---Variant 1 of `iABC`. Changes `B` to signed `sB`.  
  ---Instruction uses the `A`, `sB`, and `C` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~ C ~~~~~^ ^~~~~ sB ~~~~~^   ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAsBC = 0x10,
  ---Variant 2 of `iABC`. Changes `C` to signed `sC`.  
  ---Instruction uses the `A`, `B`, and `sC` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~ sC ~~~~~^ ^~~~~~ B ~~~~~^   ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iABsC = 0x20,
  ---Variant 3 of `iABC`. Adds flag `k`.  
  ---Instruction uses the `A`, `B`, `C`, and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~ C ~~~~~^ ^~~~~~ B ~~~~~^ k ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iABCk = 0x30,
  ---Variant 4 of `iABC`. Changes `B` to signed `sB` and adds flag `k`.  
  ---Instruction uses the `A`, `B`, `C`, and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~ C ~~~~~^ ^~~~~ sB ~~~~~^ k ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAsBCk = 0x40,
  ---Variant 5 of `iABC`. Removes argument `C`.  
  ---Instruction uses the `A` and `B` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                  ^~~~~~ B ~~~~~^   ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAB = 0x50,
  ---Variant 6 of `iABC`. Removes argument `B`.  
  ---Instruction uses the `A` and `C` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~ B ~~~~~^                   ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAC = 0x60,
  ---Variant 7 of `iABC`. Removes argument `C` and adds flag `k`.  
  ---Instruction uses the `A`, `B`, and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                  ^~~~~~ B ~~~~~^ k ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iABk = 0x70,
  ---Variant 8 of `iABC`. Changes argument `B` to signed `sB`, removes argument `C`, and adds flag `k`.  
  ---Instruction uses the `A`, `sB`, and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                  ^~~~~ sB ~~~~~^ k ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAsBk = 0x80,
  ---Variant 9 of `iABC`. Removes arguments `B` and `C`.  
  ---Instruction uses the `A` and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                                    ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iA = 0x90,
  ---Variant 10 of `iABC`. Removes arguments `B` and `C` and adds flag `k`.  
  ---Instruction uses the `A`, `B`, and `k` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                                  k ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAk = 0xA0,
  ---Variant 11 of `iABC`. Removes all arguments.  
  ---Instruction uses no arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->                                                    ^~~~ OP ~~~~^
  ---> ```
  i_ = 0xB0,

  ---An alternative mode for opcodes that need a larger argument.  
  ---Instruction uses the `A` and `Bx` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~~~~~~~~~~ Bx ~~~~~~~~~~~~~^ ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iABx = 0x01,
  ---Variant 1 of `iABx`. Changes `Bx` to signed `sBx`.  
  ---Instruction uses the `A` and `sBx` arguments.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~~~~~~~~~ sBx ~~~~~~~~~~~~~^ ^~~~~~ A ~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAsBx = 0x11,

  ---An alternative mode for opcodes that need an even larger argument.  
  ---Instruction uses the `Ax` argument.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~~~~~~~~~~~~~~~~~~ Ax ~~~~~~~~~~~~~~~~~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  iAx = 0x02,

  ---An alternative mode for opcodes that jump.  
  ---Instruction uses the `sJ` argument.
  ---> ```
  ---> |     Byte3     |     Byte2     |     Byte1     |     Byte0     |
  ---> |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
  --->  ^~~~~~~~~~~~~~~~~~~~~~ sJ ~~~~~~~~~~~~~~~~~~~~~~^ ^~~~ OP ~~~~^
  ---> ```
  isJ = 0x03
}

---@enum Plugin.BCE.op
local OP = {
  MOVE = 0,
  LOADI = 1, LOADF = 2, LOADK = 3, LOADKX = 4, LOADFALSE = 5, LFALSESKIP = 6, LOADTRUE = 7, LOADNIL = 8,
  GETUPVAL = 9, SETUPVAL = 10,
  GETTABUP = 11, GETTABLE = 12, GETI = 13, GETFIELD = 14,
  SETTABUP = 15, SETTABLE = 16, SETI = 17, SETFIELD = 18,

  NEWTABLE = 19,
  SELF = 20,
  ADDI = 21,

  ADDK = 22, SUBK = 23, MULK = 24, MODK = 25, POWK = 26, DIVK = 27, IDIVK = 28,
  BANDK = 29, BORK = 30, BXORK = 31,

  SHRI = 32, SHLI = 33,

  ADD = 34, SUB = 35, MUL = 36, MOD = 37, POW = 38, DIV = 39, IDIV = 40,
  BAND = 41, BOR = 42, BXOR = 43, SHL = 44, SHR = 45,

  MMBIN = 46, MMBINI = 47, MMBINK = 48,

  UNM = 49, BNOT = 50, NOT = 51, LEN = 52,
  CONCAT = 53,

  CLOSE = 54, TBC = 55,
  JMP = 56,
  EQ = 57, LT = 58, LE = 59,

  EQK = 60, EQI = 61, LTI = 62, LEI = 63, GTI = 64, GEI = 65,

  TEST = 66, TESTSET = 67,

  CALL = 68, TAILCALL = 69,

  RETURN = 70, RETURN0 = 71, RETURN1 = 72,

  FORLOOP = 73, FORPREP = 74,
  TFORPREP = 75, TFORCALL = 76, TFORLOOP = 77,

  SETLIST = 78,

  CLOSURE = 79,

  VARARG = 80,
  VARARGPREP = 81,

  EXTRAARG = 82
}

---@enum Plugin.BCE.typetag
local TYPE = {
  TNONE = -1,
  TNIL = 0x00, VNIL = 0x00, VEMPTY = 0x10, VABSTKEY = 0x20,
  TBOOLEAN = 0x01, VFALSE = 0x01, VTRUE = 0x11,
  TLIGHTUSERDATA = 0x02, VLIGHTUSERDATA = 0x02,
  TNUMBER = 0x03, VNUMINT = 0x03, VNUMFLT = 0x13,
  TSTRING = 0x04, VSHRSTR = 0x04, VLNGSTR = 0x14,
  TTABLE = 0x05, VTABLE = 0x05,
  TFUNCTION = 0x06, VLCL = 0x06, VLCF = 0x16, VCCL = 0x26,
  TUSERDATA = 0x07, VUSERDATA = 0x07,
  TTHREAD = 0x08, VTHREAD = 0x08,
  TUPVAL = 0x09, VUPVAL = 0x09,
  TPROTO = 0x0A, VPROTO = 0x0A,
  TDEADKEY = 0x0B
}

---@alias Plugin.BCE.optarget
---| "register" # Argument targets a register slot.
---| "constant" # Argument targets a constant.
---| "regconst" # Argument targets a register or constant depending on `k`.
---| "upvalue"  # Argument targets an upvalue.
---| "proto"    # Argument targets a prototype.
---| "value"    # Argument represents a value.
---| "jump"     # Argument represents a jump.
---| "jumpback" # Argument represents a backwards jump.
---| "range"    # Argument is considered a range.
---| "vararg"   # Similar to "range" except 0 is "as many as possible" and other values are reduced by 1.
---| "other"    # Argument has other or unknown purpose.
---| nil        # Argument is unused.

---@class Plugin.BCE.OpData
---@field name string
---@field mode Plugin.BCE.mode
---The description is both a description of what an opcode does and a description of what a complete instruction does.
---This is done by either using the format syntax shown below or using a function that *optionally* takes an
---instruction, returning the final string.
---
---All formatted objects are surrounded in {}.  
---Uppercase variables (Ⓐ) resolve argument names, some lowercase variables (ⓐ) may resolve numbers.  
---After every pass, the description re-evaluated. If an uppercase variable resolved an argument name into a number, a
---lowercase variable may now resolve that number.
---* First pass:  
---  Uppercase variables (Ⓐ) resolve argument names, lowercase variables (ⓐ) do not.
---  * `{Ⓐ±ⓑ:`ⓒ`}`: The numerical value of argument Ⓐ + ⓑ. Optionally formatted with string ⓒ.  
---    ⓑ is optional and defaults to `0`.
---  * ``{`ⓐ`=`ⓑ`}``: The string ⓐ if this is an opcode description, the result of expression ⓑ if this is an
---    instruction description.  
---    The expression itself can contain argument names that will be resolved.  
---    ⓐ is optional and defaults to the string ⓑ.
---* Second pass:  
---  Uppercase variables (Ⓐ) resolve numerical values, lowercase variables (ⓐ) resolve strings.
---  * `R[Ⓐ]`: Register Ⓐ.
---  * `K[Ⓐ]`: Constant Ⓐ.
---  * `RK(Ⓐ)`: Register Ⓐ if `k` is not set, Constant Ⓐ if `k` is set.
---  * `Upvalue[Ⓐ]`: Upvalue Ⓐ.
---  * `Proto[Ⓐ]`: Prototype Ⓐ.
---  * ``R[Ⓐ,Ⓑ:`ⓒ`]``: Register range from Ⓐ to Ⓐ+Ⓑ. Optionally uses string ⓒ as the separator.
---Third pass:  
---  Uppercase variables (Ⓐ) resolve strings, lowercase variables (ⓐ) do nothing special.
---  * ``{-`Ⓐ`}``: Only show the text Ⓐ if this is an opcode description.
---  * ``{+`Ⓐ`}``: Only show the text Ⓐ if this is an instruction description.
---@field desc string | fun(inst?: Plugin.BCE.Instruction): string
---Extra information that isn't necessary for instruction descriptions but important for opcode descriptions.
---@field info? string
---@field A Plugin.BCE.optarget
---@field B Plugin.BCE.optarget
---@field sB Plugin.BCE.optarget
---@field C Plugin.BCE.optarget
---@field k Plugin.BCE.optarget
---@field sC Plugin.BCE.optarget
---@field Bx Plugin.BCE.optarget
---@field sBx Plugin.BCE.optarget
---@field Ax Plugin.BCE.optarget
---@field sJ Plugin.BCE.optarget
---If EXTRAARG is used, this explains what it is used for.
---@field EXTRAARG Plugin.BCE.optarget


---@type {[Plugin.BCE.op]: Plugin.BCE.OpData}
local OP_DATA = {
  [OP.MOVE] = {
    name = "MOVE", mode = MODE.iAB,
    desc = "R[{A}] := R[{B}]",
    A = "register", B = "register"
  },
  [OP.LOADI] = {
    name = "LOADI", mode = MODE.iAsBx,
    desc = "R[{A}] := {sBx}",
    A = "register", sBx = "value"
  },
  [OP.LOADF] = {
    name = "LOADF", mode = MODE.iAsBx,
    desc = "R[{A}] := {sBx}{+`.0`}{-` as LuaNumber`}",
    A = "register", sBx = "value"
  },
  [OP.LOADK] = {
    name = "LOADK", mode = MODE.iABx,
    desc = "R[{A}] := K[{Bx}]",
    A = "register", Bx = "constant"
  },
  [OP.LOADKX] = {
    name = "LOADKX", mode = MODE.iA,
    desc = "R[{A}] := K[{EXTRAARG}]",
    A = "register", EXTRAARG = "constant"
  },
  [OP.LOADFALSE] = {
    name = "LOADFALSE", mode = MODE.iA,
    desc = "R[{A}] := false",
    A = "register"
  },
  [OP.LFALSESKIP] = {
    name = "LFALSESKIP", mode = MODE.iA,
    desc = "R[{A}] := false; pc++",
    A = "register"
  },
  [OP.LOADTRUE] = {
    name = "LOADTRUE", mode = MODE.iA,
    desc = "R[{A}] := true",
    A = "register"
  },
  [OP.LOADNIL] = {
    name = "LOADNIL", mode = MODE.iAB,
    desc = "R[{A},{B}] := nil",
    A = "register", B = "range"
  },
  [OP.GETUPVAL] = {
    name = "GETUPVAL", mode = MODE.iAB,
    desc = "R[{A}] := Upvalue[{B}]",
    A = "register", B = "upvalue"
  },
  [OP.SETUPVAL] = {
    name = "SETUPVAL", mode = MODE.iAB,
    desc = "Upvalue[{B}] := R[{A}]",
    A = "register", B = "upvalue"
  },

  [OP.GETTABUP] = {
    name = "GETTABUP", mode = MODE.iABC,
    desc = "R[{A}] := Upvalue[{B}][K[{C}]{-`:shortstring`}]",
    A = "register", B = "upvalue", C = "constant"
  },
  [OP.GETTABLE] = {
    name = "GETTABLE", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}][R[{C}]]",
    A = "register", B = "register", C = "register"
  },
  [OP.GETI] = {
    name = "GETI", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}][{C}]",
    A = "register", B = "register", C = "value"
  },
  [OP.GETFIELD] = {
    name = "GETFIELD", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}][K[{C}]{-`:shortstring`}]",
    A = "register", B = "register", C = "constant"
  },

  [OP.SETTABUP] = {
    name = "SETTABUP", mode = MODE.iABCk,
    desc = "Upvalue[{A}][K[{B}]{-`:shortstring`}] := RK({C})",
    A = "upvalue", B = "constant", C = "regconst", k = "other"
  },
  [OP.SETTABLE] = {
    name = "SETTABLE", mode = MODE.iABCk,
    desc = "R[{A}][R[{B}]] := RK({C})",
    A = "register", B = "register", C = "regconst", k = "other"
  },
  [OP.SETI] = {
    name = "SETI", mode = MODE.iABCk,
    desc = "R[{A}][{B}] := RK({C})",
    A = "register", B = "value", C = "regconst", k = "other"
  },
  [OP.SETFIELD] = {
    name = "SETFIELD", mode = MODE.iABC,
    desc = "R[{A}][K[{B}]{-`:shortstring`}] := RK({C})",
    A = "register", B = "constant", C = "regconst", k = "other"
  },

  [OP.NEWTABLE] = {
    name = "NEWTABLE", mode = MODE.iABCk,
    desc = "R[{A}] := {hashsize: {=`2^B`}, arraysize: {`k ? EXTRAARG_C : C`=`k and (EXTRAARG << 8 | C) or C`}}",
    A = "register", B = "other", C = "other", k = "other", EXTRAARG = "other"
  },

  [OP.SELF] = {
    name = "SELF", mode = MODE.iABCk,
    desc = "R[{A+1}] := R[{B}]; R[{A}] := R[{B}][RK({C}){-`:string`}]",
    A = "register", B = "register", C = "regconst", k = "other"
  },

  [OP.ADDI] = {
    name = "ADDI", mode = MODE.iABsC,
    desc = "R[{A}] := R[{B}] + {sC}",
    A = "register", B = "register", sC = "value"
  },

  [OP.ADDK] = {
    name = "ADDK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] + K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.SUBK] = {
    name = "SUBK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] - K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.MULK] = {
    name = "MULK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] * K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.MODK] = {
    name = "MODK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] % K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.POWK] = {
    name = "POWK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] ^ K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.DIVK] = {
    name = "DIVK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] / K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.IDIVK] = {
    name = "IDIVK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] // K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },

  [OP.BANDK] = {
    name = "BANDK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] & K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.BORK] = {
    name = "BORK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] | K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },
  [OP.BXORK] = {
    name = "BXORK", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] ~ K[{C}]{-`:number`}",
    A = "register", B = "register", C = "constant"
  },

  [OP.SHRI] = {
    name = "SHRI", mode = MODE.iABsC,
    desc = function(inst)
      if not inst then return "R[A] := R[B] >> sC" end
      local sC = inst.sC
      return ("R[%d] := R[%d] %s %d"):format(inst.A, inst.B, sC < 0 and "<<" or ">>", math.abs(sC))
    end,
    A = "register", B = "register", sC = "value"
  },
  [OP.SHLI] = {
    name = "SHLI", mode = MODE.iABsC,
    desc = "R[{A}] := {C} << R[{B}]",
    A = "register", B = "register", sC = "value"
  },

  [OP.ADD] = {
    name = "ADD", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] + R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.SUB] = {
    name = "SUB", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] - R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.MUL] = {
    name = "MUL", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] * R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.MOD] = {
    name = "MOD", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] % R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.POW] = {
    name = "POW", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] ^ R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.DIV] = {
    name = "DIV", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] / R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.IDIV] = {
    name = "IDIV", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] // R[{C}]",
    A = "register", B = "register", C = "register"
  },

  [OP.BAND] = {
    name = "BAND", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] & R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.BOR] = {
    name = "BOR", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] | R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.BXOR] = {
    name = "BXOR", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] ~ R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.SHL] = {
    name = "SHL", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] << R[{C}]",
    A = "register", B = "register", C = "register"
  },
  [OP.SHR] = {
    name = "SHR", mode = MODE.iABC,
    desc = "R[{A}] := R[{B}] >> R[{C}]",
    A = "register", B = "register", C = "register"
  },

  [OP.MMBIN] = {
    name = "MMBIN", mode = MODE.iABC,
    desc = function(inst)
      if not inst then return "if prev. instruction failed then R[(prev. A)] := metamethod[C](R[A], R[B])" end
      local previndex
      local prev = inst.proto:eachInstruction("op", inst.op, function(inst2, i)
        if inst2 == inst then
          previndex = i - 1
          return inst.proto:I(previndex)
        end
      end)
      if not prev then return "(! Error: This instruction cannot be the first instruction !)" end
      return ("if I[%d] failed, then R[%d] := %s(R[%d], R[%d])"):format(
        previndex, prev.A, mm[inst.C] or "__unknown", inst.A, inst.B
      )
    end,
    A = "register", B = "register", C = "other"
  },
  [OP.MMBINI] = {
    name = "MMBINI", mode = MODE.iAsBCk,
    desc = function(inst)
      if not inst then
        return "if prev. instruction failed then R[(prev. A)] := k ? metamethod[C](sB, R[A]) : metamethod[C](R[A], sB)"
      end

      local previndex
      local prev = inst.proto:eachInstruction("op", inst.op, function(inst2, i)
        if inst2 == inst then
          previndex = i - 1
          return inst.proto:I(previndex)
        end
      end)
      if not prev then return "(! Error: This instruction cannot be the first instruction !)" end
      if inst.k then
        return ("if I[%d] failed then R[%d] := %s(%d, R[%d])"):format(
          previndex, prev.A, mm[inst.C] or "__unknown", inst.sB, inst.A
        )
      else
        return ("if I[%d] failed then R[%d] := %s(R[%d], %d)"):format(
          previndex, prev.A, mm[inst.C] or "__unknown", inst.A, inst.sB
        )
      end
    end,
    A = "register", sB = "value", C = "other", k = "other"
  },
  [OP.MMBINK] = {
    name = "MMBINK", mode = MODE.iABCk,
    desc = function(inst)
      if not inst then
        return "if prev. instruction failed then R[(prev. A)] := k ? metamethod[C](K[B], R[A]) : metamethod[C](R[A], K[B])"
      end

      local previndex
      local prev = inst.proto:eachInstruction("op", inst.op, function(inst2, i)
        if inst2 == inst then
          previndex = i - 1
          return inst.proto:I(previndex)
        end
      end)
      if not prev then return "(! Error: This instruction cannot be the first instruction !)" end
      if inst.k then
        return ("if I[%d] failed then R[%d] := %s(%s, R[%d])"):format(
          previndex, prev.A, mm[inst.C] or "__unknown", inst.proto:K(inst.B), inst.A
        )
      else
        return ("if I[%d] failed then R[%d] := %s(R[%d], %s)"):format(
          previndex, prev.A, mm[inst.C] or "__unknown", inst.A, inst.proto:K(inst.B)
        )
      end
    end,
    A = "register", B = "constant", C = "other", k = "other"
  },

  [OP.UNM] = {
    name = "UNM", mode = MODE.iAB,
    desc = "R[{A}] := -R[{B}]",
    A = "register", B = "register"
  },
  [OP.BNOT] = {
    name = "BNOT", mode = MODE.iAB,
    desc = "R[{A}] := ~R[{B}]",
    A = "register", B = "register"
  },
  [OP.NOT] = {
    name = "NOT", mode = MODE.iAB,
    desc = "R[{A}] := not R[{B}]",
    A = "register", B = "register"
  },
  [OP.LEN] = {
    name = "LEN", mode = MODE.iAB,
    desc = "R[{A}] := #R[{B}]",
    A = "register", B = "register"
  },

  [OP.CONCAT] = {
    name = "CONCAT", mode = MODE.iAB,
    desc = "R[{A}] := R[{A},{B-1}:` .. `]",
    A = "register", B = "range"
  },

  [OP.CLOSE] = {
    name = "CLOSE", mode = MODE.iA,
    desc = "close upvalues >= R[{A}]",
    A = "register"
  },
  [OP.TBC] = {
    name = "TBC", mode = MODE.iA,
    desc = "R[{A}] as <close>",
    A = "register"
  },
  [OP.JMP] = {
    name = "JMP", mode = MODE.isJ,
    desc = "pc += {sJ}",
    sJ = "jump"
  },
  [OP.EQ] = {
    name = "EQ", mode = MODE.iABk,
    desc = "if ((R[{A}] == R[{B}]) ~= {k}) then pc++",
    A = "register", B = "register", k = "value"
  },
  [OP.LT] = {
    name = "LT", mode = MODE.iABk,
    desc = "if ((R[{A}] < R[{B}]) ~= {k}) then pc++",
    A = "register", B = "register", k = "value"
  },
  [OP.LE] = {
    name = "LE", mode = MODE.iABk,
    desc = "if ((R[{A}] <= R[{B}]) ~= {k}) then pc++",
    A = "register", B = "register", k = "value"
  },

  [OP.EQK] = {
    name = "EQK", mode = MODE.iABk,
    desc = "if ((R[{A}] == K[{B}]) ~= {k}) then pc++",
    A = "register", B = "constant", k = "value"
  },
  [OP.EQI] = {
    name = "EQI", mode = MODE.iAsBk,
    desc = "if ((R[{A}] == {sB}) ~= {k}) then pc++",
    A = "register", sB = "value", k = "value"
  },
  [OP.LTI] = {
    name = "LTI", mode = MODE.iAsBk,
    desc = "if ((R[{A}] < {sB}) ~= {k}) then pc++",
    A = "register", sB = "value", k = "value"
  },
  [OP.LEI] = {
    name = "LEI", mode = MODE.iAsBk,
    desc = "if ((R[{A}] <= {sB}) ~= {k}) then pc++",
    A = "register", sB = "value", k = "value"
  },
  [OP.GTI] = {
    name = "GTI", mode = MODE.iAsBk,
    desc = "if ((R[{A}] > {sB}) ~= {k}) then pc++",
    A = "register", sB = "value", k = "value"
  },
  [OP.GEI] = {
    name = "GEI", mode = MODE.iAsBk,
    desc = "if ((R[{A}] >= {sB}) ~= {k}) then pc++",
    A = "register", sB = "value", k = "value"
  },

  [OP.TEST] = {
    name = "TEST", mode = MODE.iAk,
    desc = "if ((not R[{A}]) == {k}) then pc++",
    A = "register", k = "value"
  },
  [OP.TESTSET] = {
    name = "TESTSET", mode = MODE.iABk,
    desc = "if ((not R[{B}]) == {k}) then pc++ else R[{A}] := R[{B}]",
    A = "register", B = "register", k = "value"
  },

  [OP.CALL] = {
    name = "CALL", mode = MODE.iABC,
    desc = "R[{A},{C-2}] := R[{A}](R[{A+1},{B-1}])",
    info = "if (B == 0) then take varargs; if (C == 0) then return varargs",
    A = "register", B = "range", C = "range"
  },
  [OP.TAILCALL] = {
    name = "TAILCALL", mode = MODE.iABCk,
    desc = "return R[{A}](R[{A+1},{B-1}])",
    info = "if (B == 0) then take varargs; if (C > 0) then function has varargs; if (k) then call builds closable upvalues",
    A = "register", B = "vararg", C = "vararg", k = "other"
  },

  [OP.RETURN] = {
    name = "RETURN", mode = MODE.iABCk,
    desc = "return R[{A},{B-2}]",
    info = "if (B == 0) then return varargs; if (C > 0) then containing function has varargs; if (k) then containing function builds closable upvalues",
    A = "register", B = "vararg", C = "other", k = "other"
  },
  [OP.RETURN0] = {
    name = "RETURN0", mode = MODE.i_,
    desc = "return"
  },
  [OP.RETURN1] = {
    name = "RETURN1", mode = MODE.iA,
    desc = "return R[{A}]",
    A = "register"
  },

  [OP.FORLOOP] = {
    name = "FORLOOP", mode = MODE.iABx,
    desc = "if (R[{A+2}] is int) and (R[{A+1}] > 0) then R[{A+1}]--, R[{A+3}] := R[{A}] += R[{A+2}], pc -= {Bx}; elseif (R[{A+2}] is float) and (R[{A}] += R[{A+2}]) does not exceed R[{A+1}] then R[{A+3}] := R[{A}], pc -= {Bx}",
    A = "register", Bx = "jumpback"
  },
  [OP.FORPREP] = {
    name = "FORPREP", mode = MODE.iABx,
    desc = "if (R[{A}] is int) and (R[{A+2}] is int) then R[{A+3}] := R[{A}], if cannot loop then pc += {Bx+1}, return; R[{A+1}] := (R[{A+1}] - R[{A}]) / R[{A+2}]; elseif cannot loop then pc += {Bx+1}; else R[{A+3}] := R[{A}]",
    A = "register", Bx = "jump"
  },

  [OP.TFORPREP] = {
    name = "TFORPREP", mode = MODE.iABx,
    desc = "R[{A+3}] as <close>; pc += {Bx}; immediately run TFORCALL",
    A = "register", Bx = "jump"
  },
  [OP.TFORCALL] = {
    name = "TFORCALL", mode = MODE.iAC,
    desc = "R[{A+4},{C+3}] := R[{A}](R[{A+1}], R[{A+2}]); immediately run TFORLOOP",
    A = "register", C = "range"
  },
  [OP.TFORLOOP] = {
    name = "TFORLOOP", mode = MODE.iABx,
    desc = "if R[{A+4}] ~= nil then R[{A+2}] := R[A+4], pc -= {Bx}",
    A = "register", Bx = "jumpback"
  },

  [OP.SETLIST] = {
    name = "SETLIST", mode = MODE.iABC,
    desc = "for (i = 1, {`B`=`B == 0 and 'top' or B`}) do R[{A}][{`(k ? EXTRAARG_C : C)`=`k and (EXTRAARG << 8 | C) or C`}+i] := R[{A}+i]",
    info = "if (B == 0) then B = top",
    A = "register", B = "range", C = "value", k = "other", EXTRAARG = "other"
  },

  [OP.CLOSURE] = {
    name = "CLOSURE", mode = MODE.iABx,
    desc = "R[A] := newclosure(Proto[{Bx}])",
    A = "register", Bx = "proto"
  },

  [OP.VARARG] = {
    name = "VARARG", mode = MODE.iABC,
    desc = "R[{A},{C-2}] := ...",
    A = "register", C = "vararg"
  },

  [OP.VARARGPREP] = {
    name = "VARARGPREP", mode = MODE.iABC,
    desc = "(adjust vararg parameters)",
    A = "range"
  },

  [OP.EXTRAARG] = {
    name = "EXTRAARG", mode = MODE.iAx,
    desc = "(holds value for previous instruction to use)",
    Ax = "other"
  },
}

return {
  MODE = MODE,
  OP = OP,
  OP_DATA = OP_DATA,
  TYPE = TYPE
}
