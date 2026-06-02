local function getPath()
	return select(2, pcall(function() error("", 1) end)):match("^([^\n:]*):")
end


function print(...)
	local content = {
		{text=""}
	}
	local varags = {...}
	local varagSize = #varags
	for index, value in ipairs(varags) do
		if type(value) == "table" then
			content[#content+1] = {
				text = tostring(value),
				color="#78bfff",
				hoverEvent={
					action="show_text",
					value=printTable(value,1,true):gsub("\t","  ")
				}
			}
		else
			content[#content+1] = {
				text = tostring(value)
			}
		end
		if varagSize ~= index then
			content[#content+1] = {
				text = " "
			}
		end
	end
	printJson(toJson{
		{
			color="white",
			font="minecraft:mono",
			text=""
		},
		{
			text="[lua] ",
			color="#5555FF",
		},
		{
			text="",
			extra=content
		},
		{
			text="\n"
		}
	})
end


function warn(...)
	local ok, result = pcall(toJson,{
		{
			text = "[warn] : " .. tostring(getPath()):gsub("/", " > ") .. " > \n",
			color = "yellow",
		},
		{
			text = "  " .. table.concat({ ... }, "\n  ") .. "\n",
			color = "gray",
		},
	})
	if ok then
		printJson(result)
	end
end
