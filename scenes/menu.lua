local scene = require("scene")
local assets = require("assets")
local background_effect = require("background_effect")
local menu = scene:extend():implement(background_effect)

local function load_module(name)
	return function()
		require(name)()
	end
end

menu.items = {
	{label = "New game", action = load_module("scenes.prelude")},
	{label = "Continue", action = function()
		if scene.current.interrupted then
      love.audio.stop()
      do local s = assets.sounds["game.wav"] s:setLooping(true) s:play() end
			scene.resume()
		end
	end, value = function()
		if not scene.current.interrupted then
			love.graphics.setColor("violet")
		end
		return ""
	end},
	{label = "Settings", action = load_module("scenes.settings")},
	{label = "Tutorial", action = load_module("levels.tutorial"),
	value = function()
		if TUTORIAL then
			love.graphics.setColor(math.floor(love.timer.getTime() * 3) % 2 == 0 and "yellow" or "white")
		end
	end},
	{label = "Exit", action = love.event.quit}
}

function menu:open(dont_restart)
	self.cursor = 1
	self.pressed = true
	self.cursor_y = 0 
	self.logo_scale_x = 0
	self.logo_scale_y = 0.1
	self:init_dots()
  local s = assets.sounds["menu.wav"]
  s:setLooping(true)
  s:play()
end

function menu:update(dt)
	self:update_dots(dt)
	-- How I can simplify this? :/
	if down_pressed() then
		if not self.pressed then
			self.cursor = math.min(self.cursor + 1, #self.items)
			self.pressed = true
			assets.sounds["select.wav"]:play()
			end
	elseif up_pressed() then
		if not self.pressed then
			self.cursor = math.max(self.cursor - 1, 1)
			self.pressed = true
			assets.sounds["select.wav"]:play()
			end
	elseif start_pressed() then
		if not self.pressed then
			self.items[self.cursor].action(self)
			self.pressed = true
			assets.sounds["select.wav"]:play()
		end
	else
		self.pressed = false
	end
	self.cursor_y = math.lerp(self.cursor_y, self.cursor * 9, 10 * dt)
	if self.logo_scale_x == 2 then
		self.logo_scale_y = math.min(2, self.logo_scale_y + dt * 4)
	else
		self.logo_scale_x = math.min(2, self.logo_scale_x + dt * 4)
	end
end

function menu:draw()
	self:draw_dots()
	-- Draw logo
	local logo = assets.images["logo.png"]
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(logo, HALF_WIDTH, HALF_HEIGHT / 2 + 4, 0, self.logo_scale_x, self.logo_scale_y, logo:getWidth() / 2, logo:getHeight() / 2)
	-- Print highscore
	love.graphics.setColor("white")
	local text = "High score: " .. format_score(HIGHSCORE)
	love.graphics.print(text, HALF_WIDTH - assets.font:getWidth(text) * 0.5, 0)
	-- Draw menu items
	love.graphics.translate(0, HALF_HEIGHT)
	for i = 1, #self.items do
		local item = self.items[i]
		local y = i * 9
		if self.cursor == i then
			love.graphics.setColor("blue")
			love.graphics.rectangle("fill", 0, self.cursor_y - 2, WIDTH, 9)
			love.graphics.setColor("white")
		else
			love.graphics.setColor("violet")
		end
		love.graphics.print(item.label .. (item.value and item.value() or ""), 4, y)
	end
	-- Draw author 
	local x = WIDTH - 1 - assets.font:getWidth("@ooichu_")
	love.graphics.setColor("white")
	love.graphics.print("@ooichu_", x, HALF_HEIGHT - assets.font:getHeight())
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(assets.images["spritesheet.png"], assets.frames.twitter, x - 8, HALF_HEIGHT - 8)
end

function menu:close()
-- love.audio.stop()
end

return menu
