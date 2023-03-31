local projectile = require("projectiles.projectile")
local assets = require("assets")
local animation = require("animation")
local bullet = projectile:extend()

bullet.damage = 1
bullet.lifetime = 3
bullet.speed = 85
bullet.radius = 1

function bullet:new(...)
	projectile.new(self, ...)
	self.animation = animation(assets.frames.bullet)
end

function bullet:update(dt)
	projectile.update(self, dt)
	self.animation:update(dt)
end

function bullet:draw(sb)
	projectile.draw(self, sb)
	self.animation:draw(sb, self.position:unpack())
end

return bullet
