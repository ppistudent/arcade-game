local class = require("class")
local scene = class:extend()

function scene:new()
	-- Close old scene, if it exists 
	if scene.current then
		scene.current:close()	
		scene.current = nil
		collectgarbage()
	end
	-- Open new scene 
	scene.current = self
	self.timers = {}
	self.camera = nil
	self:open()
end

-- XXX: scene.interrupt and scene.resume are bad stuff, used only for pause menu

function scene.interrupt(by, ...)
	scene.interrupted = scene.current
	scene.current = nil
	by(...)
end

function scene.resume()
	scene.current:close()	
	scene.current = nil
	collectgarbage()
	scene.current = scene.interrupted
	scene.interrupted = nil
end

--
-- Update / draw current scene
--

local function update_timers(t, dt)
	for i = #t, 1, -1 do
		local tim = t[i]
		if tim.disabled == false then
			tim:update(dt)
		else
			local n = #t
			t[i] = t[n]
			t[n] = nil
		end
	end
end

function scene.update(dt)
	local current = scene.current
	assert(current, "Scene not opened!")
	update_timers(current.timers, dt)
	current:update(dt)
end

function scene.draw()
	assert(scene.current, "Scene not opened!"):draw()
end

--
-- Open / close custom callbacks
--

scene.open = function() end
scene.close = function() end

return scene
