return {
	init_dots = function(self, n, speed)
		self.dots_x = {}
		self.dots_y = {}
		self.dots_z = {}
		self.dots_n = n or 200
		for	i = 1, self.dots_n do
			self.dots_x[#self.dots_x + 1] = love.math.random(-HALF_WIDTH, HALF_WIDTH)
			self.dots_y[#self.dots_y + 1] = love.math.random(-HALF_HEIGHT, HALF_HEIGHT)
			self.dots_z[#self.dots_z + 1] = love.math.random() * 3
		end
	end,
	update_dots = function(self, dt)
		local s = math.sin(0.5 * dt)
		local c = math.cos(0.5 * dt)
		for	i = 1, self.dots_n do
			local x = self.dots_x[i] 
			local y = self.dots_y[i] 
			self.dots_x[i], self.dots_y[i] = x * c - y * s, x * s + y * c
			self.dots_z[i] = self.dots_z[i] - dt
			if self.dots_z[i] <= 0 then
				self.dots_z[i] = love.math.random() * 3
			end 
		end
	end,
	draw_dots = function(self)
		love.graphics.setColor("violet")
		love.graphics.push()
		love.graphics.translate(HALF_WIDTH, HALF_HEIGHT)
		for	i = 1, self.dots_n do
			love.graphics.points(self.dots_x[i] / self.dots_z[i], self.dots_y[i] / self.dots_z[i])
		end
		love.graphics.pop()
	end
}
	
