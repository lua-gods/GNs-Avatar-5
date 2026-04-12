### Class Name: `Line`
Draws A straight path from point A to B


## Quick Example
```lua
local Line = require("lib.line")

-- creates a line
local test = Line.new()

test
:setA(vec(0,2,1)) -- sets the first end of the line
:setB(vec(0,5,2)) -- sets the second end of the line
:setColor(1,0,0) -- sets the color to red
:setWidth(0.25) -- sets the width to a quarter of a block
```


# Properties
|Type|Field|Description| |
|-|-|-|-|
|`Vector3?`|a| First end of the line| |
|`Vector3?`|b| Second end of the line| |
|`Vector3`|color| The color of the line in RGBA| |
|`number`|depth| The offset depth of the line. 0 is normal, 0.5 is farther and -0.5 is closer| |
|`Vector3?`|dir| The difference between the first and second ends position| |
|`Vector3?`|dir_override| Overrides the dir of the line, useful for non world parent parts| |
|`integer`|id|...| |
|`number`|length| The distance between the first and second ends| |
|`SpriteTask`|model|...| |
|`number`|opacity| how transparent the line is| |
|`boolean`|visible|...| |
|`number`|width| The width of the line in meters| |
|`boolean`|_queue_update| Whether or not the line should be updated in the next frame|package|
# Methods
|Returns|Methods|
|-|-|
|`Line` |Line.[new](#linenewpreset)(preset : Line?)|
|`Line` |Line:[setAB](#linesetabx1-y1-z1-x2-y2-z2)(x1 : number｜Vector3, y1 : number｜Vector3, z1 : number, x2 : number, y2 : number, z2 : number)|
||Line:[setAB](#linesetabfrom-to)(from : Vector3, to : Vector3)|
|`Line` |Line:[setA](#linesetax-y-z)(x : number, y : number, z : number)|
||Line:[setA](#linesetapos)(pos : Vector3)|
|`Line` |Line:[setB](#linesetbx-y-z)(x : number, y : number, z : number)|
||Line:[setB](#linesetbpos)(pos : Vector3)|
|`Line` |Line:[setWidth](#linesetwidthw)(w : number)|
|`Line` |Line:[setRenderType](#linesetrendertyperender_type)(render_type : ModelPart.renderType)|
|`Line` |Line:[setOpacity](#linesetopacitya)(a : number)|
|`Line` |Line:[setColor](#linesetcolorr-g-b)(r : number, g : number, b : number)|
||Line:[setColor](#linesetcolorstring)(string : string)|
||Line:[setColor](#linesetcolorrgb)(rgb : Vector3)|
|`Line` |Line:[setDepth](#linesetdepthz)(z : number)|
||Line:[free](#linefree)()|
|`Line` |Line:[setVisible](#linesetvisiblevisible)(visible : boolean)|
|`Line` |Line:[update](#lineupdate)()|
|`Line` |Line:[immediateUpdate](#lineimmediateupdate)()|
## `Line.new(preset)`
Creates a new line.  
### Arguments
- `Line?` `preset`

### Returns `Line`

## `Line:setAB(x1, y1, z1, x2, y2, z2)`
Sets both points of the line.  
### Arguments
- `number|Vector3` `x1`

- `number|Vector3` `y1`

- `number` `z1`

- `number` `x2`

- `number` `y2`

- `number` `z2`

### Returns `Line`

## `Line:setAB(from, to)`
Sets both points of the line.  
### Arguments
- `Vector3` `from`

- `Vector3` `to`


## `Line:setA(x, y, z)`
Sets the first point of the line.  
### Arguments
- `number` `x`

- `number` `y`

- `number` `z`

### Returns `Line`

## `Line:setA(pos)`
Sets the first point of the line.  
### Arguments
- `Vector3` `pos`


## `Line:setB(x, y, z)`
Sets the second point of the line.  
### Arguments
- `number` `x`

- `number` `y`

- `number` `z`

### Returns `Line`

## `Line:setB(pos)`
Sets the second point of the line.  
### Arguments
- `Vector3` `pos`


## `Line:setWidth(w)`
Sets the width of the line.  
Note: This is in minecraft blocks/meters.  
### Arguments
- `number` `w`

### Returns `Line`

## `Line:setRenderType(render_type)`
Sets the render type of the line.  
by default this is "CUTOUT_EMISSIVE_SOLID".  
### Arguments
- `ModelPart.renderType` `render_type`

### Returns `Line`

## `Line:setOpacity(a)`
set how transparent the line is.  
### Arguments
- `number` `a`

### Returns `Line`

## `Line:setColor(r, g, b)`
Sets the color of the line. accepts RGB, RGBA or HEX string  
### Arguments
- `number` `r`

- `number` `g`

- `number` `b`

### Returns `Line`

## `Line:setColor(string)`
Sets the color of the line. accepts RGB, RGBA or HEX string  
### Arguments
- `string` `string`


## `Line:setColor(rgb)`
Sets the color of the line. accepts RGB, RGBA or HEX string  
### Arguments
- `Vector3` `rgb`


## `Line:setDepth(z)`
NOTE: dont put it too far from `0`, go in `0.01` steps  
### Arguments
- `number` `z`

### Returns `Line`

## `Line:free()`
Frees the line from memory.  

## `Line:setVisible(visible)`
Sets the visibility of the line.  
### Arguments
- `boolean` `visible`

### Returns `Line`

## `Line:update()`
gets called automatically if you change a property of the line.  
### Returns `Line`

## `Line:immediateUpdate()`
call this if you want to update the line immidiately.  
### Returns `Line`

