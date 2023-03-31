local particle = require("particles.particle")
local dust = particle:extend()

dust.damping = 1
dust.lifetime = 0.1 

function dust:draw()
	love.graphics.setColor("white")
	love.graphics.circle("fill", self.position.x, self.position.y, 1)
end

return dust
