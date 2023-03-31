local monster = require("monsters.monster")
local level = require("level")
local timer = require("timer")
local vec2 = require("vec2")
local fred = monster:extend()

local acid = require("projectiles.acid")

fred.name = "fred"
fred.health = 1
fred.speed = 10
fred.reward = 250

local function shot_timeout(timer, self)
	acid(self.position, vec2())
	timer:reset()
end

function fred:new(...)
	monster.new(self, ...)
	self.shot_timer = timer(0.5, shot_timeout, self)
end

function fred:destroy()
	monster.destroy(self)
	if self.shot_timer ~= nil then
		self.shot_timer:stop()
	end
end

function fred:ai(dt)
	self:follow(120)
end

return fred
