local player = require("players.player")
local robot = player:extend()

robot.name = "robot"
robot.speed = 48
robot.radius = 4
robot.capacity = 5
robot.power = 240
robot.coverage = math.pi / 3.5
robot.range = 35
robot.health = 5
robot.reload = 0.2
robot.stunning = 1.5
robot.require_score = 40000

return robot
