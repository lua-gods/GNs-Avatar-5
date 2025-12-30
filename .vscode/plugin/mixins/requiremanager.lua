local bce = require("bce")
local mixins = require("mixins")

local mixin = mixins.mixin
local DynamicRedirect = mixins.DynamicRedirect

mixin "'workspace.require-path'.getVisiblePath^createRequireManager^mt" {
  DynamicRedirect("searchUrisByRequireName");
  function(_old)
    local bco = bce.dump(_old)
    local proto = bco.main
    local startpc = nil

    proto:addParameter()
    proto:eachInstruction("op", bce.OP.GETTABUP, function(inst, i)
      if proto:U(inst.B).name == "plugin" and proto:K(inst.C) == "dispatch" then
        startpc = i
        return true
      end
    end)

    if not startpc then
      error("BCE failure on 'RequireManager.searchUrisByRequireName': function does not dispatch to the plugin")
    elseif proto:K(proto:I(startpc + 1).Bx) ~= "ResolveRequire" then
      error("BCE failure on 'RequireManager.searchUrisByRequireName': function does not dispatch the \"ResolveRequire\" hook")
    end

    proto:I(startpc + 5).B = 5
    proto:insertInstruction(bce.OP.MOVE, startpc + 5, {A = proto:I(startpc + 4).A + 1, B = 2})

    local f, e = bco:build(_ENV)
    if not f then
      error("BCE failure on 'RequireManager.searchUrisByRequireName': building resulted in error\n" .. e)
    end

    return f
  end,

  DynamicRedirect("findUrisByRequireName");
  function(_old)
    local bco = bce.dump(_old)
    local proto = bco.main
    local startpc = nil

    proto:eachInstruction("op", bce.OP.SELF, function(inst, i)
      if inst.k and inst.B == 0 and proto:K(inst.C) == "searchUrisByRequireName" then
        startpc = i
        return true
      end
    end)

    if not startpc then
      error("BCE failure on 'RequireManager.findUrisByRequireName': function does not call self.findUrisByRequireName")
    end

    proto:I(startpc + 2).B = 4
    proto:insertInstruction(bce.OP.MOVE, startpc + 2, {A = proto:I(startpc + 1).A + 1, B = 1})

    local f, e = bco:build(_ENV)
    if not f then
      error("BCE failure on 'RequireManager.findUrisByRequireName': building resulted in error\n" .. e)
    end

    return f
  end
}
