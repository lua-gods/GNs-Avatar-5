tag @s remove has_origin_selected

execute at @s align xyz run summon marker ~ ~ ~ {Tags:["apple_wormhole", "apple_construction"], data:{editable:0, blind:0}}


#scoreboard players operation position scratchboard = @s apple_wormholes_construction_origin_z
#execute store result score player scratchboard run data get entity @s Pos[2] 1
#scoreboard players operation position scratchboard -= player scratchboard
#execute store result entity @e[tag=apple_construction, limit=1] data.z int 1 run scoreboard players get position scratchboard

scoreboard players operation m1 scratchboard = @s apple_wormholes_construction_origin_x
execute store result score m2 scratchboard run data get entity @s Pos[0] 1
scoreboard players operation m2 scratchboard -= m1 scratchboard
execute store result entity @e[tag=apple_construction, limit=1] data.x int 1 run scoreboard players get m2 scratchboard


scoreboard players operation m1 scratchboard = @s apple_wormholes_construction_origin_y
execute store result score m2 scratchboard run data get entity @s Pos[1] 1
scoreboard players operation m2 scratchboard -= m1 scratchboard
execute store result entity @e[tag=apple_construction, limit=1] data.y int 1 run scoreboard players get m2 scratchboard


scoreboard players operation m1 scratchboard = @s apple_wormholes_construction_origin_z
execute store result score m2 scratchboard run data get entity @s Pos[2] 1
scoreboard players operation m2 scratchboard -= m1 scratchboard
execute store result entity @e[tag=apple_construction, limit=1] data.z int 1 run scoreboard players get m2 scratchboard


execute store result entity @e[tag=apple_construction, limit=1] Pos[0] double 1 run scoreboard players get @s apple_wormholes_construction_origin_x
execute store result entity @e[tag=apple_construction, limit=1] Pos[1] double 1 run scoreboard players get @s apple_wormholes_construction_origin_y
execute store result entity @e[tag=apple_construction, limit=1] Pos[2] double 1 run scoreboard players get @s apple_wormholes_construction_origin_z

tag @e[tag=apple_construction] remove apple_construction

title @s actionbar "Wormhole linked"