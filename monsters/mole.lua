local monster = require("monsters.monster")
local level = require("level")
local assets = require("assets")
local animation = require("animation")
local object = require("object")
local mole = monster:extend()

mole.name = "mole"
mole.health = 3
mole.speed = 10
mole.shield = 2
mole.reward = 300

function mole:new(...)
	monster.new(self, ...)
	self.dig = animation(assets.frames.mole.dig)
end

function mole:update(dt)
	monster.update(self, dt)
	self.dig:update(dt)
end

function mole:ai(dt)
	if self.shield == 0 then
		self.speed = self:super().speed
		self:follow(80)
	else
		self.speed = self:super().speed * 3
		if not self:evade(100) then
			self.shield = 0
		end
	end
end

function mole:hurt(...)
	local hp = self.health
	monster.hurt(self, ...)
	if self.health ~= hp then
		self.shield = self.shield + 10
	end
end

function mole:draw(sb)
	if self.shield ~= 0 then
		object.draw(self)
		self.dig:draw(sb, self.position:unpack())
	else
		monster.draw(self, sb)
	end 
end

return mole

