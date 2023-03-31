local monster = require("monsters.monster")
local level = require("level")
local vec2 = require("vec2")
local bullet = require("projectiles.bullet")
local timer = require("timer")
local gob = monster:extend()

local wave = require("particles.wave")

gob.name = "gob"
gob.health = 1
gob.speed = 10
gob.reward = 500

local function teleport_timeout(timer, self)
	if not self.wandering then
		wave(4, self.position, 4)
		local x = love.math.random(32, 64) * love.math.random(-1, 1)
		local y = love.math.random(32, 64) * love.math.random(-1, 1)
		if x ~= 0 or y ~= 0 then
			self.position = vec2(x, y)
		end
		self.wandering = true
	end
	timer:reset()
end

function gob:new(...)
	monster.new(self, ...)
	self.teleport_timer = timer(5, teleport_timeout, self)
	self.wandering = true
end

function gob:destroy()
	monster.destroy(self)
	if self.teleport_timer ~= nil then
		self.teleport_timer:stop()
	end
end

function gob.wander_timeout(timer, self)
	monster.wander_timeout(timer, self)
	self.wandering = not self.wandering
	bullet(self.position, self.direction)
end

function gob:ai(dt)
	if self.wandering then
		self:wander(2)
	end
end

return gob
