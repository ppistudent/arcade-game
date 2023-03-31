local object = require("object")
local level = require("level")
local timer = require("timer")
local particle = object:extend()

particle.category = "particles"

-- Particle properties
particle.lifetime = nil
particle.lifetime_variance = 0
particle.damping = 1

local function lifetimer_timeout(timer, self)
	self:despawn()
end

function particle:new(...)
	object.new(self, ...)
	self.lifetimer = timer(self.lifetime + love.math.random(-self.lifetime_variance, self.lifetime_variance), lifetimer_timeout, self)
end

return particle
