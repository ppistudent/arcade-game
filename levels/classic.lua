local level = require("level")
local classic = level:extend()

classic.spawn_variation = 18
classic.spawn_rate = 30
classic.spawn_count = 8
classic.spawn_count_max = 45
classic.spawn_growth_factor = 0.2
classic.max_monsters_count = 80
classic.map = "small" 
classic.require_score = 0
classic.monsters_available = {
	"gob",
	"oneye",
	"woise",
	"fred",
	"meatboy",
	"mole",
	"bat"
}
classic.monsters_probability = {
	8,
	45,
	50,
	65,
	70,
	72,
	77
}

return classic
