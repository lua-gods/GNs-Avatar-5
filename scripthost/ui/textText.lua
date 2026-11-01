local GNUI = require("libhost.GNUI.init")
local screen = GNUI.getScreen()

if false then
	
	local container = screen:parse({
		layout="VERTICAL",
		sizing = {"FIXED","FIT"},
		size = vec(200,0),
		style = "opaque",
	})
	
	for i = 1, 10, 1 do
		container:parse{
			type="button",
			style="secondary",
			sizing = {"FILL","FIT"},
			text   = {
				{text="lorem ipsum dolor sit amet"},
				{text="hi",color="red"}
			},
			textScale=i,
			textColor = "blue",
			
		}
	end
end

