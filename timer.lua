local scene = require("scene")
local class = require("class")
local timer = class:extend()

function timer:new(time, timeout, ...)
	self.time = time
	self.save = time
	self.timeout = timeout or function() end
	self.disabled = false 
	self.args = {...}
	-- Attach to scene timers
	local t = scene.current.timers
	t[#t + 1] = self
end

function timer:update(dt)
	if self:is_out() and not self.disabled then
		self.disabled = true
		self.timeout(self, unpack(self.args))
	else
		self.time = self.time - dt
	end
end

function timer:reset(time)
	self.time = time or self.save
	self.disabled = false
end

function timer:stop()
	self.disabled = true
end

function timer:is_out()
	return self.time <= 0
end

return timer
