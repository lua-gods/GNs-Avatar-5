### Class Name: `GN.ProceduralTextureAPI`
a very lightweight library that Lets you render a callback function to a texture, like `texture:applyFunc()`

The texture is rendered as a partial Quadtree to easily approximate a texture at low resolution, and then render the higher fidelity texture on top

> **NOTE**  
> while this does speed up rendering, **it does not support transparency**, its the trade off for the fast rendering

Example
```lua
local RESOLUTION = 64 * 3
ProceduralTexture:newTexture("colorWheel", RESOLUTION, RESOLUTION, function(x, y, w, h)
	x = x / w - 0.5
	y = y / h - 0.5

	local dist = math.sqrt(x * x + y * y) * 2
	local angle = math.atan2(x, -y)

	return vectors.hsvToRGB(angle / (TAU), dist, 1):augmented(math.clamp((1 - dist) * 98, 0, 1))
end)
```

# Methods
|Returns|Methods|
|-|-|
||ProceduralTextureAPI:[apply](#proceduraltextureapiapplytexture-applyfunc)(texture : Texture, applyFunc : fun(x:integer,y:integer,w:integer,h:integer):Vector4)|
||ProceduralTextureAPI:[newTexture](#proceduraltextureapinewtexturename-width-height-applyfunc)(name : string, width : integer, height : integer, applyFunc : fun(x:integer,y:integer,w:integer,h:integer):Vector4)|
## `ProceduralTextureAPI:apply(texture, applyFunc)`
### Arguments
- `Texture` `texture`

- `fun(x:integer,y:integer,w:integer,h:integer):Vector4` `applyFunc`


## `ProceduralTextureAPI:newTexture(name, width, height, applyFunc)`
### Arguments
- `string` `name`

- `integer` `width`

- `integer` `height`

- `fun(x:integer,y:integer,w:integer,h:integer):Vector4` `applyFunc`


