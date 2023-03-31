local assets = {}

local function charset(n)
	local t = {}
	for i = 1, n do
		t[i] = string.char(i - 1)
	end
	return table.concat(t)
end

assets.directory = "assets/"
assets.images_directory = assets.directory .. "images/"
assets.sounds_directory = assets.directory .. "sounds/"
assets.shaders_directory = assets.directory .. "shaders/"

-- Auto load/unload assets if needed
local function weak_container(directory, load, ...)
	local args = {...}
	return setmetatable({}, {
		__mode = "v",
		__index = function(t, k)
			if rawget(t, k) == nil then
				t[k] = load(directory .. k, unpack(args))
			end
			return rawget(t, k)
		end
	})
end

-- Keep asset all time
local function strong_container(directory, load, ...)
	local args = {...}
	return setmetatable({}, {
		__index = function(t, k)
			if rawget(t, k) == nil then
				t[k] = load(directory .. k, unpack(args))
			end
			return rawget(t, k)
		end
	})
end

function assets:load()
	-- Images, shaders and sounds
	self.images = strong_container(self.images_directory, function(k, ...)
		if DEBUG then
			print(("Loading image '%s'..."):format(k))
		end
		return love.graphics.newImage(k, ...)
	end)
	self.sounds = strong_container(self.sounds_directory, function(k, ...)
		if DEBUG then
			print(("Loading sound '%s'..."):format(k))
		end
		return love.audio.newSource(k, ...)
	end, "static")
	self.shaders = strong_container(self.shaders_directory, function(k, ...)
		if DEBUG then
			print(("Compiling shader '%s'..."):format(k))
		end
		return love.graphics.newShader(k, ...)
	end)
	-- Font
	self.font = love.graphics.newImageFont(self.images_directory .. "font.png", charset(128))
	self.font:setLineHeight(1 + 1 / self.font:getHeight())
	love.graphics.setFont(self.font)
	-- Frames 
	local i_width = self.images["spritesheet.png"]:getWidth()
	local i_height = self.images["spritesheet.png"]:getHeight()
	local s_width = 64
	local s_height = 64
	self.frames = {}
	-- Robot frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 0, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 0, 8, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 8, 8, 8, i_width, i_height),
			love.graphics.newQuad(0 * s_width + 0, 8, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 8, 8, 8, i_width, i_height)
		}	
		local dead = {
			love.graphics.newQuad(0 * s_width + 0, 16, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 16, 8, 8, i_width, i_height),
			love.graphics.newQuad(0 * s_width + 0, 16, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 16, 8, 8, i_width, i_height)
		}
		self.frames.robot = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Mike frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 0, 24, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 24, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 0, 32, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 32, 8, 8, i_width, i_height),
			love.graphics.newQuad(0 * s_width + 0, 32, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 32, 8, 8, i_width, i_height)
		}	
		local dead = {
			love.graphics.newQuad(0 * s_width + 0, 40, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 40, 8, 8, i_width, i_height),
			love.graphics.newQuad(0 * s_width + 0, 40, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 40, 8, 8, i_width, i_height)
		}
		self.frames.guy = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Shad frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 0, 48, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 48, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 0, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 0, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 0, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 0, 56, 8, 8, i_width, i_height)
		}	
		local dead = {
			love.graphics.newQuad(0 * s_width + 8, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 8, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 8, 56, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 8, 56, 8, 8, i_width, i_height)
		}	
		self.frames.voidman = {
			idle = idle,
			moving = moving,
			thrown = idle,
			stunned = idle,
			dead = dead 
		}
	end
	-- Meatboy frames
	do
		local idle = {
			love.graphics.newQuad(3 * s_width + 16, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 16, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 16, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 16, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 16, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 16, 8, 8, 8, i_width, i_height)
		}
		self.frames.meatboy = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Oneye frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 8, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 8, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 8, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 8, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 8, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 8, 8, 8, 8, i_width, i_height),
		}
		self.frames.oneye = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Fred frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 24, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 24, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 24, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 24, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 24, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 24, 8, 8, 8, i_width, i_height)
		}
		self.frames.fred = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Woise frames
	do
		local idle = {
			love.graphics.newQuad(1 * s_width + 32, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 32, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 32, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 32, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 32, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 32, 8, 8, 8, i_width, i_height)
		}
		self.frames.woise = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Bat frames
	do
		local idle = {
			love.graphics.newQuad(1 * s_width + 40, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 40, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 40, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 40, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 40, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 40, 8, 8, 8, i_width, i_height)
		}
		self.frames.bat = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Gob frames
	do
		local idle = {
			love.graphics.newQuad(1 * s_width + 48, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 48, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 48, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 48, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 48, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 48, 8, 8, 8, i_width, i_height)
		}
		self.frames.gob = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead
		}
	end
	-- Mole frames
	do
		local idle = {
			love.graphics.newQuad(1 * s_width + 56, 0, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 56, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 56, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(2 * s_width + 56, 0, 8, 8, i_width, i_height),
			love.graphics.newQuad(3 * s_width + 56, 0, 8, 8, i_width, i_height)
		}
		local dead = {
			love.graphics.newQuad(0 * s_width + 56, 8, 8, 8, i_width, i_height)
		}
		self.frames.mole = {
			idle = idle,
			moving = moving,
			thrown = dead,
			stunned = idle,
			dead = dead,
			dig = {
				love.graphics.newQuad(0 * s_width + 56, 16, 8, 8, i_width, i_height),
				love.graphics.newQuad(1 * s_width + 56, 16, 8, 8, i_width, i_height),
				love.graphics.newQuad(2 * s_width + 56, 16, 8, 8, i_width, i_height),
				love.graphics.newQuad(3 * s_width + 56, 16, 8, 8, i_width, i_height)
			}
		}
	end
	-- Pet frames
	do
		local idle = {
			love.graphics.newQuad(0 * s_width + 8, 24, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 8, 24, 8, 8, i_width, i_height)
		}
		local moving = {
			love.graphics.newQuad(0 * s_width + 16, 24, 8, 8, i_width, i_height),
			love.graphics.newQuad(1 * s_width + 16, 24, 8, 8, i_width, i_height)
		}
		self.frames.pet = {
			idle = idle,
			moving = moving,
			thrown = idle,
			stunned = idle,
			dead = idle
		}
	end
	-- Bullet frames
	self.frames.bullet = {
		love.graphics.newQuad(0 * s_width + 48, 16, 8, 8, i_width, i_height),
		love.graphics.newQuad(1 * s_width + 48, 16, 8, 8, i_width, i_height)
	}
	-- Medikit frames
	self.frames.medikit = {
		love.graphics.newQuad(0 * s_width + 8, 16, 8, 8, i_width, i_height)
	}
	-- Bomb frames
	self.frames.bomb = {
		love.graphics.newQuad(0 * s_width + 16, 16, 8, 8, i_width, i_height)
	}
	-- Flash frames
	self.frames.flash = {
		love.graphics.newQuad(0 * s_width + 24, 16, 8, 8, i_width, i_height)
	}
  -- Punch frames
  self.frames.punch = {
		love.graphics.newQuad(0 * s_width + 24, 24, 8, 8, i_width, i_height)
  }
	-- Stun effect frames
	self.frames.stun = {
		love.graphics.newQuad(0 * s_width + 32, 16, 8, 8, i_width, i_height),
		love.graphics.newQuad(1 * s_width + 32, 16, 8, 8, i_width, i_height),
		love.graphics.newQuad(2 * s_width + 32, 16, 8, 8, i_width, i_height),
		love.graphics.newQuad(3 * s_width + 32, 16, 8, 8, i_width, i_height)
	}
	-- Heart frame
	self.frames.heart = love.graphics.newQuad(0 * s_width + 40, 16, 3, 3, i_width, i_height)
	-- Angry frame
	self.frames.angry = love.graphics.newQuad(0 * s_width + 40, 24, 4, 4, i_width, i_height)
	-- Twitter logo
	self.frames.twitter = love.graphics.newQuad(0 * s_width + 56, 24, 8, 8, i_width, i_height)
  -- Lock
  self.frames.lock = love.graphics.newQuad(0 * s_width + 32, 24, 8, 8, i_width, i_height)
	-- Tiles quads
	do
		local w, h = self.images["tilesheet.png"]:getDimensions()
		self.tiles = {
			[1] = love.graphics.newQuad(0, 0, 8, 8, w, h),
			[2] = love.graphics.newQuad(8, 0, 8, 8, w, h),
			[3] = love.graphics.newQuad(16, 0, 8, 8, w, h),
			[9] = love.graphics.newQuad(0, 8, 8, 8, w, h),
			[10] = love.graphics.newQuad(8, 8, 8, 8, w, h),
			[11] = love.graphics.newQuad(16, 8, 8, 8, w, h),
			[12] = love.graphics.newQuad(24, 8, 8, 8, w, h),
			[17] = love.graphics.newQuad(0, 16, 8, 8, w, h),
			[18] = love.graphics.newQuad(8, 16, 8, 8, w, h),
			[19] = love.graphics.newQuad(16, 16, 8, 8, w, h),
			[20] = love.graphics.newQuad(24, 16, 8, 8, w, h),
			[21] = love.graphics.newQuad(32, 16, 8, 8, w, h),
			[22] = love.graphics.newQuad(40, 16, 8, 8, w, h),
			[25] = love.graphics.newQuad(0, 24, 8, 8, w, h),
			[26] = love.graphics.newQuad(8, 24, 8, 8, w, h),
			[27] = love.graphics.newQuad(16, 24, 8, 8, w, h),
			[28] = love.graphics.newQuad(24, 24, 8, 8, w, h),
			[29] = love.graphics.newQuad(32, 24, 8, 8, w, h),
			[30] = love.graphics.newQuad(40, 24, 8, 8, w, h),
			[33] = love.graphics.newQuad(0, 32, 8, 8, w, h),
			[34] = love.graphics.newQuad(8, 32, 8, 8, w, h),
			[35] = love.graphics.newQuad(16, 32, 8, 8, w, h),
			[36] = love.graphics.newQuad(24, 32, 8, 8, w, h),
			[37] = love.graphics.newQuad(32, 32, 8, 8, w, h),
			[38] = love.graphics.newQuad(40, 32, 8, 8, w, h)
		}
	end
	-- Restrict reloading
	self.load = nil 
	collectgarbage()
end

return assets
