local level = require("level")
local assets = require("assets")
local vec2 = require("vec2")
local timer = require("timer")
local menu = require("scenes.menu")
local tutorial = level:extend()

local mike = require("players.mike")
local oneye = require("monsters.oneye")
local meatboy = require("monsters.meatboy")

tutorial.spawn_variation = 0
tutorial.spawn_rate = 0
tutorial.spawn_count = 0
tutorial.spawn_count_max = 0
tutorial.spawn_growth_factor = 0
tutorial.max_monsters_count = 3
tutorial.map = "tutorial" 
tutorial.monsters_available = {}

local steps = {
	{
		label = "1.'%s','%s','%s' and '%s' for movement",
		format = function()
			return "up/w", "left/a", "down/s", "right/d"
		end
	},
	{
		label = "2. Press '%s' to push and '%s' to pull",
		format = function()
			return "z/k", "x/l"
		end
	},
	{
		label = "3. Pull monster and push it out"
	},
	{
		label = "4. Try to bump monsters"
	},
	{
		label = "5. Top right column indicates arena fillness. You will lose\nif that column is full and\ntimer was out."
	},
	{
		label = "6. Now you ready for battle!"
	}
}

function tutorial.spawn_timeout(timer, self)
	-- Nothing
end

function tutorial:new()
	self.step = 1
	level.new(self, mike)
end

function tutorial:open()
	level.open(self)
	self.players[1].health = 999
end

local steps_vtable = {
	[1] = function(self, dt)
		self.key_up = self.key_up or up_pressed()
		self.key_down = self.key_down or down_pressed()
		self.key_left = self.key_left or left_pressed()
		self.key_right = self.key_right or right_pressed()
		if self.key_up and self.key_down and self.key_left and self.key_right then
			self.step = self.step + 1
			self.key_up = nil
			self.key_down = nil
			self.key_left = nil
			self.key_right = nil
		end
	end,
	[2] = function(self, dt)
		self.key_a = self.key_a or a_pressed()
		self.key_b = self.key_b or b_pressed()
		if self.key_a and self.key_b then
			meatboy(self.players[1].position + vec2(love.math.random() * math.pi * 2) * 32, 15)
			self.step = self.step + 1
			self.key_a = nil
			self.key_b = nil
		end
	end,
	[3] = function(self, dt)
		if #self.monsters == 0 and #self.players[1].tank == 0 then
			self.step = self.step + 1
			local v = vec2(love.math.random() * math.pi * 2)
			meatboy(self.players[1].position + v * 32, 15)
			oneye(self.players[1].position - v * 32, 15)
		end
	end,
	[4] = function(self, dt)
		if #self.monsters == 0 and #self.players[1].tank == 0 then
			self.step = self.step + 1
		end
	end,
	[5] = function(self, dt)
		if not self.block then
			self.block = true
			timer(7, function(timer, self)
				self.step = self.step + 1
				self.block = false
			end, self)
		end
	end,
	[6] = function(self, dt)
		if not self.block then
			TUTORIAL = false
			self.block = true
			timer(3, function(timer, self)
				self.step = self.step + 1
				self.block = false
			end, self)
		end
	end,
	[7] = function()
    love.audio.stop()
    menu()
  end
}

function tutorial:update(dt)
	level.update(self, dt)
	steps_vtable[self.step](self, dt)
end 

function tutorial:draw()
	level.draw(self)
	local step = steps[self.step]
	if step.format ~= nil then
		step = step.label:format(step.format())
	else
		step = step.label
	end
	love.graphics.setColor("black")
	love.graphics.printf(step, 4 - 1, 16, WIDTH - 8, "left")
	love.graphics.printf(step, 4 + 1, 16, WIDTH - 8, "left")
	love.graphics.printf(step, 4, 16 - 1, WIDTH - 8, "left")
	love.graphics.printf(step, 4, 16 + 1, WIDTH - 8, "left")
	love.graphics.setColor("white")
	love.graphics.printf(step, 4, 16, WIDTH - 8, "left")
end

return tutorial
