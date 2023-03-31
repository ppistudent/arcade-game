local class = require("class")
local animation = class:extend()

--- Конструктор анимации
function animation:new(frames, duration)
	self.frames = frames
	self.duration = duration or 1
	self:reset()
end

--- Сброс анимации
function animation:reset()
	self.counter = 0
end

--- Обновить анимацию 
function animation:update(dt)
	self.counter = self.counter + dt
	if self.counter >= self.duration then
		self.counter = self.counter % self.duration
		return true
	end
	return false
end

-- Отрисовать анимацию
function animation:draw(sb, x, y, r, sx, sy, ox, oy, ...)
	local frame = self.frames[math.floor(self.counter / self.duration * #self.frames) + 1]
	local _, _, w, h = frame:getViewport()
	sb:add(frame, x, y, r, sx, sy, (ox or 0) + w * 0.5, (oy or 0) + h * 0.5, ...)
end

return animation
