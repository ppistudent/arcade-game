local class = require("class")
local vec2 = require("vec2")
local level = require("level")
local object = class:extend()

-- Object properties
object.category = nil
object.radius = 4
object.height = 4
object.damping = 0
object.solid = false

--- Конструктор объекта
function object:new(position, velocity_or_z, z)
	assert(class.is(level.current, level), "Attempt to create object on not a level scene")
	self.position = position or vec2()
	if type(velocity_or_z) == "number" then
		self.velocity = vec2()
		self.z = velocity_or_z
	else
		self.velocity = velocity_or_z or vec2()
		self.z = z or 0
	end 
	self.drift = vec2()
	self.direction = vec2(1, 0)
	self.radius = self.radius
	self.height = self.height
	self.damping = self.damping
	self:spawn()
end

--- Заспавнить объект
function object:spawn()
	level.current:insert(self.category, self)
end

--- Деспавнить объект
function object:despawn()
	level.current:remove(self)
end

--- Действие при уничтожении объекта
function object:destroy()
	-- Optional
end

local function is_solid(tile)
	return tile ~= nil and tile.solid
end

local function has_damping(tile)
	return tile ~= nil and tile.damping
end

--- Обновить объект
function object:update(dt)
	if self.velocity:len2() ~= 0 then
		self.direction = math.lerp(self.direction, self.velocity:normalize(), 8 * dt)
	end
--[[
	if self.solid then
		-- Check damping
		do
			local tile = level.current:look_range(
				self.position.x - self.radius,
				self.position.y - self.radius,
				self.position.x + self.radius,
				self.position.y + self.radius,
				has_damping)
			if tile ~= nil then
				self.velocity = self.velocity * tile.damping
			end
		end
		-- Check solid tiles
		local offset = self.drift + self.velocity * dt
		local num_steps = math.floor(offset:len() + 1)
		local step = offset / num_steps
		for i = 1, num_steps do
			local x0 = self.position.x - self.radius
			local y0 = self.position.y - self.radius
			local x1 = self.position.x + self.radius
			local y1 = self.position.y + self.radius
			-- Check for x-axis
			if not level.current:look_range(x0 + step.x, y0, x1 + step.x, y1, is_solid) then
				self.position.x = self.position.x + step.x
			end
			-- Check for y-axis
			if not level.current:look_range(x0, y0 + step.y, x1, y1 + step.y, is_solid) then
				self.position.y = self.position.y + step.y
			end
		end
	else
--]]
		self.position = self.position + self.drift + self.velocity * dt 
--	end
	self.velocity = self.velocity * self.damping
	self.drift = vec2()
	self.z = math.max(0, self.z - level.current.gravity * dt)
end

--- Отрисовать объект
function object:draw()
	-- Draw shadow
	love.graphics.setColor("black")
	love.graphics.circle("fill", self.position.x, self.position.y + self.radius, self.radius)
	-- TODO: remove it
	if DEBUG then
		love.graphics.setColor(1, 0, 1)
		love.graphics.circle("line", self.position.x, self.position.y, self.radius)
	end
end

--- Вычислить расстояние между объектами
function object.distance(a, b)
	return math.max(0, (b.position - a.position):len() - a.radius - b.radius)
end

--- Проверить два объекта на столкновения
function object.collided(a, b)
	local r = a.radius + b.radius
	return (a.position - b.position):len2() <= r * r
end

--- Разрешить столкновение
function object.rigid_collision(a, b)
	local direction = b.position - a.position
	local length = direction:len()
	if length == 0 then
		direction = vec2(1, 0)
		length = 1
	end
	-- Solve collision
	direction = direction / length * (a.radius + b.radius - length) * 0.5
	a.drift = a.drift - direction
	b.drift = b.drift + direction
end

return object
