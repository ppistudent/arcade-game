local particle = require("particles.particle")
local assets = require("assets")
local text = particle:extend()
	
text.fg_color = "white"
text.bg_color = nil
text.lifetime = 3
text.damping = 1

function text:new(text, ...)
	particle.new(self, ...)
	self.text = text
end

function text:style(fg, bg)
	self.fg_color = fg
	self.bg_color = bg
end

function text:draw()
	local x = self.position.x - assets.font:getWidth(self.text) * 0.5
	local y = self.position.y - assets.font:getHeight() * 0.5
	if self.bg_color then
		love.graphics.setColor(self.bg_color)
		love.graphics.print(self.text, x - 1, y)
		love.graphics.print(self.text, x, y - 1)
		love.graphics.print(self.text, x + 1, y)
		love.graphics.print(self.text, x, y + 1)
	end
	love.graphics.setColor(self.fg_color)
	love.graphics.print(self.text, x, y)
end

return text
