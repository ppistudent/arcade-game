local scene = require("scene")
local camera = require("camera")
local assets = require("assets")
local vec2 = require("vec2")
local timer = require("timer")
local tiles = require("assets.maps.tiles")
local level = scene:extend()

-- XXX: dirtiest code of whole project 
level.gravity = 20

-- Level properties
level.spawn_variation = nil
level.spawn_count = nil
level.spawn_count_max = nil 
level.spawn_growth_factor = nil
level.spawn_rate = nil
level.monsters_count = nil
level.max_monsters_count = nil
level.map = nil
level.require_score = nil
level.monsters_available = nil
level.monsters_probability = nil -- table of #monsters_available elements with 0-100 numbers (%)
level.drop_chance = 8

local categories = {
	"players", "monsters", "particles", "projectiles", "powerups"
}

local function random_monster(self, ...)
	local i = 0
	local p = love.math.random(100)
	while i < #self.monsters_probability  do
		i = i + 1
		if self.monsters_probability[i] > p then
			break
		end
	end
	return self.monsters_preload[i](...)
end

local function rnd()
	return love.math.random() * 2 - 1
end

local function spawn_monsters(self)
	local hdx = self.dimensions.x * 0.5
	local hdy = self.dimensions.y * 0.5
	for i = 1, self.spawn_count do
		local p = vec2(rnd(), rnd())
		if math.abs(p.x) > math.abs(p.y) then
			p.x = math.sign(p.x)
			p.y = rnd()
		else
			p.x = rnd()
			p.y = math.sign(p.y)
		end
		p.x = (p.x + 1) * hdx - math.sign(p.x) * love.math.random(self.spawn_variation)
		p.y = (p.y + 1) * hdy - math.sign(p.y) * love.math.random(self.spawn_variation)
		random_monster(self, p, 10)
	end
	self.spawn_count = math.lerp(self.spawn_count, self.spawn_count_max, self.spawn_growth_factor)
end

function level.spawn_timeout(timer, self)
  if not self.is_game_over then
	  spawn_monsters(self)
	  if self.monsters_count >= self.max_monsters_count and self.players[1] ~= nil then
	  	self.players[1]:kill()
	  end
	  timer:reset()
  end
end

function level:new(player)
	self.player = player
	self.pressed = true
	self.monsters_preload = {}
	for k, v in ipairs(self.monsters_available) do
		self.monsters_preload[k] = require("monsters." .. v)
	end
	self.map = require("assets.maps." .. self:super().map)
	self.dimensions = vec2(self.map.width * 8, self.map.height * 8)
	self.prerender_batch = love.graphics.newSpriteBatch(assets.images["tilesheet.png"], self.map.width * self.map.height)
	self.prerender = love.graphics.newCanvas(self.dimensions:unpack())
	self.prerender:setWrap("clampzero")
	self.dirty_tiles = self.map.data
	self.column_height = 0
	self.map_is_dirty = true
	scene.new(self)
	scene.interrupted = nil
end

function level:open()
	self.batch = love.graphics.newSpriteBatch(assets.images["spritesheet.png"])
	self.camera = camera()
	-- Object categories 
	for i = 1, #categories do
		self[categories[i]] = {}
	end
	self.monsters_count = 0
	-- Deleted objects
	self.delete = setmetatable({}, {__mode = "k"}) 
	-- Drawable objects
	self.drawable = {} 
	-- Other properties
	self.shake = nil
	self.score = 0
	self.is_game_over = false
	-- Spawn timer
	self.spawn_timer = timer(self.spawn_rate, self.spawn_timeout, self)
	self.player(self.dimensions * 0.5)
	-- Message 
	self.message_text = ""
	self.message_scale = 0
	self.message_color = "white"
	self.message_timer = nil
	-- Spawn first horde
	spawn_monsters(self)
	self.spawn_count = self:super().spawn_count
  love.audio.stop()
  do local s = assets.sounds["game.wav"] s:setLooping(true) s:play() end
end

local function message_timeout(timer, self)
	self.message_timer = nil
end

function level:message(text, color, t)
	if self.message_timer ~= nil then
		self.message_timer:stop()
	end
	self.message_scale = 0
	self.message_text = text
	self.message_color = color or "white"
	self.message_timer = timer(t or 2, message_timeout, self)
end

function level:insert(what, obj)
	local t = assert(self[what], ("Unknown category '%s'"):format(what))
	t[#t + 1] = obj
end

function level:remove(obj)
	self.delete[obj] = true
end

local function update(t, delete, dt)
	for i = #t, 1, -1 do
		local obj = t[i]
		obj:update(dt)
		if delete[obj] then
			delete[obj] = nil
			obj:destroy()
			local n = #t
			t[i] = t[n]
			t[n] = nil
		end
	end
end

local game_over = "Game over!"

function level:update(dt)
	self.column_height = math.lerp(self.column_height, math.min(30, 30 * self.monsters_count / self.max_monsters_count), 10 * dt)
	-- Should spawn more monsters?
	if self.monsters_count == 0 then
		spawn_monsters(self)
		self.spawn_timer:reset()
	end
	-- Process message
	if self.message_timer ~= nil then
		self.message_scale = math.min(1.5, self.message_scale + 2 * dt)
	else
		self.message_scale = math.max(0, self.message_scale - 2 * dt)
	end
	-- Monster-monster collisions
	for i = 1, #self.monsters do
		local a = self.monsters[i]
		for j = i + 1, #self.monsters do
			local b = self.monsters[j]
			if a:collided(b) then
				if a.state ~= "dead" and b.state ~= "dead" then
					if a.state == "thrown" and b.state == "thrown" then
						a:despawn()
						b:despawn()
					elseif a.state == "thrown" or b.state == "thrown" then
						a:reaction(b)
					end
				end
				a:rigid_collision(b)
			end
		end
	end
	-- Collisions with player
	for i = 1, #self.players do
		local player = self.players[i]
		local pulling = a_pressed() and player.tank == 0 
		-- Player-monster collisions
		for i = 1, #self.monsters do
			local m = self.monsters[i]
			if m.shield == 0 then
				if player:should_absorb(m) then
					player:absorb(m)
				else
					local reachable = player:reachable(m)
					if reachable and player.mode == "push" then
						player:pull(m)
					elseif reachable and player.mode == "pull" then
						player:push(m)
					elseif m:collided(player) and m.z == player.z then
						player:rigid_collision(m)
						if m.state == "moving" and player.shield == 0 then
							if not player.punch_timer then
                player:hurt(1)
						  	m:hurt(1)
						  else
                m:throw(0.4, (m.position - player.position):normalize() * 150)
              end
            end
					end
				end
			end
		end
		-- Player-projectile collisions
		for i = 1, #self.projectiles do
			local p = self.projectiles[i]
			if p:collided(player) then
				if not player.punch_timer then player:hurt(p.damage) end
				p:despawn()
			end
		end
		-- Player-powerup collisions
		for i = 1, #self.powerups do
			local p = self.powerups[i]
			if p:collided(player) then
				assets.sounds["powerup.wav"]:clone():play()
				p:pickup(player)
				p:despawn()
			end
		end
	end
	-- Update objects 
	local delete = self.delete
	for i = 1, #categories do
		update(self[categories[i]], delete, dt)
	end
	-- Update tilemap
	if self.map_is_dirty then
		local old_canvas = love.graphics.getCanvas()
		local old_shader = love.graphics.getShader()
		local sb = self.prerender_batch
		love.graphics.setCanvas(self.prerender)
		love.graphics.setShader()
		love.graphics.clear(0, 0, 0)
		love.graphics.push("all")
		love.graphics.origin()
		sb:clear()
		for k, v in pairs(self.dirty_tiles) do
			self.map.data[k] = v
			sb:add(assets.tiles[v], (k % self.map.width) * 8, math.floor(k / self.map.height) * 8)
		end
		self.dirty_tiles = {}
		love.graphics.draw(sb)
		love.graphics.pop()
		love.graphics.setCanvas(old_canvas)
		love.graphics.setShader(old_shader)
		self.map_is_dirty = false
	end
	-- Focus camera to player
	if #self.players ~= 0 then
		local player = self.players[1]
		self.camera:new(player.position)
	end
	-- Return to menu, if needed
	if start_pressed() then
		if not self.pressed then
			local menu = require("scenes.menu")
      love.audio.stop()
			if not self.is_game_over then
				scene.interrupt(menu)
			else
				menu()
			end
			self.pressed = true
		end
	else
		self.pressed = false 
	end
end

local function sort(a, b)
	return a.z < b.z
end

local function count_objects(self)
	local n = 0
	for i = 1, #categories do
		n = n + #self[categories[i]]
	end
	return n
end

local function printb(text, x, y, fg, bg, r, sx, sy)
	local hw = assets.font:getWidth(text) * 0.5
	local hh = assets.font:getHeight() * 0.5
	love.graphics.setColor(bg)
	love.graphics.print(text, x - 1, y, r, sx, sy, hw, hh)
	love.graphics.print(text, x + 1, y, r, sx, sy, hw, hh)
	love.graphics.print(text, x, y - 1, r, sx, sy, hw, hh)
	love.graphics.print(text, x, y + 1, r, sx, sy, hw, hh)
	love.graphics.setColor(fg)
	love.graphics.print(text, x, y, r, sx, sy, hw, hh)
end

function level:draw()
	local n = 1
	-- Fill drawable table
	for i = 1, #categories do
		local t = self[categories[i]]
		for i = 1, #t do
			self.drawable[n] = t[i]
			n = n + 1
		end
	end
	-- Truncate
	for i = #self.drawable, n, -1 do
		self.drawable[i] = nil
	end
	-- Sort it
	table.sort(self.drawable, sort)
	-- Draw tilemap
	love.graphics.push()
	self.camera:apply_rounded(self.shake) 
	love.graphics.draw(self.prerender)
	love.graphics.pop()
	-- Draw other 
	love.graphics.push()
	self.camera:apply(self.shake)
	-- Fill spritebatch
	self.batch:clear()
	for i = 1, #self.drawable do
		self.drawable[i]:draw(self.batch)
	end
	-- Draw players interface
	if #self.players ~= 0 then
		local player = self.players[1]
		for i = 1, player.capacity do
			local a = i + love.timer.getTime() * 2
			local s = math.sin(a)
			local x = player.position.x + HALF_WIDTH - 12 + s * 1.5
			local y = player.position.y + HALF_HEIGHT - 10 - 14 * (i - 1)
			love.graphics.setColor("black")
			love.graphics.circle("line", x, y, 5 + math.abs(s))
			love.graphics.setColor("white")
			love.graphics.circle("line", x, y, 6 + math.abs(s))
			local m = player.tank[i]
			if m ~= nil then
				m.animations.idle:draw(self.batch, x, y, a, 0.75 + math.abs(s * 0.5))
			end
		end
		player.animations[player.state]:draw(self.batch, player.position.x - HALF_WIDTH + 6, player.position.y + HALF_HEIGHT - 6)
		do
			local x = player.position.x - HALF_WIDTH + 13
			local y = player.position.y + HALF_HEIGHT - assets.font:getHeight() - 2
			love.graphics.setColor("black")
			love.graphics.print("x" .. tostring(player.health), x + 1, y + 1)
			love.graphics.setColor("white")
			love.graphics.print("x" .. tostring(player.health), x, y)
		end
	end
	-- Draw with contour 
	love.graphics.setColor(0, 0, 0)
	love.graphics.draw(self.batch, -1, 0)
	love.graphics.draw(self.batch,  1, 0)
	love.graphics.draw(self.batch, 0, -1)
	love.graphics.draw(self.batch, 0,  1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.batch)
	-- Cancel camera
	love.graphics.pop()
	-- Print score
	local blink = math.floor(love.timer.getTime() * 4) % 2 == 0
	if self.is_game_over then
		if self.show_annotations then
			printb("GAME OVER!", HALF_WIDTH, HALF_HEIGHT * 0.5, "blue", "black", 0, 2)
			printb("Your score: " .. format_score(self.score), HALF_WIDTH, HALF_HEIGHT, "white", "black")
			printb("High score: " .. format_score(HIGHSCORE), HALF_WIDTH, HALF_HEIGHT + assets.font:getHeight() * 2 + 1, "white", "black")
			if self.score > HIGHSCORE then
				printb("New high score!", HALF_WIDTH, HALF_HEIGHT + assets.font:getHeight() * 4 + 2, blink and "yellow" or "white", "black")
			end
			printb(("Press '%s' to continue"):format("return/escape"), HALF_WIDTH, HEIGHT - assets.font:getHeight() - 4, blink and "green" or "blue", "black")
		else
			printb("GAME OVER!", HALF_WIDTH, (HALF_HEIGHT * 0.5) / self.game_over_timer.save * (self.game_over_timer.save - self.game_over_timer.time), "blue", "black", 0, 2)
		end
	else
		local score = format_score(self.score)
		love.graphics.setColor("white")
		love.graphics.print(score, (WIDTH - assets.font:getWidth(score)) * 0.5, 2)
		local minutes = math.floor(self.spawn_timer.time / 60)
		local seconds = self.spawn_timer.time - minutes * 60
		local string = ("%02i:%02i"):format(minutes, seconds)
		love.graphics.setColor(((minutes == 0 and seconds / self.spawn_timer.save > 0.25) or blink) and "white" or "red")
		love.graphics.print(string, HALF_WIDTH - assets.font:getWidth(string) * 0.5, 10)
		love.graphics.setColor("black")
		love.graphics.rectangle("fill", WIDTH - 9, 1, 8, 32)
		love.graphics.setColor("white")
		love.graphics.rectangle("fill", WIDTH - 8, 2, 6, 30)
		if self.column_height > 24 then
			love.graphics.setColor(blink and "red" or "white")
		elseif self.column_height > 15 then
			love.graphics.setColor("yellow")
		else
			love.graphics.setColor("green")
		end
		love.graphics.rectangle("fill", WIDTH - 8, 32, 6, -self.column_height)
	end
	-- Draw message
	local wid = assets.font:getWidth(self.message_text)
	local hei = assets.font:getHeight()
	printb(self.message_text, HALF_WIDTH, HEIGHT - hei * 2, self.message_color, "black", math.cos(love.timer.getTime() * 10) * math.pi / 12, self.message_scale, nil, wid * 0.5, hei * 0.5)
	-- Debug stuff
	if DEBUG then
		local s = ("Moncount: %i\nSpawn count: %i"):format(self.monsters_count, math.floor(self.spawn_count))
		love.graphics.setColor("red")
		love.graphics.print(s, 1, assets.font:getHeight() * 3 + 1)
		love.graphics.setColor("white")
		love.graphics.print(s, 0, assets.font:getHeight() * 3)
	end
end

function level:each(what)
	local i = 0
	local t = self[what]
	return function()
		while i < #t do
			i = i + 1
			return t[i]
		end
	end
end

local function map_index(self, x, y)
	return math.floor(x / 8) + math.floor(y / 8) * self.map.width
end

function level:look_range(x0, y0, x1, y1, fn, ...)
	for y = y0, y1 do
		for x = x0, x1 do
			local tile = self:look_tile(x, y)
			if fn(tile, ...) then
				return tile
			end
		end
	end
end

function level:look_tile(x, y)
	return tiles[self.map.data[map_index(self, x, y)]]
end

function level:place_tile(x, y, v)
	self.dirty_tiles[map_index(self, x, y)] = v
	self.map_is_dirty = true
end

local SCORE_LIMIT = tonumber(("9"):rep(8)) 

function level:add_score(score)
	self.score = math.min(SCORE_LIMIT, self.score + score)
	if self.score == SCORE_LIMIT then
		error("Score limit reached, consider yourself a winner!.. and tell about this problem to developer, please!")
	end
end

local function shake_off(timer, self)
	self.shake = nil
end

function level:shake_screen(t)
	self.shake = timer(t, shake_off, self)
end

function level:game_over()
	self.game_over_timer = timer(2, function(timer, self)
		self.is_game_over = true
    love.audio.stop()
    assets.sounds["gameover.wav"]:play()
		timer:new(1, function(timer, self)
			self.show_annotations = true
		end, self)
	end, self)
end

function level:close()
	if self.score > HIGHSCORE then
		HIGHSCORE = self.score
	end
end

return level
