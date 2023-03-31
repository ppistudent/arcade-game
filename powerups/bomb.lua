local powerup = require("powerups.powerup")
local level = require("level")
local assets = require("assets")
local animation = require("animation")
local vec2 = require("vec2")
local text = require("particles.text")
local bomb = powerup:extend()

local wave = require("particles.wave")

function bomb:new(...)
	powerup.new(self, ...)
	self.animation = animation(assets.frames.bomb)
end

function bomb:update(dt)
	self.animation:update(dt)
	powerup.update(self, dt)
end

function bomb:draw(sb)
	powerup.draw(self, sb)
	self.animation:draw(sb, self.position.x, self.position.y - self.z)
end

function bomb:pickup(player)
	for e in level.current:each("monsters") do
		if player:distance(e) <= 64 then
			e:kill()
		end
	end
	wave(64, player.position)
	wave(32, player.position)
	wave(16, player.position)
	level.current:shake_screen(0.2)
	text("BOOM!", self.position, vec2(0, -10)):style("yellow", "red")
end

return bomb
