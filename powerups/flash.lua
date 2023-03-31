local powerup = require("powerups.powerup")
local level = require("level")
local assets = require("assets")
local animation = require("animation")
local vec2 = require("vec2")
local text = require("particles.text")
local flash = powerup:extend()

function flash:new(...)
	powerup.new(self, ...)
	self.animation = animation(assets.frames.flash)
end

function flash:update(dt)
	self.animation:update(dt)
	powerup.update(self, dt)
end

function flash:draw(sb)
	powerup.draw(self, sb)
	self.animation:draw(sb, self.position.x, self.position.y - self.z)
end

function flash:pickup(player)
	for e in level.current:each("monsters") do
		e:stun(2)
	end
	flash_screen(1)
	text("FLASH!", self.position, vec2(0, -10)):style("white", "blue")
end

return flash
