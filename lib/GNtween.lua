---@diagnostic disable: assign-type-mismatch
--[[______  __ 
  / ____/ | / /  by: GNanimates | Discord: @GN68s | Youtube: @GNamimates
 / / __/  |/ / name: Tween Library v2.0.1
/ /_/ / /|  /  desc: a library that makes it easier to create tweens
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/libraries/tween.lua

NOTE: Figura trims off all comments automatically by default. 
so all of this comment will be stripped out before being processed by Figura.
]]

local queries = {}
local sysTime

local tweenProcessor = models:newPart("TweenProcessor","WORLD") -- set to "WORLD" so it always runs when the player is loaded

local isActive = false
local setActive ---@type function

local function process()
	sysTime = client:getSystemTime() / 1000
	
	local toRemove = {}
	
	for id, tween in pairs(queries) do
		local duration = (sysTime - tween.start) / tween.duration
		if duration < 1 then
			local w = tween.easing(duration)
			tween.tick(math.lerp(tween.from,tween.to, w), duration)
		else
			tween.tick(tween.to, 1)
			toRemove[id] = true
			tween.onFinish()
			setActive(next(queries) and true or false)
		end
	end
	
	for id in pairs(toRemove) do
		queries[id] = nil
	end
end


setActive = function (toggle)
	if isActive ~= toggle then
		tweenProcessor.midRender = toggle and process or nil
		isActive = toggle
	end
end


---@class TweenInstanceCreation
---@field id string?
---
---@field from number|Vector.any
---@field to number|Vector.any
---
---@field duration number
---@field period number?
---@field overshoot number?
---@field amplitude number?
---
---@field easing EaseTypes|(fun(t: number): number|Vector.any)
---
---@field tick fun(v : number|Vector.any,t : number)
---@field onFinish function?


---An instance of a tween query
---@class TweenInstance
---@field id string
---
---@field from number|Vector.any
---@field to number|Vector.any
---
---@field duration number
---@field package start number?
---@field period number?
---@field overshoot number?
---@field amplitude number?
---
---@field easing fun(t: number): number|Vector.any
---
---@field tick fun(v : number|Vector.any,t : number)
---@field onFinish function?
local TweenInstance = {}
TweenInstance.__index = TweenInstance

local function placeholder() end


---Creates a new Tween instance
---***
---FIELDS:  
--- | Field       | Default    | Description                                                                                                                                     |
--- | ----------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
--- | `id`        | `?`        | The unique ID of the tween                                                                                                                      |
--- | `from`      | `0`        | The starting value of the tween                                                                                                                 |
--- | `to`        | `1`        | The ending value of the tween                                                                                                                   |
--- | `amplitude` | `1`        | The height of the oscillation (springiness). **only used for the elastic easings**                                                              |
--- | `period`    | `1`        | The frequency of the oscillation (how fast it bounces). **only used for the elastic easings**                                                   |
--- | `overshoot` | `1.7`      | controls how much the back easing will "go past" the starting position before moving toward the final value. **only used for the back easings** |
--- | `duration`  | `1`        | how long the tween will take in seconds                                                                                                         |
--- | `easing`    | `ar`       | The name of theeasing function to use                                                                                                           |
--- | `tick`      | `?`        | a callback function that gets called everytime the tween ticks                                                                                  |
--- | `onFinish`  | `?`        | a callback function that gets called when the tween finishes                                                                                    |
---@param cfg {
---	id: string?,
---	from: number|Vector.any,
---	to: number|Vector.any,
---	duration: number,
---	period: number?,
---	overshoot: number?,
---	amplitude: number?,
---	easing: EaseTypes|(fun(t: number): number|Vector.any),
---	tick: fun(v : number|Vector.any,t : number),
---	onFinish: function?}
---@return TweenInstance
function Tween.new(cfg)
	local id = cfg.id or #queries + 1
	---@type TweenInstance
	
	local new = {
		start = isActive and sysTime or (client:getSystemTime()/1000),
		from = cfg.from or 0,
		to = cfg.to or 1,
		period = cfg.period or 1,
		overshoot = cfg.overshoot or 5,
		duration = cfg.duration or 1,
		easing = Tween.easings[cfg.easing] or (type(cfg.easing) == "function" and cfg.easing) or linear,
		tick = cfg.tick or placeholder,
		onFinish = cfg.onFinish or placeholder,
		id = cfg.id
	}
	setmetatable(new, {__index = TweenInstance})
	new.tick(new.from, 0)
	queries[id] = new
	
	setActive(true)
	return new
end

---Stops this TweenInstance
function TweenInstance:stop()
	Tween.stop(self.id,true)
end

---Skips the given TweenInsatnce to finish instantly
function TweenInstance:skip()
	Tween.stop(self.id)
end


---Stops the tween with the given ID. if `cancel` is true, it NOT will call the `onFinish` function
---@param id string
---@param cancel boolean?
function Tween.stop(id, cancel)
	queries[id] = nil
	if not cancel and queries[id] then
		queries[id].onFinish()
	end
end

return Tween
