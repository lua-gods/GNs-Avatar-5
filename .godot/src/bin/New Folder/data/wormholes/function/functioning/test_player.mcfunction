tag @s add apple_current_player

execute if entity @s[tag=wormhole_just_teleported] align xyz unless entity @e[distance=..0.1, tag=apple_wormhole] run tag @s remove wormhole_just_teleported
execute unless entity @s[tag=wormhole_just_teleported] align xyz as @e[distance=..0.1, tag=apple_wormhole, limit=1] run function wormholes:functioning/work_wormhole

tag @s remove apple_current_player