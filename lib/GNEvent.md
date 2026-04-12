### Class Name: `GN.Event`
# Methods
|Returns|Methods|
|-|-|
|`GN.Event` |Events.[new](#eventsnew)()|
|`GN.EventGroup` |Events.[newGroup](#eventsnewgroup)()|
||Events:[register](#eventsregisterfunc-name)(func : function, name : any)|
||Events:[clear](#eventsclear)()|
||Events:[remove](#eventsremovename)(name : any｜function)|
|`integer` |Events:[getRegisteredCount](#eventsgetregisteredcountname)(name : any)|
||Events:[__call](#events__call)()|
||Events.[__index](#events__index)()|
||Events.[__newindex](#events__newindex)()|
## `Events.new()`
### Returns `GN.Event`

## `Events.newGroup()`
### Returns `GN.EventGroup`

## `Events:register(func, name)`
Registers a function as a listener to the event when it triggers.  
### Arguments
- `function` `func`

- `any` `name`


## `Events:clear()`
Clears all the registered listeners.  

## `Events:remove(name)`
Removes the listener with the given name.  
### Arguments
- `any|function` `name`


## `Events:getRegisteredCount(name)`
Returns the amount of events with the given name.  
### Arguments
- `any` `name`

### Returns `integer`

## `Events:__call()`

## `Events.__index()`

## `Events.__newindex()`

