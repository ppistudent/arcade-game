local powerup = require("powerups.powerup")
local assets = require("assets")
local animation = require("animation")
local text = require("particles.text")
local vec2 = require("vec2")
local punch = powerup:extend()

function punch:new(...)
	powerup.new(self, ...)
	self.animation = animation(assets.frames.punch)
end

function punch:update(dt)
	self.animation:update(dt)
	powerup.update(self, dt)
end

function punch:draw(sb)
	powerup.draw(self, sb)
	self.animation:draw(sb, self.position.x, self.position.y - self.z)
end

function punch:pickup(player)
  player:activate_punch()
	text("Punch!", self.position, vec2(0, -10)):style("white", "blue")	
end

return punch
