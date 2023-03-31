local particle = require("particles.particle")
local assets = require("assets") 
local heart = particle:extend()

heart.lifetime = 1
heart.lifetime_variance = 0.1

function heart:update(dt)
	self.z = self.z + 30 * dt
	particle.update(self, dt)
end

function heart:draw(sb)
	local _, _, w, h = assets.frames.heart:getViewport()
	sb:add(assets.frames.heart, self.position.x - w * 0.5, self.position.y - h * 0.5 - self.z)
end

return heart
