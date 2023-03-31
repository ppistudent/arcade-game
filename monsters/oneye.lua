local monster = require("monsters.monster")
local timer = require("timer")
local vec2 = require("vec2")
local bullet = require("projectiles.bullet")
local oneye = monster:extend()

oneye.name = "oneye"
oneye.health = 3
oneye.speed = 10
oneye.reward = 400

function oneye.wander_timeout(timer, self)
	monster.wander_timeout(timer, self)
	bullet(self.position, self.direction:perpend())
end

function oneye:ai(dt)
	self:wander(3)
end

return oneye
