local particle = require("particles.particle")
local pufft = particle:extend()

pufft.lifetime = 2
pufft.lifetime_variance = 0
pufft.radius = 2
pufft.damping = 0.98

function pufft:draw()
	love.graphics.setColor("white")
	love.graphics.circle("fill", self.position.x, self.position.y - self.z, 2)
end

return pufft
