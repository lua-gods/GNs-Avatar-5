require("lib.http")

local notif = notify("checking for backend","Backend Status",":loading:",true)

local request = net.http:request("http://127.0.0.1:8080/")
request:sendAsync(function (result, status)
	if status == 200 then
		notif:setIcon(":white_check_mark:")
		notif:setMessage("Connection successful!")
	else
		notif:setIcon(":skull:")
		notif:setMessage("Unable to reach the avatar backend")
	end
	notif:timeout(3)
end)