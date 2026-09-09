execute unless entity @s[tag=already_edited] if block ~ ~ ~ command_block run data modify entity @s data.editable set value 0
execute unless entity @s[tag=already_edited] if block ~ ~ ~ command_block run tag @s add already_edited

execute unless entity @s[tag=already_edited] if block ~ ~ ~ sea_lantern run data modify entity @s data.levitate set value 1
execute unless entity @s[tag=already_edited] if block ~ ~ ~ sea_lantern run tag @s add already_edited

execute unless entity @s[tag=already_edited] if block ~ ~ ~ hay_block run data modify entity @s data.levitate set value 0
execute unless entity @s[tag=already_edited] if block ~ ~ ~ hay_block run tag @s add already_edited

execute unless entity @s[tag=already_edited] if block ~ ~ ~ coal_block run data modify entity @s data.blind set value 1
execute unless entity @s[tag=already_edited] if block ~ ~ ~ coal_block run tag @s add already_edited

execute unless entity @s[tag=already_edited] if block ~ ~ ~ emerald_block run data modify entity @s data.blind set value 0
execute unless entity @s[tag=already_edited] if block ~ ~ ~ emerald_block run tag @s add already_edited

execute unless entity @s[tag=already_edited] if block ~ ~ ~ redstone_block run tag @s add to_be_removed
execute unless entity @s[tag=already_edited] if block ~ ~ ~ redstone_block run tag @s add already_edited