execute if entity @s[nbt={data:{editable:1}}] run function wormholes:editing/process_editable_wormhole

execute unless entity @s[tag=already_edited] if block ~ ~ ~ command_block run data modify entity @s data.editable set value 1
execute unless entity @s[tag=already_edited] if block ~ ~ ~ command_block run tag @s add already_edited


execute if entity @s[tag=already_edited] run setblock ~ ~ ~ air
tag @s remove already_edited
execute if entity @s[tag=to_be_removed] run kill @s
