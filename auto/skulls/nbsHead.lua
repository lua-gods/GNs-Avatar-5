local ModelUtils = require("lib.modelUtils")
local NBS = require("lib.nbs")
local zlib = require("lib.zlib")
local Tween = require("lib.GNtween")

local SKullAPI = require("lib.GNskull")


local MODEL = models.plushie
MODEL:setVisible(false)

local HALF = vec(0.5,0.5,0.5)



---@type ChloePianoAPI
local ChloePianoAPI = world.avatarVars()["943218fd-5bbc-4015-bf7f-9da4f37bac59"] or {playSound=function ()end}

-- thankyou 4P5 for the snippet bellow (I stole this)
local NOTES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

---@param pitch number
---@return string?
local function getNoteName(pitch)
	local note = NOTES[pitch % 12 + 1]
	local octave = math.floor((pitch / 12) - 1)
	if pitch >= 21 and pitch <= 95 then -- A0 to B7
		return note .. octave
	else
		return getNoteName(pitch + (pitch < 21 and 12 or -12))
	end
end

---@type Minecraft.soundID
local PIANO_VALID_INSTRUMENTS = {
	["minecraft:block.note_block.harp"] = -12,
	["minecraft:block.note_block.flute"] = 0,
	["minecraft:block.note_block.bass"] = -24,
	["minecraft:block.note_block.banjo"] = -24,
	["minecraft:block.note_block.xylophone"] = 0,
	["minecraft:block.note_block.pling"] = 0,
	["minecraft:block.note_block.bell"] = 0,
}

---@param pos Vector3
---@return function
local function makePianoCustomPlay(pos)
	return function (musicPlayer,instrument,_,key,volume,attenuation)
		local spos = tostring(pos)
		if PIANO_VALID_INSTRUMENTS[instrument] then
			key = key + PIANO_VALID_INSTRUMENTS[instrument]
			ChloePianoAPI.playNote(spos,getNoteName(key+21),volume*0.1)
		end
	end
end


---@type DrumAPI
local DrumAPI = world.avatarVars()["3dfb6d3b-74e3-4628-9747-1ab586e2fd65"] or {playNote = function () end}


---@param musicPlayer NBS.MusicPlayer
---@param instrument Minecraft.soundID
---@param pos Vector3
---@param key integer
---@param volume integer
---@param attenuation integer
local function customPlay(musicPlayer,instrument,pos,key,volume,attenuation)
	local cpos = client:getCameraPos()
	local pitch=2^(((key-9)/12+musicPlayer.transposition)-3)
	local block,hit = raycast:block(pos+(cpos-pos):normalize()*1.2, cpos)
	if (hit-cpos):lengthSquared() > 0.01 then
		volume = (volume*0.1)
	end
	
	sounds[instrument]
	:pos(pos)
	:pitch(pitch)
	:volume(volume)
	:attenuation(attenuation)
	:play()
end


---@param pos Vector3
---@return function
local function makeDrumCustomPlay(pos)
---@param instrument Minecraft.soundID
return function (musicPlayer,instrument,_,key,volume,attenuation)
		local spos = tostring(pos)
		if instrument == "minecraft:block.note_block.basedrum" then
			DrumAPI.playNote(spos,"B1",true,pos,volume)
		elseif instrument == "minecraft:block.note_block.snare" then
			if key > 50 then
				DrumAPI.playNote(spos,"F#2",true,pos,volume)
			elseif key > 40 then
				DrumAPI.playNote(spos,"C#3",true,pos,volume*0.2)
			else
				DrumAPI.playNote(spos,"F#2",true,pos,volume)
			end
		elseif instrument == "minecraft:block.note_block.hat" then
			DrumAPI.playNote(spos,"C#2",true,pos,volume)
		else
			customPlay(musicPlayer,instrument,pos,key,volume,attenuation)
		end
	end
end



SKullAPI.newIdentity({
	id = "nbs",
	init = function (skull, cfg)
		
		local packedBinary = skull.binary
		packedBinary = zlib.Deflate.Decompress(packedBinary)
		local buffer = data:createBuffer(#packedBinary)
		buffer:writeByteArray(packedBinary)
		buffer:setPosition(0)
		
		
		
		
		local plushie = ModelUtils.deepCopy(MODEL):setVisible(true)
		local scale = cfg.scale or 1
		plushie:setScale(scale)
		skull.model:addChild(plushie)
		cfg.squish = 0
		cfg.steer = 0
		if skull.block then
			
			
			if packedBinary then
				cfg.musicPlayer = NBS.newMusicPlayer(NBS.parseBuffer(buffer))
				buffer:close()
				
				local supportEntityData = world.getBlockState(skull.pos - vec(0,1,0)):getEntityData()
				
				if supportEntityData 
				and supportEntityData.SkullOwner 
				and supportEntityData.SkullOwner.Id then
					local id = supportEntityData.SkullOwner.Id
					local uuid = client.intUUIDToString(id[1],id[2],id[3],id[4])
					if uuid == "943218fd-5bbc-4015-bf7f-9da4f37bac59"then -- pianos
					cfg.musicPlayer:setPlayCallback(makePianoCustomPlay(skull.pos - vec(0,1,0)))
					end
					if uuid == "3dfb6d3b-74e3-4628-9747-1ab586e2fd65" then -- drums
						cfg.musicPlayer:setPlayCallback(makeDrumCustomPlay(skull.pos - vec(0,1,0)))
					end
				end
				cfg.musicPlayer.NOTE_PLAYED:register(function (cnote)
					---@cast cnote NBS.Noteblock
					cfg.squish = math.max(cnote.volume, cfg.squish)
					cfg.steer = (cnote.key / 64) - 1
					
					particles:newParticle("minecraft:note",skull.block:getPos() + HALF ,vec((cnote.instrument)/24,0,0))
					:setVelocity(vec(cnote.key/24-2,0,(cnote.instrument)/24-0.5)*0.8)
					:scale(cnote.volume*scale*1)
					:setLifetime(120)
					:setGravity(-0.5)
				end)
		end
			cfg.musicPlayer:setPos(skull.block:getPos():add(0.5,0.5,0.5)):play()
		end
	end,
	frame = function (skull,cfg, dt, df)
		cfg.squish = cfg.squish * 0.9
		local s = 1-cfg.squish
		skull.model
		:scale(1/s,s,1/s)
	end,
	tick = function (skull)
		
	end,
	exit = function (skull,cfg)
		if cfg.musicPlayer then
			cfg.musicPlayer:stop()
		end
	end
})

function nbsHead(path)
	if file:exists(path) then
		print("File ".. path .. " exists")
		local read = file:openReadStream(path)
		local buffer = data:createBuffer(read:available())
		buffer:readFromStream(read)
		buffer:setPosition(0)
		local binary = buffer:readByteArray(buffer:available())
		buffer:close()
		binary = zlib.Deflate.Compress(binary)
		makeSkull({nbs={}},binary)
	else
		print("File ".. path .. "dosent exists")
	end
	
end