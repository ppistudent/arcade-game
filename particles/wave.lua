local particle = require("particles.particle")
local wave = particle:extend()

wave.lifetime = math.huge -- Crutch :P
wave.damping = 0 

function wave:new(rad, ...)
	particle.new(self, ...)
	self.max_radius = rad
	self.radius = 0
end

function wave:update(dt)
	particle.update(self, dt)
	self.radius = (self.radius + (self.radius + self.max_radius) * dt)
	if self.radius >= self.max_radius then
		self:despawn()
	end
end 

function wave:draw()
	love.graphics.setColor(math.floor(love.timer.getTime() * 8) % 2 == 0 and "yellow" or "red")
	love.graphics.circle("line", self.position.x, self.position.y - self.z, self.radius)
end

return wave
