local scene = require("scene")
local assets = require("assets")
local background_effect = require("background_effect")
local prelude = scene:extend():implement(background_effect)

local characters = {
	require("players.mike"),
	require("players.robot"),
	require("players.shad")
}

local levels = {
	require("levels.classic"),
	require("levels.terra"),
	require("levels.metal")
}

function prelude:open()
	self.cursor = 1
	self.cursor_y = 0
	self.pressed = true
	self.character_selected = false
	self:init_dots()
end

function prelude:update(dt)
	self:update_dots(dt)
	if up_pressed() then
		if not self.pressed then
			self.cursor = math.max(1, self.cursor - 1)
			self.pressed = true
			assets.sounds["select.wav"]:clone():play()
		end
	elseif down_pressed() then
		if not self.pressed then
			self.cursor = math.min((self.character_selected and #levels or #characters) + 1, self.cursor + 1)
			self.pressed = true
			assets.sounds["select.wav"]:clone():play()
		end
	elseif start_pressed() then
		if not self.pressed then
			if self.character_selected then
				if self.cursor <= #levels then
					if HIGHSCORE >= levels[self.cursor].require_score then
						levels[self.cursor](self.character)
					end
				else
					self.character_selected = false
				end
			else
				local c = characters[self.cursor]
				if self.cursor > #characters then
					require("scenes.menu")()
				elseif c.require_score <= HIGHSCORE then
					self.character = c
					self.character_selected = true
					self.cursor = 1
				end
			end
			self.pressed = true
			assets.sounds["select.wav"]:clone():play()
		end
	else
		self.pressed = false
	end
	self.cursor_y = math.lerp(self.cursor_y, self.cursor * 14, 10 * dt)
end

local function draw_back_button(self, i)
	local active = self.cursor == i
	if active then
		love.graphics.setColor("blue")
		love.graphics.rectangle("fill", 0, self.cursor_y - 2, WIDTH, 12)
	end
	love.graphics.setColor("black")
	love.graphics.print("Back", 20, i * 14 + 2)
	love.graphics.setColor(active and "white" or "violet")
	love.graphics.print("Back", 20, i * 14 + 1)
end

function prelude:draw()
	self:draw_dots()
	love.graphics.setColor("yellow")
	local text = self.character_selected and "Select level" or "Select character" 
	love.graphics.print(text, HALF_WIDTH - assets.font:getWidth(text), 9, 0, 2, 2)
	love.graphics.push()
	love.graphics.translate(0, HALF_HEIGHT * 0.3)
	if self.character_selected then
		love.graphics.translate(0, HALF_HEIGHT * 0.05)
		for i = 1, #levels do
			local active = self.cursor == i
			if active then
				love.graphics.setColor("blue")
				love.graphics.rectangle("fill", 0, self.cursor_y - 12, WIDTH, 12)
			end
			local s = HIGHSCORE >= levels[i].require_score and levels[i].map:gsub("^%l", string.upper) or ("Require %i score"):format(levels[i].require_score)
			love.graphics.setColor("black")
			love.graphics.print(s, 20, i * 14 - 8)
			love.graphics.setColor(active and "white" or "violet")
			love.graphics.print(s, 20, i * 14 - 9)
		end
		love.graphics.translate(0, -11)
		draw_back_button(self, #levels + 1)
	else
		love.graphics.translate(0, -4)
		for i = 1, #characters do
			local c = characters[i]
			local active = self.cursor == i
			local unlocked = c.require_score <= HIGHSCORE
			if active then
				love.graphics.setColor("blue")
				love.graphics.rectangle("fill", 0, self.cursor_y - 2, WIDTH, 12)
			end
			if unlocked then
				love.graphics.setColor(1, 1, 1)
			else
				love.graphics.setColor(0, 0, 0)
			end
			love.graphics.draw(assets.images["spritesheet.png"], assets.frames[c.name].idle[1], 4, i * 14)
			love.graphics.setColor("black")	
			local name = unlocked and c.name:gsub("^%l", string.upper) or ("Require %i score"):format(c.require_score)
			love.graphics.print(name, 20, i * 14 + 2)
			love.graphics.setColor(active and "white" or "violet")
			love.graphics.print(name, 20, i * 14 + 1)
		end	
		love.graphics.translate(0, -2)
		draw_back_button(self, #characters + 1)
		if self.cursor <= #characters and characters[self.cursor].require_score <= HIGHSCORE then
			love.graphics.translate(0, HALF_HEIGHT)
			love.graphics.setColor("violet")
			love.graphics.rectangle("fill", 3, -1, WIDTH - 8 + 2, HALF_HEIGHT * 0.7 + 3)
			local c = characters[self.cursor]
			local s = ("Health: %g\nSpeed: %g\nPower: %g\nCoverage: %s%%\nRange: %g\nCapacity: %g\nReload: %g\nStunning: %g"):format(c.health, c.speed, c.power, tostring(math.floor(100 * c.coverage / (math.pi * 2) + 0.5)), c.range, c.capacity, c.reload, c.stunning)
			love.graphics.setColor("black")
			love.graphics.printf(s, 4 + 1, 0 + 1, WIDTH - 8, "justify")
			love.graphics.setColor("white")
			love.graphics.printf(s, 4, 0, WIDTH - 8, "justify")
		end
	end
	love.graphics.pop()
end

return prelude
