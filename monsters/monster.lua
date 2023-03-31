local entity = require("entity")
local vec2 = require("vec2")
local level = require("level")
local animation = require("animation")
local timer = require("timer")
local tiles = require("assets.maps.tiles")
local assets = require("assets")
local monster = entity:extend()

local pufft = require("particles.pufft")
local heart = require("particles.heart")
local text = require("particles.text")

monster.category = "monsters"
monster.damping = 0.1

-- Monster properties
monster.shield = 0 
monster.reward = nil

function monster:new(...)
	entity.new(self, ...)
	self.stun_animation = animation(assets.frames.stun)
	self.wander_timer = nil 
end

function monster:spawn()
	entity.spawn(self)
	level.current.monsters_count = level.current.monsters_count + 1
end

function monster:despawn()
	entity.despawn(self)
	level.current.monsters_count = level.current.monsters_count - 1
	self:safe_set_state("dead")
end

local drop = {
	require("powerups.medikit"),
	require("powerups.bomb"),
	require("powerups.flash"),
  require("powerups.punch")
}

local directions = {
	vec2( 1,  0),
	vec2(-1,  0),
	vec2( 0,  1),
	vec2( 0, -1)
}

function monster:destroy()
	entity.destroy(self)
	for i = 1, 4 do
		pufft(self.position, vec2(math.pi * (i * 0.5 + 0.25)) * 20, love.math.random(8))
	end
	if self.wander_timer ~= nil then
		self.wander_timer:stop()
	end
	if love.math.random(100) < level.current.drop_chance then
		drop[love.math.random(#drop)](self.position)
	end
	text(self.reward, self.position, vec2(0, -20)):style("white", "black")	
	level.current:add_score(self.reward)
	assets.sounds["destroy.wav"]:clone():play()
end

function monster:update(dt)
	if self.state == "idle" or self.state == "moving" and self.z == 0 then
		if self.smacked_on_wall then
			self.direction = vec2(
				self.smacked_on_wall_x and -self.direction.x or self.direction.x,
				self.smacked_on_wall_y and -self.direction.y or self.direction.y)
		end
		self:ai(dt)
	elseif self.state == "thrown" and self.smacked_on_wall then
		self:despawn()
	elseif self.state == "stunned" then
		self.stun_animation:update(dt)
	else
		self.stun_animation:reset()
	end
	entity.update(self, dt)
end

function monster:draw(sb)
	entity.draw(self, sb)
	if self.state == "stunned" then
		self.stun_animation:draw(sb, self.position.x, self.position.y - self.z - self.radius * 1.5)
	end
end

function monster.detect_player()
	return level.current.players[1]
end

function monster:follow(range)
	if #level.current.players ~= 0 then
		local player = self.detect_player()
		local to = player.position - self.position
		local len = to:len()
		if len <= range then
			self:move(to / len)
			return true
		end
	end
	return false
end

function monster:evade(range)
	if #level.current.players ~= 0 then
		local player = self.detect_player()
		local to =  self.position - player.position
		local len = to:len()
		if len <= range then
			self:move(to / len)
			return true
		end
	end
	return false
end

function monster.wander_timeout(timer, self)
	self.direction = math.lerp(self.direction, vec2(love.math.random() * math.pi * 2), 0.8)
	timer:reset()
end

function monster:wander(t)
	if self.wander_timer == nil then
		self.wander_timer = timer(t, self.wander_timeout, self)
	end
	self:move(self.direction)
end

function monster:ai(dt)
	error("monster ai not implemented")
end

--
-- Monster reactions functions
--

local function bump(a, b)
	if a.state ~= "thrown" and a.state ~= "dead" then
		a:hurt(1)
	end
	if b.state ~= "thrown" and b.state ~= "dead" then
		b:hurt(1)
	end
end

local function summon(a, b)
	a:safe_set_state("idle")
	b:safe_set_state("idle")
	local mid_pos = math.lerp(a.position, b.position, 0.5)
	heart(mid_pos - 2, vec2(-5, 0))
	heart(mid_pos)
	heart(mid_pos + 2, vec2(5, 0))
  a:hurt(0.5)
  b:hurt(0.5)
	level.current:message("Summon! +50", "red")
	level.current:add_score(50)
	return (math.random(-10, 10) > 0 and a:super() or b:super())(mid_pos)
end

local function morph(to)
	return function(a, b)
		a:despawn()
		b:despawn()
		level.current:message("Morph! +150", "green")
		level.current:add_score(150)
		require(to)((a.position + b.position) * 0.5)
	end 
end

local function eat(a, b)
	a:despawn()
	b.health = b.health + 1
	level.current:message("Eat! +200", "red")
	level.current:add_score(200)
end

local function absorb(a, b)
	a.health = a.health + 1
	b:despawn()
	level.current:message("Absorb! +200", "red")
	level.current:add_score(200)
end

--
-- Monster reactions table
--

local collide_table = {
	meatboy = {
		meatboy = summon,
		oneye   = bump,
		fred    = bump,
		woise   = bump,
		bat     = eat,
		mole    = eat,
		gob     = bump
	},
	oneye = {
		meatboy = bump,
		oneye   = morph("monsters.woise"),
		fred    = bump,
		woise   = summon,
		bat     = bump,
		mole    = bump,
		gob     = absorb,
	},
	fred = {
		meatboy = bump,
		oneye   = bump,
		fred    = bump,
		woise   = bump,
		bat     = eat,
		mole    = bump,
		gob     = bump
	},
	woise = {
		meatboy = bump,
		oneye   = summon,
		fred    = bump,
		woise   = morph("monsters.oneye"),
		bat     = bump,
		mole    = bump,
		gob     = bump
	},
	bat = {
		meatboy = bump,
		oneye   = bump,
		fred    = absorb,
		woise   = bump,
		bat     = summon,
		mole    = bump,
		gob     = eat 
	},
	mole = {
		meatboy = bump,
		oneye   = bump,
		fred    = absorb,
		woise   = bump,
		bat     = bump,
		mole    = bump,
		gob     = bump
	},
	gob = {
		meatboy = bump,
		oneye   = bump,
		fred    = bump,
		woise   = bump,
		bat     = absorb,
		mole    = bump,
		gob     = morph("monsters.meatboy")
	}
}

function monster.throw_timeout(timer, self)
	entity.throw_timeout(timer, self)
	self:despawn()
end

function monster.reaction(a, b)
	collide_table[a.name][b.name](a, b)
end

return monster
