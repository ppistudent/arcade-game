local pressed = love.keyboard.isScancodeDown

function up_pressed()
  return pressed('up') or pressed('w')
end

function down_pressed()
  return pressed('down') or pressed('s')
end

function left_pressed()
  return pressed('left') or pressed('a')
end

function right_pressed()
  return pressed('right') or pressed('d')
end

function b_pressed()
  return pressed('z') or pressed('k')
end

function a_pressed()
  return pressed('x') or pressed('l')
end

function start_pressed()
  return pressed('return') or pressed('escape')
end

local assets = require("assets")
local scene = require("scene")
local level = require("level")

-- Reimplementation love.graphics.setColor and love.graphics.setBackgroundColor 
-- functions for setting color from fixed palette
do
	local set_fg, set_bg, palette = love.graphics.setColor, love.graphics.setBackgroundColor, {
		white  = {240 / 255, 240 / 255, 220 / 255},
		yellow = {250 / 255, 200 / 255,   0 / 255},
		green  = { 16 / 255, 200 / 255,  64 / 255},
		blue   = {  0 / 255, 160 / 255, 200 / 255},
		red    = {210 / 255,  64 / 255,  64 / 255},
		brown  = {160 / 255, 110 / 255,  70 / 255},
		violet = {115 / 255, 100 / 255, 100 / 255},
		black  = { 16 / 255,  24 / 255,  32 / 255}
	}
	function love.graphics.setBackgroundColor(color, alpha, ...)
		if type(color) == "string" then
			color = assert(palette[color], "Unknown color")
			set_bg(color[1], color[2], color[3], alpha)
		else
			set_bg(color, alpha, ...)
		end
	end
	function love.graphics.setColor(color, alpha, ...)
		if type(color) == "string" then
			color = assert(palette[color], "Unknown color")
			set_fg(color[1], color[2], color[3], alpha)
		else
			set_fg(color, alpha, ...)
		end
	end
end

function love.keypressed(key)
  if key == "space" and scene.current:is(level) then
    LOCK = not LOCK
  end
end

local function file_contents(filename, defaults)
	if love.filesystem.getInfo(filename) == nil then
		local success, message = love.filesystem.write(filename, defaults)
		if not success then
			error(message)
		end
	end
	local content, err = love.filesystem.load(filename)
	if err ~= nil then
		print(err)
		settings = loadstring(defaults)
	end
	return content()
end

local function write_file(filename, txt)
	local success, message = love.filesystem.write(filename, txt)
	if not success then
		error(message)
	end
end

function load_settings()
	-- Load settings file
	local settings = file_contents(SETTINGS_FILE, DEFAULT_SETTINGS)
	-- Apply settings
	love.window.setFullscreen(settings.fullscreen)
	love.window.setVSync(settings.vsync == true and 1 or 0)
	love.audio.setVolume(settings.audio and 1 or 0)
	USE_FILTER = settings.filter == true and true or false
  LOCK = settings.lock == true and true or false
end

function load_save()
	-- Load save file
	local save = file_contents(SAVE_FILE, DEFAULT_SAVE)
	-- Apply save
	HIGHSCORE = save.highscore
	TUTORIAL = save.tutorial
end

local cur_flash_time = 1
local max_flash_time = 1
local do_flash = false

function flash_screen(t)
	assert(t ~= 0, "flash time cannot be 0")
	max_flash_time = t
	cur_flash_time = t
	do_flash = true
end

function flash_is_out()
	return not do_flash 
end

function love.run()
	-- Load files
	load_settings()
	load_save()
	-- Engine setup
	love.graphics.setDefaultFilter("nearest")
	love.graphics.setLineStyle("rough")
	local letterbox = love.graphics.newCanvas(WIDTH, HEIGHT)
	letterbox:setWrap("clampzero")
	love.graphics.setBackgroundColor("black")
	assets:load()
	assets.shaders["filter.glsl"]:send("WIDTH", WIDTH)
	assets.shaders["filter.glsl"]:send("HEIGHT", HEIGHT)
	-- Game setup
	require("scenes.splash")()
	-- Game loop
	love.timer.step()
	local TARGET_FRAME_RATE = 1 / 60
	local accumulator = 0
	return function()
		-- Update system events
		love.event.pump()
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					-- Write settings
					if not DEBUG then
						write_file(SETTINGS_FILE, table.concat{
							"return {\n",
							"\tfullscreen = ", tostring(love.window.getFullscreen()), ",\n",
							"\tvsync = ", tostring(love.window.getVSync() ~= 0), ",\n",
							"\tfilter = ", tostring(USE_FILTER), ",\n",
							"\taudio = ", tostring(love.audio.getVolume() ~= 0), ",\n",
              "\tlock = ", tostring(LOCK),
							"\n}"
						})
						-- Write save
						write_file(SAVE_FILE, table.concat{
							"return {\n",
							"\ttutorial = ", tostring(TUTORIAL), ",\n",
							"\thighscore = ", tostring(HIGHSCORE),
							"\n}"
						})
					end
					return a or 0
				end
			end
			love.handlers[name](a, b, c, d, e, f)
		end
		-- Variable time step
		accumulator = accumulator + love.timer.step()
		if accumulator >= TARGET_FRAME_RATE then
			if do_flash then
				cur_flash_time = math.max(0, cur_flash_time - TARGET_FRAME_RATE)
				if cur_flash_time == 0 then
					cur_flash_time = 1
					max_flash_time = 1
					do_flash = false
				end
			end
			scene.update(TARGET_FRAME_RATE)
			accumulator = accumulator - TARGET_FRAME_RATE
		end
		-- Update flash
		-- Draw
		if love.graphics.isActive() then
			-- Set letterbox as render target
			assets.shaders["flash.glsl"]:send("flash_factor", do_flash and 10 * (0.1 + cur_flash_time / max_flash_time) or 1)
			love.graphics.setShader(assets.shaders["flash.glsl"])
			love.graphics.setCanvas(letterbox)
			-- Draw scene
			love.graphics.push("all")
			love.graphics.clear(love.graphics.getBackgroundColor())
			scene.draw()
			love.graphics.pop()
			-- Draw debug info
			if DEBUG then
				local dbg = ("%iFPS\n%iKb"):format(love.timer.getFPS(), math.floor(collectgarbage("count")))
				love.graphics.setColor("red")
				love.graphics.print(dbg, 1, 1)
				love.graphics.setColor("yellow")
				love.graphics.print(dbg, 0, 0)
			end
			-- Set window screen as render target
			love.graphics.setCanvas()
			love.graphics.clear()
			if USE_FILTER then
				love.graphics.setShader(assets.shaders["filter.glsl"])
			end
			-- Draw letterbox
			local screen_width = love.graphics.getWidth()
			local screen_height = love.graphics.getHeight()
			local scale = math.min(screen_width * INVERSE_WIDTH, screen_height * INVERSE_HEIGHT)
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(letterbox, screen_width * 0.5, screen_height * 0.5, 0, scale, scale, HALF_WIDTH, HALF_HEIGHT)
			love.graphics.present()
		end 
		love.timer.sleep(0.001)
	end
end
