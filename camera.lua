local vec2 = require("vec2")
local camera = vec2:extend()

function camera:apply(shake, factor)
	if shake then
		love.graphics.translate(love.math.random(-2, 2), love.math.random(-2, 2))
	end
  factor = factor or 1
	love.graphics.translate(HALF_WIDTH - self.x * factor, HALF_HEIGHT - self.y * factor)
end

function camera:apply_rounded(shake, factor)
	if shake then
		love.graphics.translate(love.math.random(-2, 2), love.math.random(-2, 2))
	end
  factor = factor or 1
	love.graphics.translate(
		math.floor((HALF_WIDTH - self.x) * factor + 0.5),
		math.floor((HALF_HEIGHT - self.y) * factor + 0.5))
end

return camera
