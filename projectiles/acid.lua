local projectile = require("projectiles.projectile")
local acid = projectile:extend()

acid.damage = 1
acid.lifetime = 4
acid.lifetime_variancy = 1
acid.speed = 0
acid.damping = 0

function acid:new(...)
	projectile.new(self, ...)
	self.radius = self.lifetimer.time
end

function acid:update(dt)
	projectile.update(self, dt)
	self.radius = self.lifetimer.time
	if self.radius <= 1 then
		self:despawn()
	end
end

function acid:draw()
	love.graphics.setColor("black")
	love.graphics.circle("fill", self.position.x, self.position.y, self.radius + 1)
	love.graphics.setColor("green")
	love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
	love.graphics.setColor("white")
	local r = self.radius * 0.25
	love.graphics.circle("fill", self.position.x - r * 1.5, self.position.y - r * 1.5, r)
end

return acid
