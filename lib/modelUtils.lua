--[[______   __
  / ____/ | / / Name: GN MODEL UTILS LIBRARY v1.1.0
 / / __/  |/ /  Desc: a script with some useful functions for working with models
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Copyleft License ]]
---@class GN.ModelUtils
local ModelUtils = {}

local function isModel(model)
	if not type(model) then
		error("expected ModelPart, got "..type(model),2)
	end
end

local function deepCopy(part)
	local copy = part:copy(part:getName())
	for key, value in pairs(part:getTask()) do
		copy:addTask(value)
	end
	for _, child in ipairs(part:getChildren()) do
		copy:removeChild(child)
		deepCopy(child):moveTo(copy)
	end
	return copy
end

-- duplicates a model while keeping its children as references to the original.  
-- this exists because normal copy dosent copy over render tasks while this one does.
function ModelUtils.shallowCopy(modelPart)
	isModel(modelPart)
	local copy = modelPart:copy(modelPart:getName())
	for key, value in pairs(modelPart:getTask()) do
		copy:addTask(value)
	end
	return copy
end



---@param modelPart ModelPart
---@param func fun(modelPart:ModelPart): boolean?
local function apply(modelPart,func)
	local cancel = func(modelPart)
	if not cancel then
		for _, child in ipairs(modelPart:getChildren()) do
			apply(child,func)
		end
	end
end


---Applies a callback function to all the model's children.
---@param modelPart ModelPart
---@param func fun(modelPart:ModelPart): boolean?
---@return ModelPart
function ModelUtils.apply(modelPart,func)
	isModel(modelPart)
	return apply(modelPart,func)
end


--- duplicates the model recursively. with no references to the original
---@param modelPart ModelPart
function ModelUtils.deepCopy(modelPart)
	isModel(modelPart)
	return deepCopy(modelPart)
end


return ModelUtils