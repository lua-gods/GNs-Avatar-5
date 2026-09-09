execute if entity @s[tag=has_origin_selected] run tag @s add b
execute if entity @s[tag=has_origin_selected] run function wormholes:construction/link_wormhole
execute unless entity @s[tag=has_origin_selected] unless entity @s[tag=b] run function wormholes:construction/begin_link
tag @s remove b