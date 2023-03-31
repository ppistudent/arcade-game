local monster = require("monsters.monster")
local level = require("level")
local meatboy = monster:extend()

meatboy.name = "meatboy"
meatboy.health = 1
meatboy.speed = 30
meatboy.reward = 100

function meatboy:ai(dt)
	self:wander(2)
end

return meatboy
