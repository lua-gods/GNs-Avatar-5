execute at @e[tag=apple_current_player, limit=1] run summon marker ~ ~ ~ {Tags:["apple_playerhead"]}
# rotation
tp @e[tag=apple_playerhead, limit=1] ~ ~ ~ ~ ~

execute store result score position scratchboard run data get entity @e[tag=apple_current_player, limit=1] Pos[0] 1000
execute store result score wormhole scratchboard run data get entity @s data.x 1000
scoreboard players operation position scratchboard += wormhole scratchboard
execute store result entity @e[tag=apple_playerhead, limit=1] Pos[0] double 0.001 run scoreboard players get position scratchboard


execute store result score position scratchboard run data get entity @e[tag=apple_current_player, limit=1] Pos[1] 1000
execute store result score wormhole scratchboard run data get entity @s data.y 1000
scoreboard players operation position scratchboard += wormhole scratchboard
execute store result entity @e[tag=apple_playerhead, limit=1] Pos[1] double 0.001 run scoreboard players get position scratchboard


execute store result score position scratchboard run data get entity @e[tag=apple_current_player, limit=1] Pos[2] 1000
execute store result score wormhole scratchboard run data get entity @s data.z 1000
scoreboard players operation position scratchboard += wormhole scratchboard
execute store result entity @e[tag=apple_playerhead, limit=1] Pos[2] double 0.001 run scoreboard players get position scratchboard

execute at @e[tag=apple_playerhead, limit=1] run tp @e[tag=apple_current_player, limit=1] ~ ~ ~ ~ ~

execute if entity @s[nbt={data:{levitate:1}}] run effect give @e[tag=apple_current_player, limit=1] levitation 1 10 true
execute if entity @s[nbt={data:{blind:1}}] run effect give @e[tag=apple_current_player, limit=1] blindness 5 1 true

tag @e[tag=apple_current_player, limit=1] add wormhole_just_teleported

kill @e[tag=apple_playerhead, limit=1]
