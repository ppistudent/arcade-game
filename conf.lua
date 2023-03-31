VERSION = "1.2"
DEBUG = false
LOCK = true

-- Settings
SETTINGS_FILE = "settings"
DEFAULT_SETTINGS = [[
return {
	fullscreen = false,
	vsync = true,
	filter = true,
	audio = true,
  lock = true
}
]]

-- Save
SAVE_FILE = "save"
DEFAULT_SAVE = [[
return {
	tutorial = true,
	highscore = 0
}
]]

function format_score(n)
	local score = tostring(n)
	score = ("0"):rep(math.max(0, 8 - #score)) .. score
	return score
end

-- Graphics constants
WIDTH = 136
HEIGHT = 136
HALF_WIDTH = WIDTH / 2
HALF_HEIGHT = HEIGHT / 2
INVERSE_WIDTH = 1 / WIDTH
INVERSE_HEIGHT = 1 / HEIGHT
DEFAULT_SCALE = 6

-- Input settings
function love.conf(t)
	-- Config Love2D
	t.identity = nil
	t.appendidentity = false
	t.version = "11.3"
	t.console = false
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.gammacorrect = false
	-- Audio settings
	t.audio.mic = false
	t.audio.mixwithsystem = true
	-- Window settings
	t.window.title = "Vacuum warriors" ..  " v" .. VERSION
	t.window.icon = "assets/images/icon.png"
	t.window.width = WIDTH * DEFAULT_SCALE
	t.window.height = HEIGHT * DEFAULT_SCALE
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = WIDTH
	t.window.minheight = HEIGHT
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = false
	t.window.usedpiscale = true
	t.window.x = nil
	t.window.y = nil
	-- Using modules
	t.modules.audio = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = false
	t.modules.physics = false 
	t.modules.sound = true
	t.modules.system = false
	t.modules.thread = false
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = true
end

-- Missing math definitions
function math.lerp(a, b, t)
	return a + (b - a) * t 
end

function math.sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

function math.clamp(x, a, b)
	return x < a and a or x > b and b or x
end
