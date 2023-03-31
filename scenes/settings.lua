local menu = require("scenes.menu")
local settings = menu:extend()

local wipe_steps = 4

settings.items = {
	{
		label = "Sound: ",
		action = function()
			if love.audio.getVolume() ~= 0 then
				love.audio.setVolume(0)
			else
				love.audio.setVolume(1)
			end
		end,
		value = function()
			return love.audio.getVolume() == 0 and "off" or "on"
		end
	},
	{
		label = "Filter: ",
		action = function()
			USE_FILTER = not USE_FILTER
		end,
		value = function()
			return USE_FILTER and "on" or "off"
		end
	},
	{
		label = "Fullscreen: ",
		action = function()
			local fs = love.window.getFullscreen()
			love.window.setFullscreen(not fs)
		end,
		value = function()
			local fs = love.window.getFullscreen()
			return fs and "on" or "off"
		end
	},
	{
		label = "Vsync: ",
		action = function()
			love.window.setVSync(love.window.getVSync() == 0 and 1 or 0)
		end,
		value = function()
			return love.window.getVSync() == 0 and "off" or "on"
		end,
	},
	{
		label = "",
		action = function()
			if wipe_steps > 0 then
				wipe_steps = wipe_steps - 1
				if wipe_steps == 0 then
					wipe_steps = 0
					love.filesystem.remove(SAVE_FILE)	
					load_save()
				end
			end
		end,
		value = function()
			if wipe_steps == 4 then
				return "Wipe save data"
			end
			if wipe_steps == 0 then
				love.graphics.setColor("violet")
				return "Save data wiped"
			end
			return "Steps remaining: " .. tostring(wipe_steps)
		end
	},
	{
		label = "Back",
		action = menu
	}
}

function settings:open()
	menu.open(self)
	wipe_steps = 4
end

return settings
