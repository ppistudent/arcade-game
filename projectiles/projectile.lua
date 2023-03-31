local particle = require("particles.particle")
local projectile = particle:extend()

projectile.category = "projectiles"

-- Projectile properties
projectile.damage = nil
projectile.speed = nil

function projectile:new(position, direction, ...)
	particle.new(self, position, direction * self.speed, ...)
end

return projectile
