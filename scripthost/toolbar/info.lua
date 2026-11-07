local Macro = require("lib.GNMacros")
local GNUI = require("libhost.GNUI.init")
local Window = require("scripthost.ui.window")

local SIZE = vec(300,200)
local myMacro

---@param self GN.Macros
---@param screen GNUI.Canvas
---@param GNUI GNUIAPI
---@param btn GNUI.Box
myMacro = Macro.new(function (self, events, screen, GNUI, btn)
	
	local win = Window.new(screen)
	
	win:parse{
		type="container",
		style="opaque",
		size = vec(SIZE.x,SIZE.y),
		growDirection=vec(1,-1),
		pos = vec(-1,-2),
		name="info",
		layout="VERTICAL",
	}
	
	win:setTitle("Information Spreadsheet")
	:setPos(50,50)
	
	local infoBox = win:getChild("info")
	
	local color = vec(0,1,0)
	local odd = false
	local function newEntry(name,value,clipboard)
		odd = not odd
		local infoRow = infoBox:parse{
			layout="HORIZONTAL",
			sizing = {"FILL","FIT"},
			{
				{
					type="button",
					text={text=name,color=vec(1,1,1)},
					textAlign = {1,0},
					color = odd and (color * 0.3) or (color * 0.2),
					size = vec(60,0),
					sizing={"FIXED","FILL"}
				},
				{
					type="button",
					text=tostring(value),
					textAlign = {-1,0},
					color = odd and math.lerp(color,vec(1,1,1),0.9) or vec(1,1,1),
					name="valueBtn",
					wrapText=false,
					sizing={"FILL","FILL"},
				},
			}
		}
		local valuebtn = infoRow:getChild("valueBtn")
		---@cast valuebtn GNUI.Widget.Button
		valuebtn.PRESSED:register(function ()
			host:setClipboard(tostring(clipboard or value))
		end)
	end
	
	local function newTitle(icon,name)
		odd = true
		infoBox:parse{
			type="button",
			text={{text=icon},{text=" "..name,bold=true}},
			color = color * 0.4,
			textColor = vec(1,1,1),
			minSize = vec(0,10),
			textAlign = {-1,0},
			sizing={"FILL","FIT"}
		}
	end
	
	local data = client:getServerData()
	color = vec(0,1,0)
	newTitle(":grass_block:","SERVER INFO")
	newEntry("name",data.name)
	newEntry("IP",data.ip)
	newEntry("Motd",data.motd)
	newEntry("Brand",client:getServerBrand())
	
	color = vec(1,0.6,0.6)
	newTitle(":mcm_player:","PLAYER INFO")
	newEntry("Position",("%.1f %.1f %.1f"):format(player:getPos():unpack()))
	newEntry("Rotation",("%.2f %.2f"):format(player:getRot():unpack()))
	newEntry("Name",player:getName())
	newEntry("Health",player:getHealth().." / "..player:getMaxHealth())
	newEntry("Food",tostring(player:getFood()))
	
	local block = player:getTargetedBlock(true,100)
	color = vec(0.8,0.6,0)
	newTitle(":gun:","TARGET BLOCK INFO")
	newEntry("ID",block:getID())
	newEntry("Name",client.getTranslatedString(string.format("block.%s.%s",string.match(block:getID(),"([^:]+):([^:]+)"))))
	newEntry("Hardness",block:getHardness())
	newEntry("Friction",block:getFriction())
	newEntry("Resistance",block:getBlastResistance())
	newEntry("is FullCube",block:isFullCube())
	newEntry("is Opaque",block:isOpaque())
	newEntry("is Solid",block:isSolidBlock())
	newEntry("Translucnt",block:isTranslucent())
	
	color = vec(0,0.6,1)
	newTitle(":earth:","WORLD INFO")
	newEntry("Dimension",world:getDimension())
	newEntry("Height",string.format("%s to %s",world:getBuildHeight()))
	newEntry("Day",world.getDay())
	newEntry("Daytime",world.getTimeOfDay() % 24000)
	newEntry("Spawn",("%s %s %s"):format(world.getSpawnPoint():unpack()))
	newEntry("Weather",world.isThundering() and "Thunderstorm" or (world.getRainGradient() > 0.5 and "Rain" or "Clear"))
	
	events.ON_EXIT:register(function ()
		win:free()
	end)
end)

return myMacro