local particle = require("particles.particle")
local assets = require("assets") 
local angry = particle:extend()

angry.lifetime = 1
angry.lifetime_variance = 0.1

function angry:update(dt)
	self.z = self.z + 30 * dt
	particle.update(self, dt)
end

function angry:draw(sb)
	local _, _, w, h = assets.frames.angry:getViewport()
	sb:add(assets.frames.angry, self.position.x - w * 0.5, self.position.y - h * 0.5 - self.z)
end

return angry
