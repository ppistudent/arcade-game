local object = require("object")
local powerup = object:extend()

powerup.category = "powerups"

-- Power properties
powerup.radius = 4

function powerup:pickup()
	error("powerup:pickup() method not implemented")
end

return powerup
