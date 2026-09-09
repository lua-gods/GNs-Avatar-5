tag @s add has_origin_selected
execute store result score @s apple_wormholes_construction_origin_x run data get entity @s Pos[0] 1
execute store result score @s apple_wormholes_construction_origin_y run data get entity @s Pos[1] 1
execute store result score @s apple_wormholes_construction_origin_z run data get entity @s Pos[2] 1

title @s actionbar "Selected from, move to destination and execute function again"