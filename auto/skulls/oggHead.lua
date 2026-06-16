local ModelUtils = require("lib.modelUtils")
local zlib = require("lib.zlib")
local Tween = require("lib.GNtween")

local SKullAPI = require("lib.GNskull")


local MODEL = models.plushie
MODEL:setVisible(false)

local HALF = vec(0.5, 0.5, 0.5)


local function isInside(pos,from,to)
	return pos.x >= from.x 
	   and pos.x <= to.x 
	   and pos.y >= from.y 
	   and pos.y <= to.y 
	   and pos.z >= from.z 
	   and pos.z <= to.z
end

local DOWN = vec(0,1,0)

SKullAPI.newIdentity({
	id = "ogg",
	init = function(skull, cfg)
		local packedBinary = skull.binary
		local buffer = data:createBuffer(#packedBinary)
		buffer:writeByteArray(packedBinary)
		buffer:setPosition(0)
		local data = buffer:readBase64()

		local plushie = ModelUtils.deepCopy(MODEL):setVisible(true)
		local scale = cfg.scale or 1
		plushie:setScale(scale)
		skull.model:addChild(plushie)

		cfg.wasPowered = false

		if skull.block then
			if packedBinary then
				sounds:newSound(skull.hash, data)
				buffer:close()
			end
		end
		cfg.c = 0
		if cfg.from and cfg.to then
			local a,b = cfg.from, cfg.to
			cfg.from = vec(math.min(a[1], b[1]), math.min(a[2], b[2]), math.min(a[3], b[3]))
			cfg.to = vec(math.max(a[1], b[1])+1, math.max(a[2], b[2])+1, math.max(a[3], b[3])+1)
			cfg.global = true
			cfg.hasRegion = true
		else
			cfg.hasRegion = false
		end
		cfg.volume = cfg.volume or 1
		cfg.fadeTime = 0
		cfg.fade = cfg.fade or 0.001
		if skull.ctx == "BLOCK" then
			cfg.pos = skull.block:getPos()
		end
	end,
	world_frame = function(skull, cfg, dt, df)
		if skull.block then
			if cfg.active then
				local pos = client:getCameraPos()

				if cfg.global then
					cfg.audio
						 :setPos(pos + client:getCameraDir())
				end
			end
		end
	end,
	frame = function(skull, cfg, dt, df)
		if cfg.active then
			cfg.c = cfg.c + df

			local s = math.sin(cfg.c * 3.14159 * 4) * 0.1 * (cfg.fadeTime / cfg.fade) + 1
			skull.model
				 :scale(1 / s, s, 1 / s)

			local pos = client:getCameraPos()

			if cfg.global and cfg.audio then
				cfg.audio
					 :setPos(pos + client:getCameraDir())
			end
		end
	end,
	tick = function(skull, cfg)
		if skull.ctx == "BLOCK" then
			local activate = world.getRedstonePower(cfg.pos - DOWN) == 0
			if cfg.hasRegion then
				activate = activate and isInside(client:getCameraPos(),cfg.from,cfg.to)
			end
			
			if activate then
				if cfg.fadeTime < cfg.fade then
					cfg.fadeTime = math.min(cfg.fadeTime + 0.05, cfg.fade)
					if cfg.audio and cfg.audio:isPlaying() then
						cfg.audio:volume(cfg.fadeTime / cfg.fade * cfg.volume)
					end
				end
			else
				if cfg.fadeTime > 0 then
					cfg.fadeTime = math.max(cfg.fadeTime - 0.05, 0)
					if cfg.audio then
						cfg.audio:volume(cfg.fadeTime / cfg.fade * cfg.volume)
					end
				end
			end
			cfg.active = cfg.fadeTime > 0
			if cfg.wasPowered ~= cfg.active then
				if cfg.active then
					cfg.audio = sounds[skull.hash]
						 :pos(skull.block:getPos() + HALF)
						 :loop(cfg.loop)
						 :volume(cfg.fadeTime > 0.01 and 0 or cfg.volume)
						 :pitch(cfg.pitch or 1)
						 :attenuation(cfg.attenuation or 1)
						 :play()
				else
					cfg.c = 0
					if cfg.audio then
						cfg.audio:stop()
					end
				end
				cfg.wasPowered = cfg.active
			end
		end
	end,
	exit = function(skull, cfg)
		if cfg.audio then
			cfg.audio:stop()
		end
	end,
})

function oggHead(path, flags)
	if file:exists(path) then
		print("File " .. path .. " exists")
		local read = file:openReadStream(path)
		local buffer = data:createBuffer(read:available())
		buffer:readFromStream(read)
		buffer:setPosition(0)
		local binary = buffer:readByteArray(buffer:available())
		buffer:close()

		flags = flags or {}
		local item = SKullAPI.makeHead({ ogg = flags }, binary)
		giveItem(item)
	else
		print("File " .. path .. "dosent exists")
	end
end



function oggArea()
	local from = client:getCameraPos():floor():sub(0,1,0)
	local ogOggArea = oggArea
	host:setActionbar("Captured From:" .. from.x .. " " .. from.y .. " " .. from.z)
	
	function oggArea()
		local to = client:getCameraPos():floor()
		local json = ("to={%d,%d,%d},from={%d,%d,%d}"):format(from.x,from.y,from.z,to.x,to.y,to.z)
		host:setActionbar("Saved Region:" .. json)
		host:setClipboard(json)
		oggArea = ogOggArea
	end
end