#host
--[[______   __
  / ____/ | / / Name: GN ACTION WHEEL UTILITY LIBRARY v1.0.0
 / / __/  |/ /  Desc: contains useful API for the action wheel
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]


---@param str string
---@param vars {[string]: string|number}
---@return string
local function namedFormat(str, vars)
	return (string.gsub(str, "%b()", function(key)
		return vars[key:sub(2,-2)]
	end))
end

local function namedFormat2(str,vars)
		return select(1,string.gsub(str,"{(%a+)}",vars))
end


--────  ────────────────────────────────────────────--


local GNAW = {}


local STYLE = ""
local DEFAULT_COLOR = "#ffffff"

---sets the raw json text template used for the action function.  
---use these placeholders for the action function to replace over:  
---`(title)`, `(desc)`, `(color)`
---@param style table
function GNAW.setStyle(style)
	STYLE = toJson(style)
end


function GNAW.setDefaultColor(hexColor)
	DEFAULT_COLOR = hexColor
end


GNAW.setStyle({
	{text="",color="gray"},
	{text="(title)",color="(color)"},
	{text="\n"},
	{text="(desc)"}
})


---@param title string
---@param description string?
---@param hexColor string?
---@return Action
function GNAW.action(title,description,hexColor)
	return GNAW.title(action_wheel:newAction(),title,description,hexColor)
end

function GNAW.title(action,title,description,hexColor)
	hexColor = hexColor or DEFAULT_COLOR
	description = description or ""
	action:title(namedFormat(
	STYLE,{
		title=title,
		desc=description,
		color=hexColor
	}))
	return action
end


---Appends an action onto the given page
---@param page Page
---@param action Action
---@return Page
function GNAW.append(page,action)
	page:setAction(#page:getActions()+1,action)
	return page
end

return GNAW