### Class Name: `GNCommon`
# Methods
|Returns|Methods|
|-|-|
||gnc.[color](#gnccolorr-g-b-a)(r : number, g : number, b : number, a : number?)|
||gnc.[color](#gnccolorrgba)(rgba : Vector4)|
||gnc.[color](#gnccolorrgb)(rgb : Vector3)|
||gnc.[color](#gnccolorhex)(hex : string)|
|`number` `number?` `number?` `number?` `number?` `number?` `number?` `number?` `number?` `number?` |gnc.[unpack](#gncunpackx)(x : number｜Vector.any｜Matrix.any)|
||gnc.[packToVector](#gncpacktovectornumber)(number : Vector3｜Vector3｜Vector4)|
|`table` |gnc.[combineTables](#gnccombinetables)(. : table)|
|`table` |gnc.[appendArrays](#gncappendarrays)(. : table)|
||gnc.[vec2](#gncvec2x-y-default)(x : number?, y : number?, default : Vector2?)|
||gnc.[vec2](#gncvec2xy)(xy : Vector2)|
|`Vector3` |gnc.[vec3](#gncvec3x-y-z-default)(x : number?, y : number?, z : number?, default : Vector3?)|
||gnc.[vec3](#gncvec3xyz)(xyz : Vector3)|
|`Vector4` |gnc.[vec4](#gncvec4x-y-z-w-default)(x : number?, y : number?, z : number?, w : number?, default : Vector4?)|
||gnc.[vec4](#gncvec4xy-zw)(xy : Vector2, zw : Vector2)|
||gnc.[vec4](#gncvec4xyzw)(xyzw : Vector4)|
## `gnc.color(r, g, b, a)`
Parses a color from different formats into a Vector4.  
### Arguments
- `number` `r`

- `number` `g`

- `number` `b`

- `number?` `a`


## `gnc.color(rgba)`
Parses a color from different formats into a Vector4.  
### Arguments
- `Vector4` `rgba`


## `gnc.color(rgb)`
Parses a color from different formats into a Vector4.  
### Arguments
- `Vector3` `rgb`


## `gnc.color(hex)`
Parses a color from different formats into a Vector4.  
### Arguments
- `string` `hex`


## `gnc.unpack(x)`
Unpacks a Vector, Matrix or table into its components  
### Arguments
- `number|Vector.any|Matrix.any` `x`

### Returns
  - `number`
  - `number?`
  - `number?`
  - `number?`
  - `number?`
  - `number?`
  - `number?`
  - `number?`
  - `number?`
  - `number?`

## `gnc.packToVector(number)`
```lua  
GNCommon.packToVector(1,2,3,4)  
GNCommon.packToVector(vec(1,2),vec(3,4))  
GNCommon.packToVector(vec(1,2,3),4)  
```   
^ all outputs a `Vector4(1,2,3,4)`  
***  
NOTE:  
this uses an average of `121` instructions. use `GNCommmon.vec2`/`GNCommon.vec3`/`GNCommon.vec4` instead  
### Arguments
- `Vector3|Vector3|Vector4` `number`


## `gnc.combineTables(.)`
Combines tables into one, t2 takes priority  
### Arguments
- `table` `.`

### Returns `table`

## `gnc.appendArrays(.)`
Concatinates arrays into one long array.  
### Arguments
- `table` `.`

### Returns `table`

## `gnc.vec2(x, y, default)`
Parses Vector2 variants into a single unified Vector2.  
uses an average of `20` instructions  
### Arguments
- `number?` `x`

- `number?` `y`

- `Vector2?` `default`


## `gnc.vec2(xy)`
Parses Vector2 variants into a single unified Vector2.  
uses an average of `20` instructions  
### Arguments
- `Vector2` `xy`


## `gnc.vec3(x, y, z, default)`
Parses Vector3 variants into a single unified Vector3.  
uses an average of `26` instructions  
### Arguments
- `number?` `x`

- `number?` `y`

- `number?` `z`

- `Vector3?` `default`

### Returns `Vector3`

## `gnc.vec3(xyz)`
Parses Vector3 variants into a single unified Vector3.  
uses an average of `26` instructions  
### Arguments
- `Vector3` `xyz`


## `gnc.vec4(x, y, z, w, default)`
Parses Vector4 variants into a single unified Vector4.  
uses an average of `32` instructions  
### Arguments
- `number?` `x`

- `number?` `y`

- `number?` `z`

- `number?` `w`

- `Vector4?` `default`

### Returns `Vector4`

## `gnc.vec4(xy, zw)`
Parses Vector4 variants into a single unified Vector4.  
uses an average of `32` instructions  
### Arguments
- `Vector2` `xy`

- `Vector2` `zw`


## `gnc.vec4(xyzw)`
Parses Vector4 variants into a single unified Vector4.  
uses an average of `32` instructions  
### Arguments
- `Vector4` `xyzw`


