local entity = require("entity")
local level = require("level")
local vec2 = require("vec2")
local assets = require("assets")
local timer = require("timer")
local player = entity:extend()

local dust = require("particles.dust")

player.category = "players"

-- Don't touch
player.shield = 1
player.absorb_distance = 2.5

-- Player properties
player.power = nil
player.coverage = nil
player.range = nil
player.capacity = nil
player.reload = nil
player.stunning = nil
player.require_score = nil -- XXX: must be set!!!
player.radius = 3

function player:new(...)
	assert(#level.current[self.category] == 0, "Attempt to create player, but it already created")
	entity.new(self, ...)
	self.tank = {}
	self.mode = "nope"
	self.reload = 0
end

local MAGIC = 0.01

local function make_dust(self, vel, n)
	local dir_angle = self.direction:angle()
	local half_coverage_mul_10 = self.coverage * 50
	for i = 1, n do
		local direction = vec2(dir_angle + love.math.random(-half_coverage_mul_10, half_coverage_mul_10) * 0.01)
		dust(self.position + direction * (self.absorb_distance + love.math.random(self.absorb_distance, self.range)), direction * (60 * vel))
	end
end

local function shot_monster(self, dir)
  local n = #self.tank
  local e = self.tank[n]
  self.tank[n] = nil
  e:new(self.position + dir * (self.radius + e.radius + 1))
  e:throw(self.power * MAGIC, dir * self.power)
  self.reload = self:super().reload
end

local vtable_shot_monster = {
  [1] = function(self) shot_monster(self, self.direction) end,
  [2] = function(self)
    shot_monster(self, self.direction)
    shot_monster(self, -self.direction)
  end,
  [3] = function(self)
    shot_monster(self, self.direction)
    local p = self.direction:perpend()
    shot_monster(self, p)
    shot_monster(self, -p)
  end,
  [4] = function(self)
    local p = self.direction
    shot_monster(self, p)
    shot_monster(self, -p)
    local p = self.direction:perpend()
    shot_monster(self, p)
    shot_monster(self, -p)
  end
}

function player:activate_punch()
  if self.punch_timer then self.punch_timer:stop() end
  self.punch_timer = timer(6, function()
    self.punch_timer = nil
  end)
end

function player:update(dt)
	-- Save direction
	local old_direction = self.direction
	-- Update actions
	self.speed = self:super().speed * 0.8
  if a_pressed() then
  	assets.sounds["pushpull.wav"]:play()
  	self.mode = "pull"
  	make_dust(self, 1, 3)
    old_direction = LOCK and old_direction or nil
  elseif b_pressed() and #self.tank < self.capacity then
  	assets.sounds["pushpull.wav"]:play()
  	self.mode = "push"
  	make_dust(self, -1, 3)
    old_direction = LOCK and old_direction or nil
  else
  	self.mode = "nope"
  	self.speed = self:super().speed
    old_direction = nil
  end
  if self.reload == 0 then
  	if self.mode == "pull" and #self.tank > 0 then
      if self.quadro_shots then
        vtable_shot_monster[math.min(#self.tank, 4)](self)
      else
        shot_monster(self, self.direction)
      end
  	end
  else
  	self.reload = math.max(self.reload - dt, 0)
  end
	-- Update movement
  if self.punch_timer then
  	self:move(
  		left_pressed() and -1.3 or right_pressed() and 1.3 or 0,
  		up_pressed() and -1.3 or down_pressed() and 1.3 or 0
  	)
  else
  	self:move(
  		left_pressed() and -1 or right_pressed() and 1 or 0,
  		up_pressed() and -1 or down_pressed() and 1 or 0
  	)
  end
	-- Update entity
	entity.update(self, dt)
	-- Restore old direction
	if old_direction then
		self.direction = old_direction
		self.look = math.sign(self.direction.x)
	end
end

function player:draw(sb)
	-- Draw sprite
  if not self.punch_timer or math.floor((self.punch_timer.time * 100) % 3) == 0 then
	  entity.draw(self, sb)
  end
	-- Draw cone
  love.graphics.setColor("violet", 0.75)
  local begin_angle = self.direction:angle() - self.coverage * 0.5
  local end_angle = begin_angle + self.coverage
  love.graphics.arc("line", self.position.x, self.position.y, self.range, begin_angle, end_angle)
  love.graphics.setColor("violet", 0.75)
  love.graphics.arc("fill", self.position.x, self.position.y, self.range, begin_angle, end_angle)
  -- Draw reload
  if self.reload ~= 0 then
  	local x = self.position.x - self.radius
  	local w = self.radius * 2
  	local y = self.position.y - w
  	love.graphics.setColor("black")
  	love.graphics.rectangle("fill", x, y, w, 1)
  	love.graphics.setColor("red")
  	love.graphics.rectangle("fill", x, y, (self.reload / self:super().reload) * w, 1)
  end
  if (b_pressed() or a_pressed()) and LOCK then
  	local x = self.position.x - 4
    local y = self.position.y - 16 
    love.graphics.setColor(1, 1, 1)
	  love.graphics.draw(assets.images["spritesheet.png"], assets.frames.lock, x, y)
  end
	if DEBUG then
		love.graphics.setColor(1, 0, 0)
		love.graphics.circle("line", self.position.x, self.position.y, self.radius + self.absorb_distance)
	end
end

function player:hurt(...)
	entity.hurt(self, ...)
	level.current:shake_screen(0.5)
end

function player:destroy()
	entity.destroy(self)
	level.current:game_over()
end

local function test(self, point, min, max)
	local a = (point - self.position):angle()
	return min <= a and a <= max
end

function player:should_absorb(e)
	return self.mode == "push" and #self.tank < self.capacity and self:distance(e) <= self.absorb_distance
end

function player:absorb(e)
	self.tank[#self.tank + 1] = e
	e:despawn()
	assets.sounds["absorb.wav"]:clone():play()
end

function player:pull(m)
	local to = m.position - self.position
	local len = to:len()
	m.velocity = m.velocity - to * ((1.5 - len / self.range) * self.power / len)
end
	
function player:push(m)
	local to = m.position - self.position
	local len = to:len()
	m.velocity = -m.velocity + to * ((1.5 - len / self.range) * self.power / len) * 2
	m:stun(self.stunning)
end

function player:reachable(e)
	local dir = self.direction:angle()
	local distance = self:distance(e)
	if distance < 1 then
		return true
	elseif distance <= self.range then
		local min = dir - self.coverage * 0.5
		local max = min + self.coverage
		local xrad = vec2(e.radius, 0)
		local yrad = vec2(0, e.radius)
		return
		   test(self, e.position - xrad, min, max)
		or test(self, e.position + xrad, min, max)
		or test(self, e.position - yrad, min, max)
		or test(self, e.position + yrad, min, max)
	end
	return false
end

return player
