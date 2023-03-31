local monster = require("monsters.monster")
local level = require("level")
local bat = monster:extend()

bat.name = "bat"
bat.health = 1
bat.speed = 10
bat.reward = 200

function bat:new(...)
	monster.new(self, ...)
	self.target_selected = false
end

function bat.wander_timeout(timer, self)
	monster.wander_timeout(timer, self)
	self.target_selected = not self.target_selected 
end

function bat:ai(dt)
	if not self.target_selected or not self:follow(60) then
		self:wander(3)
	end
end

return bat
