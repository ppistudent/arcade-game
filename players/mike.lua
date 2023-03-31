local player = require("players.player")
local mike = player:extend()

mike.name = "guy"
mike.speed = 60
mike.radius = 4
mike.capacity = 3
mike.power = 80
mike.coverage = math.pi / 3
mike.range = 23
mike.health = 4
mike.reload = 1
mike.stunning = 1
mike.require_score = 0

return mike
