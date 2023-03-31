local monster = require("monsters.monster")
local level = require("level")
local timer = require("timer")
local vec2 = require("vec2")
local woise = monster:extend()

local pufft = require("particles.pufft")

woise.name = "woise"
woise.health = 1
woise.speed = 10
woise.reward = 350
woise.damping = 0.5

function woise:ai(dt)
	if not self:follow(16) then
		self:wander(4)
	end
end

return woise
