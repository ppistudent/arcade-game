local powerup = require("powerups.powerup")
local assets = require("assets")
local animation = require("animation")
local text = require("particles.text")
local vec2 = require("vec2")
local medikit = powerup:extend()

function medikit:new(...)
	powerup.new(self, ...)
	self.animation = animation(assets.frames.medikit)
end

function medikit:update(dt)
	self.animation:update(dt)
	powerup.update(self, dt)
end

function medikit:draw(sb)
	powerup.draw(self, sb)
	self.animation:draw(sb, self.position.x, self.position.y - self.z)
end

function medikit:pickup(player)
	player.health = player.health + 1
	text("HP up!", self.position, vec2(0, -10)):style("white", "red")
end

return medikit
