local object = require("object")
local assets = require("assets")
local animation = require("animation")
local timer = require("timer")
local level = require("level")
local class = require("class")
local vec2 = require("vec2")
local entity = object:extend()

local possible_states = {
	"idle", "moving", "thrown", "stunned", "dead"
}

-- Entity properties
entity.name = nil
entity.health = nil
entity.speed = nil
entity.shield = 0
entity.solid = false

--- Конструктор сущности
function entity:new(...)
	object.new(self, ...)
	-- Animation state 
	self.state = "idle" 
	self.animations = {}
	for i = 1, #possible_states do
		local state = possible_states[i]
		self.animations[state] = animation(assets.frames[self.name][state])
	end
	self.look = 1
	-- Bind attributes
	self.speed = self.speed
	self.health = self.health
	self.shield = 0
	self.timer = nil
	self.smacked_on_wall = false
	self.smacked_on_wall_x = false
	self.smacked_on_wall_y = false
end

--- Метод обновления сущности
function entity:update(dt)
	-- Reset state, if needed
	if self.state == "moving" and self.velocity:len2() == 0 then
		self.state = "idle"
	end
	-- Update animation
	if self.animations[self.state]:update(dt) and self.state == "dead" then
		self:despawn()
	end
	-- Update object
	if self.state == "thrown" then
		self.velocity = self.constant_velocity
	end
	-- Update physics
	object.update(self, dt)
	-- Clamp position into level dimensions
	local dimensions = level.current.dimensions
	if self.position.x <= self.radius or self.position.x >= dimensions.x - self.radius then
		self.position.x = math.clamp(self.position.x, self.radius, dimensions.x - self.radius)
		self.smacked_on_wall_x = true
	else
		self.smacked_on_wall_x = false
	end
	if self.position.y <= 0 or self.position.y >= dimensions.y - self.radius * 2 then
		self.position.y = math.clamp(self.position.y, 0, dimensions.y - self.radius * 2)
		self.smacked_on_wall_y = true
	else
		self.smacked_on_wall_y = false
	end
	self.smacked_on_wall = self.smacked_on_wall_x or self.smacked_on_wall_y
	-- Update shield
	if self.shield > 0 then
		self.shield = self.shield - dt
	else
		self.shield = 0
	end
end

--- Метод отрисовки сущности
function entity:draw(sb)
	object.draw(self)
	if self.shield == 0 or math.floor(self.shield * 8) % 2 == 0 then
		self.animations[self.state]:draw(sb, self.position.x, self.position.y - self.z, (self.state == "thrown" or self.z ~= 0) and love.timer.getTime() * 10 or 0, self.look, 1)
	end
end

--- Установка состояния со сбросом таймера
function entity:safe_set_state(state)
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
	self.state = state
end

--
-- Actions
--

local function return_to_idle(timer, self)
	self.state = "idle"
end

entity.throw_timeout = return_to_idle
entity.stun_timeout = return_to_idle

--- Передвинуть сущность
function entity:move(x, y)
	if self.state == "idle" or self.state == "moving" then
		local v = class.is(x, vec2) and x or vec2(x, y)
		if v:len2() ~= 0 then
			if v.x ~= 0 then
				self.look = math.sign(v.x)
			end
			self.velocity = self.velocity + v * self.speed
			self.state = "moving"
		end
	end
end


--- Бросить сущность в направлении
function entity:throw(t, velocity)
	if self.state == "idle" or self.state == "moving" then
		self.state = "thrown"
		self.velocity = vec2()
		self.constant_velocity = velocity
		self.timer = timer(t, self.throw_timeout, self)
	end
end

--- Оглушить сущность
function entity:stun(t)
	if self.state == "idle" or self.state == "moving" then
		self.state = "stunned"
		self.velocity = vec2()
		self.timer = timer(t, self.stun_timeout, self)
	end
end

--- Нанести урон сущности
function entity:hurt(v)
	if self.shield == 0 then
		self.health = math.max(0, self.health - v)
		assets.sounds["hurt.wav"]:clone():play()
		if self.health == 0 then
			self.state = "dead"
		else
			self.shield = self:super().shield 
		end
	end
end

--- Вылечить сущность
function entity:heal(v)
	self.health = math.min(self.health + v, self:super().health)
end

--- Уничтожить сущность
function entity:kill()
	self:safe_set_state("dead")
	self.velocity = vec2()
end

return entity
