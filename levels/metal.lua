local level = require("level")
local metal = level:extend()

metal.spawn_variation = 20
metal.spawn_rate = 18
metal.spawn_count = 15
metal.spawn_count_max = 58
metal.spawn_growth_factor = 0.15
metal.max_monsters_count = 80
metal.map = "large" 
metal.require_score = 60000
metal.monsters_available = {
	"gob",
	"bat",
	"meatboy",
	"mole",
	"fred",
	"oneye",
	"woise"
}
metal.monsters_probability = {
	30,
	45,
	70,
	30,
	77,
	50,
	65
}

return metal
