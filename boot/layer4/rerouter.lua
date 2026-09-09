
ROOT_MODEL = models

models = models.models

local ogIndex = figuraMetatables.AnimationAPI.__index
figuraMetatables.AnimationAPI.__index = function(self, key)
	return ogIndex(self,key) or ogIndex(self, "models."..tostring(key))
end

local ogTextureAPIIndex = figuraMetatables.TextureAPI.__index
figuraMetatables.TextureAPI.__index = function(self, key)
	return ogTextureAPIIndex(self,key) or ogTextureAPIIndex(self, "textures."..tostring(key))
end

local ogSoundsAPIIndex = figuraMetatables.SoundAPI.__index
figuraMetatables.SoundAPI.__index = function(self, key)
	return ogSoundsAPIIndex(self,key) or ogSoundsAPIIndex(self, "sounds."..tostring(key))
end