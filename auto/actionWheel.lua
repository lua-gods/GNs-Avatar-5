local awUtil = require("lib.GNAWUtil")
local http = require("lib.http")

local page = action_wheel:newPage()

local fileDialogAction = awUtil.action(":file_folder: File Dialog","open native file dialog","#F9CF66")
:onLeftClick(function (self)
	local request = net.http:request("http://127.0.0.1:8080/fileDialog/")
	request:sendAsync(function (result, status)
		if result and #result > 0 then
			local _,pos = result:find("/data/")
			local path = result:sub(pos+1,-1)
			if path:find("%.nbs$") then
				nbsHead(path)
			end
			if path:find("%.ogg$") then
				oggHead(path,{loop=true})
			end
		else
			print("File Dialog Failed")
		end
	end)
end):item("stripped_oak_wood")
awUtil.append(page,fileDialogAction)

local killServerAction = awUtil.action(":100: Kill Server","kills the server, if its running","#CF3552")
:onLeftClick(function (self)
	local request = net.http:request("http://127.0.0.1:8080/kill/")
	request:sendAsync(function (result, status)
	end)
end):item("minecraft:iron_sword")
awUtil.append(page,killServerAction)

local pingServerAction = awUtil.action(":mcb_light: Avatar Backend Status","pings the server if its active or not","#FFFFFF")
pingServerAction:onLeftClick(function (self)
	awUtil.title(pingServerAction,":loading: Avatar Backend Status","pinging the server...","#FFFFFF")
	local request = net.http:request("http://127.0.0.1:8080/")
	request:sendAsync(function (result, status)
		if status == 200 then
			awUtil.title(pingServerAction,":white_check_mark: Avatar Backend Status","Server is alive and well","#72C355")
		else
			awUtil.title(pingServerAction,":x: Avatar Backend Status","server is dead","#CF3552")
		end
	end)
end):item("minecraft:light")
awUtil.append(page,pingServerAction)

action_wheel:setPage(page)