local scene = require("scene")
local assets = require("assets")
local timer = require("timer")
local splash = scene:extend()

local text = "ooichu stuff"

function splash:open()
	self.scale = 0.1
	self.max_scale = 2
	self.mult = 2
	self.amplitude = 10
	timer(4, function()
		self.mult = -self.mult * 2.3
	end)
	assets.sounds["splash.wav"]:play()
end

function splash:update(dt)
	self.scale = math.min(self.scale + self.mult * dt, self.max_scale)
	if self.scale <= 0 or start_pressed() then
		require("scenes.menu")()
	end
end

function splash:draw()
	-- Mess :P
	local half_text_width = assets.font:getWidth(text)
	local glyph_width = half_text_width / #text
	half_text_width = half_text_width * 0.5 
	love.graphics.translate(WIDTH / 2, HEIGHT / 2)
	for i = 1, #text do
		local val = math.sin(love.timer.getTime() * self.amplitude + i)
		local x = (i * glyph_width - half_text_width) * self.scale
		local y = val * 2.5 * self.scale
		local r = self.scale / self.max_scale * math.pi * 2 + math.cos(love.timer.getTime() * 8 + i) * 0.3
		local chr = text:sub(i, i)
		love.graphics.setColor(1, 1, 1, (1 - val * val) * 0.1)
		love.graphics.print(chr, x, 8,	r, self.scale, 1, 2, -5)
		love.graphics.setColor(0.9, 0.8, 0.2 + val^1.5)
		love.graphics.print(chr, x, y,	r, self.scale, self.scale, 2, 2.5)
	end
	local factor = self.scale / math.abs(self.mult)
	love.graphics.setColor(1, 1, 1, factor)
	love.graphics.print("Games", 0, self.amplitude * self.scale + 8, 0, 1, 1, 8 * self.scale, 2.5 * self.scale)
	love.graphics.setBackgroundColor(1, 1, 1, 1 - factor^math.pi)
end

function splash:close()
	love.audio.stop()
end

return splash
