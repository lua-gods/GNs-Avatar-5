### Class Name: `GN.Macro`



This library allows you to make a chunk of your code togglable!

examples being togglable accessories that do stuff when active, but completely turn off when turned off

## Added / Modified Events
- **ENTITY_INIT**: instead of being triggered once, it gets triggered once the player is loaded; everytime the macro is enabled, if the player isnt loaded, it will wait until the player is loaded.
- **ON_EXIT**: gets triggered when the macro is disabled
- **ON_ENTITY_LOAD**: similar to the original ENTITY_INIT, but this triggers everytime the player is loaded
- **ON_ENTITY_UNLOAD**: the opposite of ON_ENTITY_LOAD, triggers everytime the player unloads

> NOTE
> registering with ON_ENTITY_LOAD and ON_ENTITY_UNLOAD will make the macro use WORLD_TICK instructions
## Example Demo
```lua
local Macros = require("lib.GNMacros")

local macro = Macros.new(function (events, ...)
    -- triggers when the player is loaded and the macro is enabled
    events.ENTITY_INIT:register(function ()
        print("INIT")
    end)
    
    events.RENDER:register(function ()
        print("tick")
    end)
    
    -- triggers when the macro is disabled
    events.ON_EXIT:register(function ()
        print("end")
    end)
end)


events.TICK:register(function ()
    -- enable the macro when the player sneaks
    macro:setActive(player:isSneaking())
end)
```




# Properties
|Type|Field|Description| |
|-|-|-|-|
|`MacroEventsAPI`|events|...| |
|`string`|id|...| |
|`fun(events: MacroEventsAPI,...):any?`|init|...|package|
|`boolean`|isActive|...| |



# Methods
|Returns|Methods|
|-|-|
|`...` |Macro:[setActive](#macrosetactiveactive-any)(active : boolean, any : )|
## `Macro:setActive(active, any)`
Enables / Disables the macro
  
### Arguments
- `boolean` `active`

- `` `any`

### Returns `...`


***
***
***


### Class Name: `MacroEventsAPI`
# Properties
|Type|Field|Description| |
|-|-|-|-|
|`Event`|ON_ENTITY_LOAD|...| |
|`Event`|ON_ENTITY_UNLOAD|...| |
|`Event`|ON_EXIT|...| |
|`Event`|ARROW_RENDER|...| |
|`Event`|CHAR_TYPED|...| |
|`Event`|CHAT_RECEIVE_MESSAGE|...| |
|`Event`|CHAT_SEND_MESSAGE|...| |
|`Event`|ENTITY_INIT|...| |
|`Event`|ERROR|...| |
|`Event`|GUI_RENDER|...| |
|`Event`|ITEM_RENDER|...| |
|`Event`|KEY_PRESS|...| |
|`Event`|MOUSE_MOVE|...| |
|`Event`|MOUSE_PRESS|...| |
|`Event`|MOUSE_SCROLL|...| |
|`Event`|ON_PLAY_SOUND|...| |
|`Event`|POST_RENDER|...| |
|`Event`|POST_WORLD_RENDER|...| |
|`Event`|RENDER|...| |
|`Event`|RESOURCE_RELOAD|...| |
|`Event`|SKULL_RENDER|...| |
|`Event`|TICK|...| |
|`Event`|TRIDENT_RENDER|...| |
|`Event`|USE_ITEM|...| |
|`Event`|WORLD_RENDER|...| |
|`Event`|WORLD_TICK|...| |
|`Event`|arrow_render|...| |
|`Event`|char_typed|...| |
|`Event`|chat_receive_message|...| |
|`Event`|chat_send_message|...| |
|`Event`|entity_init|...| |
|`Event`|error|...| |
|`Event`|gui_render|...| |
|`Event`|item_render|...| |
|`Event`|key_press|...| |
|`Event`|mouse_move|...| |
|`Event`|mouse_press|...| |
|`Event`|mouse_scroLll|...| |
|`Event`|on_pLay_sound|...| |
|`Event`|post_render|...| |
|`Event`|post_world_render|...| |
|`Event`|render|...| |
|`Event`|resource_reload|...| |
|`Event`|skuLl_render|...| |
|`Event`|tick|...| |
|`Event`|trident_render|...| |
|`Event`|use_item|...| |
|`Event`|world_render|...| |
|`Event`|world_tick|...| |


***
***
***

### Class Name: `MacroAPI`
# Methods
|Returns|Methods|
|-|-|
|`GN.Macro` |MacrosAPI.[new](#macrosapinewinit)(init : fun(events:)|
## `MacrosAPI.new(init)`
### Arguments
- `fun(events:` `init`

### Returns `GN.Macro`

