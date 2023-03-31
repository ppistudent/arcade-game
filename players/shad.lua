local player = require("players.player")
local shad = player:extend()

shad.name = "voidman"
shad.speed = 60
shad.radius = 4
shad.capacity = 4
shad.power = 140
shad.coverage = math.pi / 1.7
shad.range = 25
shad.health = 2
shad.reload = 0.75
shad.stunning = 2.2
shad.require_score = 100000
shad.quadro_shots = true

return shad
